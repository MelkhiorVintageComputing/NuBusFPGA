#include "NuBusFPGADrvr.h"

#if 0
typedef struct AuxDCE {
   Ptr         dCtlDriver;   /* pointer or handle to driver */
   short       dCtlFlags;    /* flags */
   QHdr        dCtlQHdr;     /* I/O queue header */
   long        dCtlPosition; /* current R/W byte position */
   Handle      dCtlStorage;  /* handle to private storage */
   short       dCtlRefNum;   /* driver reference number */
   long        dCtlCurTicks; /* used internally */
   GrafPtr     dCtlWindow;   /* pointer to driverâs window */
   short       dCtlDelay;    /* ticks between periodic actions */
   short       dCtlEMask;    /* desk accessory event mask */
   short       dCtlMenu;     /* desk accessory menu ID */
   char        dCtlSlot;     /* slot */
   char        dCtlSlotId;   /* sResource directory ID */
   long        dCtlDevBase;  /* slot device base address */
   Ptr         dCtlOwner;    /* reserved; must be 0 */
   char        dCtlExtDev;   /* external device ID */
   char        fillByte;      /* reserved */
} AuxDCE;
typedef AuxDCE *AuxDCEPtr, **AuxDCEHandle;
#endif

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
		   dStore->curMode = firstVidMode;
		   dStore->curDepth = kDepthMode1;
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
		   switch (vPInfo->csMode) {
		   case firstVidMode:
			   dStore->curMode = firstVidMode;
			   SwapMMUMode ( &busMode );
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_8BIT);
			   SwapMMUMode ( &busMode );
			   break;
		   case secondVidMode:
			   dStore->curMode = secondVidMode;
			   SwapMMUMode ( &busMode );
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_1BIT);
			   SwapMMUMode ( &busMode );
		   	   break;
		   default:
			   return paramErr;
		   }
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
		   /* FIXME: TODO */
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   if (vPInfo->csPage != 0)
			   return paramErr;

		   SwapMMUMode ( &busMode );

		   switch (dStore->curMode) {
		   case firstVidMode: // 8bpp
			   {
				   /* grey the screen */
				   UInt32 a32 = dce->dCtlDevBase;
				   UInt32 a32_l0, a32_l1;
				   UInt32 a32_4p0, a32_4p1;
				   short j, i;
				   a32_l0 = a32;
				   a32_l1 = a32 + HRES;
				   for (j = 0 ; j < VRES ; j+= 2) {
					   a32_4p0 = a32_l0;
					   a32_4p1 = a32_l1;
					   for (i = 0 ; i < HRES ; i += 4) {
						   *((UInt32*)a32_4p0) = 0xFF00FF00;
						   *((UInt32*)a32_4p1) = 0x00FF00FF;
						   a32_4p0 += 4;
						   a32_4p1 += 4;
					   }
					   a32_l0 += 2*HRES;
					   a32_l1 += 2*HRES;
				   }
			   } break;
		   case secondVidMode: // 1bpp
			   {
				   /* grey the screen */
				   UInt32 a32 = dce->dCtlDevBase;
				   UInt32 a32_l0, a32_l1;
				   UInt32 a32_4p0, a32_4p1;
				   short j, i;
				   a32_l0 = a32;
				   a32_l1 = a32 + HRES/8;
				   for (j = 0 ; j < VRES ; j+= 2) {
					   a32_4p0 = a32_l0;
					   a32_4p1 = a32_l1;
					   for (i = 0 ; i < HRES/8 ; i += 4) {
						   *((UInt32*)a32_4p0) = 0xAAAAAAAA;
						   *((UInt32*)a32_4p1) = 0x55555555;
						   a32_4p0 += 4;
						   a32_4p1 += 4;
					   }
					   a32_l0 += 2*HRES/8;
					   a32_l1 += 2*HRES/8;
				   }
			   } break;
		   }

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
		   switch (vddefm->csID) { // checkme: really mode?
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
		  switch (vdswitch->csData) {
		  case kDepthMode1:
			   SwapMMUMode ( &busMode );
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_8BIT);
			   SwapMMUMode ( &busMode );
			  break;
		  case kDepthMode2:
			   SwapMMUMode ( &busMode );
			   write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_1BIT);
			   SwapMMUMode ( &busMode );
			  break;
		  default:
			  return paramErr;
		  }
		  vdswitch->csBaseAddr = 0;
		  ret = noErr;
	  }
	  break;

  case cscSavePreferredConfiguration: /* 0x10 */
	   // is that ony for PCI drivers?
#if 1
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  switch (vdswitch->csMode) {
		  case firstVidMode:
			  break;
		  case secondVidMode:
			  break;
		  default:
			  return paramErr;
		  }
		  switch (vdswitch->csData) { // checkme: really mode?
		  case firstVidMode:
			  break;
		  case secondVidMode:
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
