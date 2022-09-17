#include "NuBusFPGADrvr.h"

void linearGamma(NuBusFPGADriverGlobalsPtr dStore) {
	int i;
	dStore->gamma.gVersion = 0;
	dStore->gamma.gType = 0;
	dStore->gamma.gFormulaSize = 0;
	dStore->gamma.gChanCnt = 3;
	dStore->gamma.gDataCnt = 256;
	dStore->gamma.gDataWidth = 8;
	for (i = 0 ; i < 256 ; i++) {
		dStore->gamma.gFormulaData[0][i] = i;
		dStore->gamma.gFormulaData[1][i] = i;
		dStore->gamma.gFormulaData[2][i] = i;
	}
}

OSErr changeIRQ(AuxDCEPtr dce, char en, OSErr err) {
   NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
   NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
   char busMode = 1;
   if (en != dStore->irqen) {
	   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF000F); */
	   /* write_reg(dce, GOBOFB_DEBUG, en); */
	   
	   if (en) {
	   	   if (SIntInstall(dStore->siqel, dce->dCtlSlot)) {
	   		   return err;
	   	   }
	   } else {
	   	   if (SIntRemove(dStore->siqel, dce->dCtlSlot)) {
	   		   return err;
	   	   }
	   }

	   SwapMMUMode ( &busMode );
	   write_reg(dce, GOBOFB_VBL_MASK, en ? GOBOFB_INTR_VBL : 0);
	   SwapMMUMode ( &busMode );
	   dStore->irqen = en;
   }
   return noErr;
}

/*
  7.1.1:
     11 Debug: 0x00000003
      2 Debug: 0x00000004
      1 Debug: 0x00000005
      4 Debug: 0x00000006
      1 �Debug: 0x00000002

  7.5.3:
      4 Debug: 0x00000002
     12 Debug: 0x00000003
      3 Debug: 0x00000004
      5 Debug: 0x00000005
      5 Debug: 0x00000006
      5 Debug: 0x00000009
      4 Debug: 0x0000000a
      5 Debug: 0x00000010
      1 �Debug: 0x00000002

  8.1:
      5 Debug: 0x00000002
      9 Debug: 0x00000003
      1 Debug: 0x00000004
      6 Debug: 0x00000005
      6 Debug: 0x00000006
      4 Debug: 0x00000009
      5 Debug: 0x0000000a
      4 Debug: 0x00000010
      1 �Debug: 0x00000002
*/


OSErr cNuBusFPGACtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
   NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
   NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
   
   short ret = -1;
   char	busMode = 1;

   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0001); */
   /* write_reg(dce, GOBOFB_DEBUG, pb->csCode); */
   
