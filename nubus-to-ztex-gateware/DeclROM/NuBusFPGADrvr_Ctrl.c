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
	   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0005); */
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

   write_reg(dce, GOBOFB_DEBUG, 0xBEEF0001);
   write_reg(dce, GOBOFB_DEBUG, pb->csCode);
   
#if 1
  switch (pb->csCode)
  {
  case -1:
	  asm volatile(".word 0xfe16\n");
  	  break;
  case cscReset:
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   dStore->curMode = nativeVidMode;
		   dStore->curDepth = kDepthMode1; /* 8-bit */
		   vPInfo->csMode = nativeVidMode;
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

		   ret = reconfHW(dce, dStore->curMode, vPInfo->csMode, vPInfo->csPage);
   
		  if (ret == noErr)
			  vPInfo->csBaseAddr = (void*)(vPInfo->csPage * 1024 * 1024 * 4);
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
		   UInt32 a32 = dce->dCtlDevBase;
		   UInt32 a32_l0, a32_l1;
		   UInt32 a32_4p0, a32_4p1;
		   const uint32_t wb = dStore->hres[0] >> idx;
		   unsigned short j, i;
		   short npage = (vPInfo->csMode == kDepthMode5) ? 1 : 2;
		   if (vPInfo->csPage >= npage)
			   return paramErr;

		   a32 += vPInfo->csPage * 1024 * 1024 * 4; /* fixme */
		   
		   SwapMMUMode ( &busMode );
#if 0
		   if ((dStore->curMode != kDepthMode5) && (dStore->curMode != kDepthMode6)) {
			   /* grey the screen */
			   a32_l0 = a32;
			   a32_l1 = a32 + wb;
			   for (j = 0 ; j < dStore->vres[0] ; j+= 2) {
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
			   a32_l1 = a32 + dStore->hres[0]*4;
			   for (j = 0 ; j < dStore->vres[0] ; j+= 2) {
				   a32_4p0 = a32_l0;
				   a32_4p1 = a32_l1;
				   for (i = 0 ; i < dStore->hres[0] ; i ++ ) {
					   *((UInt32*)a32_4p0) = (i&0xFF);//(i&0xFF) | (i&0xFF)<<8 | (i&0xff)<<24;
					   *((UInt32*)a32_4p1) = (i&0xFF)<<16;//(i&0xFF) | (i&0xFF)<<8 | (i&0xff)<<24;
					   a32_4p0 += 4;
					   a32_4p1 += 4;
				   }
				   a32_l0 += 2*dStore->hres[0]*4;
				   a32_l1 += 2*dStore->hres[0]*4;
			   }
		   }
#else

#define WAIT_FOR_HW_LE(accel_le)						\
	while (accel_le->reg_status & (1<<WORK_IN_PROGRESS_BIT))
		   
		   const UInt32 fgcolor = 0; // FIXME: per-depth?
		   struct goblin_accel_regs* accel_le = (struct goblin_accel_regs*)(dce->dCtlDevBase+GOBOFB_ACCEL_LE);
		   WAIT_FOR_HW_LE(accel_le);
		   accel_le->reg_width = dStore->hres[dStore->curMode - nativeVidMode]; // pixels
		   accel_le->reg_height = dStore->vres[dStore->curMode - nativeVidMode];
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
	  { /* fixme: NVRAM */
		   VDDefMode	*vddefm = (VDDefMode *)*(long *)pb->csParam;

		   ret = updatePRAM(dce, vddefm->csID, dStore->curDepth, 0);
	  }
	  break;

  case cscSwitchMode: /* 0xa */
	  {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;

		  ret = reconfHW(dce, vdswitch->csData, vdswitch->csMode, vdswitch->csPage);
   
		  if (ret == noErr)
			  vdswitch->csBaseAddr = (void*)(vdswitch->csPage * 1024 * 1024 * 4);
	  }
	  break;

  case cscSavePreferredConfiguration: /* 0x10 */
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;

		  ret = updatePRAM(dce, vdswitch->csData, vdswitch->csMode, 0);
	   }
	  break;
	  
  default: /* always return controlErr for unknown csCode */
	  asm volatile(".word 0xfe16\n");
	  ret = controlErr;
	  break;
  }