#if 1
  switch (pb->csCode)
  {
  case -1:
	  asm volatile(".word 0xfe16\n");
  	  break;
  case cscReset:
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   dStore->curMode = firstVidMode;
		   dStore->curDepth = kDepthMode1; /* 8-bit */
		   vPInfo->csMode = firstVidMode;
		   vPInfo->csPage = 0;
		   vPInfo->csBaseAddr = 0;
		   ret = noErr;
	   }
  	  break;
  case cscKillIO:
	  asm volatile(".word 0xfe16\n");
	  ret = noErr;
	  break;
  case cscSetMode: /* 2 */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   if (vPInfo->csPage != 0)
			   return paramErr;
		   SwapMMUMode ( &busMode );
		   switch (vPInfo->csMode) {
		   case kDepthMode1:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_8BIT);
			   break;
		   case kDepthMode2:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_4BIT);
		   	   break;
		   case kDepthMode3:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_2BIT);
		   	   break;
		   case kDepthMode4:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_1BIT);
		   	   break;
		   case kDepthMode5:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_24BIT);
		   	   break;
		   case kDepthMode6:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_15BIT);
		   	   break;
		   default:
			   SwapMMUMode ( &busMode );
			   return paramErr;
		   }
		   dStore->curDepth = vPInfo->csMode;
		   SwapMMUMode ( &busMode );
		   vPInfo->csBaseAddr = 0;
		   ret = noErr;
	   }
	  break;
  case cscSetEntries: /* 3 */
	  if (1) {
		  VDSetEntryRecord	**vdentry = (VDSetEntryRecord **)(long *)pb->csParam;
		  int csCount = (*vdentry)->csCount;
		  int csStart = (*vdentry)->csStart;
		  int i;
		  if (csCount <= 0) {
			  ret = noErr;
			  goto cscSetMode_done;
		  }
		  SwapMMUMode ( &busMode );
		  if (csStart < 0) {
			  for (i = 0 ; i <= csCount ; i++) {
				  unsigned char idx = ((*vdentry)->csTable[i].value & 0x0FF);
				  /* dStore->shadowClut[idx*3+0] = (*vdentry)->csTable[i].rgb.red; */
				  /* dStore->shadowClut[idx*3+1] = (*vdentry)->csTable[i].rgb.green; */
				  /* dStore->shadowClut[idx*3+2] = (*vdentry)->csTable[i].rgb.blue; */
				  
				  write_reg(dce, GOBOFB_LUT_ADDR, 3 * idx);
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[0][(*vdentry)->csTable[i].rgb.red>>8 & 0xFF]);
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[1][(*vdentry)->csTable[i].rgb.green>>8 & 0xFF]);
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[2][(*vdentry)->csTable[i].rgb.blue>>8 & 0xFF]);
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.red); */
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.green); */
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.blue); */
			  }
		  } else {
			  write_reg(dce, GOBOFB_LUT_ADDR, 3 * (csStart & 0xFF));
			  for (i = 0 ; i <= csCount ; i++) {
				  /* dStore->shadowClut[(i+csStart)*3+0] = (*vdentry)->csTable[i].rgb.red; */
				  /* dStore->shadowClut[(i+csStart)*3+1] = (*vdentry)->csTable[i].rgb.green; */
				  /* dStore->shadowClut[(i+csStart)*3+2] = (*vdentry)->csTable[i].rgb.blue; */
				  
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[0][(*vdentry)->csTable[i].rgb.red>>8 & 0xFF]);
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[1][(*vdentry)->csTable[i].rgb.green>>8 & 0xFF]);
				  write_reg(dce, GOBOFB_LUT, dStore->gamma.gFormulaData[2][(*vdentry)->csTable[i].rgb.blue>>8 & 0xFF]);
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.red); */
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.green); */
				  /* write_reg(dce, GOBOFB_LUT, (*vdentry)->csTable[i].rgb.blue); */
			  }
		  }
		  SwapMMUMode ( &busMode );
		  ret = noErr;
	  } else {
			   ret = noErr;
	  }
	  cscSetMode_done:
	  break;
  case cscSetGamma: /* 4 */
	  {
		   VDGammaRecord	*vdgamma = (VDGammaRecord *)*(long *)pb->csParam;
		   GammaTbl	*gammaTbl = (GammaTbl*)vdgamma->csGTable;
		   int i;
		   if (gammaTbl == NULL) {
			   linearGamma(dStore);
		   } else {
			   if (gammaTbl->gDataWidth != 8)
				   return paramErr;
			   if (gammaTbl->gDataCnt != 256) // 8-bits
				   return paramErr;
			   if ((gammaTbl->gChanCnt != 1) && (gammaTbl->gChanCnt != 3))
				   return paramErr;
			   if ((gammaTbl->gType != 0) && (gammaTbl->gType != 0xFFFFBEEF))
				   return paramErr;
			   if (gammaTbl->gFormulaSize != 0)
				   return paramErr;
			   
			   dStore->gamma.gVersion =     gammaTbl->gVersion;
			   dStore->gamma.gType =        gammaTbl->gType;
			   dStore->gamma.gFormulaSize = gammaTbl->gFormulaSize;
			   dStore->gamma.gChanCnt =     gammaTbl->gChanCnt;
			   dStore->gamma.gDataCnt =     gammaTbl->gDataCnt;
			   dStore->gamma.gDataWidth =   gammaTbl->gDataWidth;
			   
			   int og, ob;
			   if (gammaTbl->gChanCnt == 1)
				   og = ob = 0;
			   else {
				   og = 256;
				   ob = 512;
			   }
			   for (i = 0 ; i < gammaTbl->gDataCnt ; i++) {
				   dStore->gamma.gFormulaData[0][i] = ((unsigned char*)gammaTbl->gFormulaData)[i +  0];
				   dStore->gamma.gFormulaData[1][i] = ((unsigned char*)gammaTbl->gFormulaData)[i + og];
				   dStore->gamma.gFormulaData[2][i] = ((unsigned char*)gammaTbl->gFormulaData)[i + ob];
			   }
		   }
 		   ret = noErr;
	   }
	  break;
  case cscGrayPage: /* 5 == cscGrayScreen */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   const uint8_t idx = dStore->curMode % 4; // checkme
		   const UInt32 a32 = dce->dCtlDevBase;
		   UInt32 a32_l0, a32_l1;
		   UInt32 a32_4p0, a32_4p1;
		   const uint32_t wb = HRES >> idx;
		   unsigned short j, i;
		   
		   if (vPInfo->csPage != 0)
			   return paramErr;
		   
		   SwapMMUMode ( &busMode );
#if 0
		   if ((dStore->curMode != kDepthMode5) && (dStore->curMode != kDepthMode6)) {
			   /* grey the screen */
			   a32_l0 = a32;
			   a32_l1 = a32 + wb;
			   for (j = 0 ; j < VRES ; j+= 2) {
				   a32_4p0 = a32_l0;
				   a32_4p1 = a32_l1;
				   for (i = 0 ; i < wb ; i += 4) {
					   *((UInt32*)a32_4p0) = 0xFF00FF00;
					   *((UInt32*)a32_4p1) = 0x00FF00FF;
					   a32_4p0 += 4;
					   a32_4p1 += 4;
				   }
				   a32_l0 += 2*wb;
				   a32_l1 += 2*wb;
			   }
		   } else {
			   /* testing */
			   a32_l0 = a32;
			   a32_l1 = a32 + HRES*4;
			   for (j = 0 ; j < VRES ; j+= 2) {
				   a32_4p0 = a32_l0;
				   a32_4p1 = a32_l1;
				   for (i = 0 ; i < HRES ; i ++ ) {
					   *((UInt32*)a32_4p0) = (i&0xFF);//(i&0xFF) | (i&0xFF)<<8 | (i&0xff)<<24;
					   *((UInt32*)a32_4p1) = (i&0xFF)<<16;//(i&0xFF) | (i&0xFF)<<8 | (i&0xff)<<24;
					   a32_4p0 += 4;
					   a32_4p1 += 4;
				   }
				   a32_l0 += 2*HRES*4;
				   a32_l1 += 2*HRES*4;
			   }
		   }
#else

#define WAIT_FOR_HW_LE(accel_le)						\
	while (accel_le->reg_status & (1<<WORK_IN_PROGRESS_BIT))
		   
		   const UInt32 fgcolor = 0; // FIXME: per-depth?
		   struct goblin_accel_regs* accel_le = (struct goblin_accel_regs*)(dce->dCtlDevBase+GOBOFB_ACCEL_LE);
		   WAIT_FOR_HW_LE(accel_le);
		   switch (dStore->curMode) {
		   default:
		   case firstVidMode:
			   accel_le->reg_width = HRES; // pixels
			   accel_le->reg_height = VRES;
			   break;
		   case secondVidMode:
			   accel_le->reg_width = 640; // pixels
			   accel_le->reg_height = 480;
			   break;
		   }
		   accel_le->reg_bitblt_dst_x = 0; // pixels
		   accel_le->reg_bitblt_dst_y = 0;
		   accel_le->reg_dst_ptr = 0;
		   accel_le->reg_fgcolor = fgcolor;
		   accel_le->reg_cmd = (1<<DO_FILL_BIT);
		   WAIT_FOR_HW_LE(accel_le);

#undef WAIT_FOR_HW_LE
		   