#endif
  return ret;
}

OSErr reconfHW(AuxDCEPtr dce, unsigned char mode, unsigned char depth, unsigned short page) {
	NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
	NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
	const short npage = (depth == kDepthMode5) ? 1 : 2;
	OSErr err = noErr;
	char busMode = 1;

	write_reg(dce, GOBOFB_DEBUG, 0xBEEF0031);
	write_reg(dce, GOBOFB_DEBUG, mode);
	write_reg(dce, GOBOFB_DEBUG, depth);
	write_reg(dce, GOBOFB_DEBUG, page);
	
	if ((mode == dStore->curMode) &&
		(depth == dStore->curDepth) &&
		(page == dStore->curPage)) {
		return noErr;
	}
		  
	if (page >= npage)
		return paramErr;

	if ((mode < nativeVidMode) ||
		(mode > dStore->maxMode))
		return paramErr;
		  
	switch (depth) {
	case kDepthMode1:
		break;
	case kDepthMode2:
		break;
	case kDepthMode3:
		break;
	case kDepthMode4:
		break;
	case kDepthMode5:
		break;
	case kDepthMode6:
		break;
	default:
		return paramErr;
	}
	
	SwapMMUMode ( &busMode );
	if (mode != dStore->curMode) {
		unsigned short i;
		for (i = nativeVidMode ; i <= dStore->maxMode ; i++) {
			// disable spurious resources, enable only the right one
			SpBlock spb;
			spb.spParamData = (i != mode ? 1 : 0); /* disable/enable */
			spb.spSlot = dStore->slot;
			spb.spID = i;
			spb.spExtDev = 0;
			SetSRsrcState(&spb);
		}
		dce->dCtlSlotId = mode; // where is that explained ? cscSwitchMode is not in DCDMF3, and you should'nt do that anymore says PDCD...
		
		UInt8 id = mode - nativeVidMode;
		unsigned int ho = ((dStore->hres[0] - dStore->hres[id]) / 2);
		unsigned int vo = ((dStore->vres[0] - dStore->vres[id]) / 2);
		/* write_reg(dce, GOBOFB_VIDEOCTRL, 0); */
		write_reg(dce, GOBOFB_HRES_START, __builtin_bswap32(ho));
		write_reg(dce, GOBOFB_VRES_START, __builtin_bswap32(vo));
		write_reg(dce, GOBOFB_HRES_END, __builtin_bswap32(ho + dStore->hres[id]));
		write_reg(dce, GOBOFB_VRES_END, __builtin_bswap32(vo + dStore->vres[id]));
		/* write_reg(dce, GOBOFB_VIDEOCTRL, 1); */
	}
	if (depth != dStore->curDepth) {
		switch (depth) {
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
	}
	dStore->curMode = mode;
	dStore->curDepth = depth;
	dStore->curPage = page; /* FIXME: HW */
		  
	SwapMMUMode ( &busMode );

	return err;
}

OSErr updatePRAM(AuxDCEPtr dce, unsigned char mode, unsigned char depth, unsigned short page) {
	NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
	NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
	const short npage = (depth == kDepthMode5) ? 1 : 2;
	SpBlock spb;
	NuBusFPGAPramRecord pram;
	OSErr err;
		  
	if (page >= npage)
		return paramErr;

	if ((mode < nativeVidMode) ||
		(mode > dStore->maxMode))
		return paramErr;
		  
	switch (depth) {
	case kDepthMode1:
		break;
	case kDepthMode2:
		break;
	case kDepthMode3:
		break;
	case kDepthMode4:
		break;
	case kDepthMode5:
		break;
	case kDepthMode6:
		break;
	default:
		return paramErr;
	}

	spb.spSlot = dce->dCtlSlot;
	spb.spResult = (UInt32)&pram;
	err = SReadPRAMRec(&spb);
	if (err == noErr) {
		pram.mode = mode;
		pram.depth = depth;
		pram.page = page;
		spb.spSlot = dce->dCtlSlot;
		spb.spsPointer = &pram;
		err = SPutPRAMRec(&spb);
	}
	return err;
}