#endif
		   SwapMMUMode ( &busMode );
		   
		   ret = noErr;
	   }
	  break;
  case cscSetGray: /* 6 */
	   {
		   VDGrayRecord	*vGInfo = (VDGrayRecord *)*(long *)pb->csParam;
		   dStore->gray = vGInfo->csMode;
		   ret = noErr;
	   }
	  break;
	  
  case cscSetInterrupt: /* 7 */
	   {
		   VDFlagRecord	*vdflag = (VDFlagRecord *)*(long *)pb->csParam;
		   ret = changeIRQ(dce, 1 - vdflag->csMode, controlErr);
	   }
  	  break;

  case cscDirectSetEntries: /* 8 */
	  asm volatile(".word 0xfe16\n");
	  return controlErr;
	  break;

  case cscSetDefaultMode: /* 9 */
	   {
		   VDDefMode	*vddefm = (VDDefMode *)*(long *)pb->csParam;
		   
		   switch (vddefm->csID) {
		   case firstVidMode:
			   break;
		   case secondVidMode:
			   break;
		   default:
			   return paramErr;
		   }
		   
		   ret = noErr;
	   }
	  break;

  case cscSwitchMode: /* 0xa */
	  {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  if (vdswitch->csPage != 0)
			  return paramErr;
		  if ((vdswitch->csData == dStore->curMode) &&
			  (vdswitch->csMode == dStore->curDepth)) {
			  return noErr;
		  }

		  unsigned short i;
		  for (i = firstVidMode ; i <= secondVidMode ; i++) {
			  // disable spurious resources, enable only the right one
			  SpBlock spb;
			  spb.spParamData = (i != vdswitch->csData ? 1 : 0); /* disable/enable */
			  spb.spSlot = dStore->slot;
			  spb.spID = i;
			  spb.spExtDev = 0;
			  SetSRsrcState(&spb);
		  }
		  dce->dCtlSlotId = vdswitch->csData; // where is that explained ? cscSwitchMode is not in DCDMF3, and you should'nt do that anymore says PDCD...
		  
		   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0021); */
		   /* write_reg(dce, GOBOFB_DEBUG, vdswitch->csMode); */
		   /* write_reg(dce, GOBOFB_DEBUG, vdswitch->csData); */
		  SwapMMUMode ( &busMode );
		  switch (vdswitch->csData) {
		  case firstVidMode: {
			  /* write_reg(dce, GOBOFB_VIDEOCTRL, 0); */
			  write_reg(dce, GOBOFB_HRES_START, 0);
			  write_reg(dce, GOBOFB_VRES_START, 0);
			  write_reg(dce, GOBOFB_HRES_END, __builtin_bswap32(HRES)); // fixme: endianess (along with HW)
			  write_reg(dce, GOBOFB_VRES_END, __builtin_bswap32(VRES)); // fixme: endianess (along with HW)
			  /* write_reg(dce, GOBOFB_VIDEOCTRL, 1); */
		  } break;
		  case secondVidMode: {
			  unsigned int ho = ((HRES - 640) / 2);
			  unsigned int vo = ((VRES - 480) / 2);
			   /* write_reg(dce, GOBOFB_VIDEOCTRL, 0); */
			  write_reg(dce, GOBOFB_HRES_START, __builtin_bswap32(ho));
			  write_reg(dce, GOBOFB_VRES_START, __builtin_bswap32(vo));
			  write_reg(dce, GOBOFB_HRES_END, __builtin_bswap32(ho + 640));
			  write_reg(dce, GOBOFB_VRES_END, __builtin_bswap32(vo + 480));
			  /* write_reg(dce, GOBOFB_VIDEOCTRL, 1); */
		  } break;
		  default:
			  SwapMMUMode ( &busMode );
			  return paramErr;
		  }
		  switch (vdswitch->csMode) {
		  case kDepthMode1:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_8BIT);
			  break;
		  case kDepthMode2:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_4BIT);
			  break;
		  case kDepthMode3:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_2BIT);
			  break;
		  case kDepthMode4:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_1BIT);
			  break;
		  case kDepthMode5:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_24BIT);
			  break;
		  case kDepthMode6:
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_15BIT);
			  break;
		  default:
			  SwapMMUMode ( &busMode );
			  return paramErr;
		  }
		  dStore->curMode = vdswitch->csData;
		  dStore->curDepth = vdswitch->csMode;
		  SwapMMUMode ( &busMode );
		  vdswitch->csBaseAddr = 0;
		  ret = noErr;
	  }
	  break;

  case cscSavePreferredConfiguration: /* 0x10 */
	   // is that ony for PCI drivers?
#if 1
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  switch (vdswitch->csMode) { // checkme: really mode?
		  case firstVidMode:
			  break;
		  case secondVidMode:
			  break;
		   case thirdVidMode:
			   break;
		   case fourthVidMode:
			   break;
		   case fifthVidMode:
			   break;
		   case sixthVidMode:
			   break;
		  default:
			  return paramErr;
		  }
		  switch (vdswitch->csData) { // checkme: really mode?
		  case firstVidMode:
			  break;
		  case secondVidMode:
			  break;
		   case thirdVidMode:
			   break;
		   case fourthVidMode:
			   break;
		   case fifthVidMode:
			   break;
		   case sixthVidMode:
			   break;
		  default:
			  return paramErr;
		  }
		  if (vdswitch->csPage != 0)
			  return paramErr;
		  vdswitch->csBaseAddr = 0;
		  ret = noErr;
	   }
#else
	  ret = controlErr;
#endif
	  break;
	  
  default: /* always return controlErr for unknown csCode */
	  asm volatile(".word 0xfe16\n");
	  ret = controlErr;
	  break;
  }
#endif
  return ret;
}
