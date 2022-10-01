#include "NuBusFPGADrvr.h"

/*
  7.1:
      2 Debug: 0x00000009
      1 �Debug: 0x00000009


  7.5.3:
      6 Debug: 0x00000008
    112 Debug: 0x0000000a
     32 Debug: 0x0000000c
     14 Debug: 0x0000000d
      3 Debug: 0x0000000e
      4 Debug: 0x00000010
      2 Debug: 0x00000011
     78 Debug: 0x00000012
      1 Debug: 0x00000014
      1 �Debug: 0x0000000a

  8.1:
      9 Debug: 0x00000008
    273 Debug: 0x0000000a
    156 Debug: 0x0000000c
     16 Debug: 0x0000000d
      3 Debug: 0x00000010
      3 Debug: 0x00000011
    157 Debug: 0x00000012
      1 Debug: 0x00000014
      2 Debug: 0x00000018
     10 Debug: 0x0000001c
      1 �Debug: 0x0000000c
*/


OSErr cNuBusFPGAStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
   NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
   NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
   short ret = -1;
   
   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0002); */
   /* write_reg(dce, GOBOFB_DEBUG, pb->csCode); */
   
#if 1
   switch (pb->csCode)
   {
   case -1:
		 asm volatile(".word 0xfe16\n");
   	   break;
   case 0:
	   ret = statusErr;
	   break;
   /* case 1: */
   /* 	   break; */
   case cscGetMode: /* 2 */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   vPInfo->csMode = dStore->curDepth; /* checkme: PCI says depth, 7.5+ doesn't call anyway? */ 
		   vPInfo->csPage = dStore->curPage;
		   vPInfo->csBaseAddr = dStore->curPage * 1024 * 1024 * 4; /* fixme */
		   ret = noErr;
	   }
	   break;
   case cscGetEntries: /* 3 */
	   /* FIXME: TODO */
	   /* never called in >= 7.1 ? */
		 asm volatile(".word 0xfe16\n");
         ret = noErr;
	   break;
   case cscGetPageCnt: /* 4 == cscGetPages */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		  if ((vPInfo->csMode != kDepthMode1) &&
			  (vPInfo->csMode != kDepthMode2) &&
			  (vPInfo->csMode != kDepthMode3) &&
			  (vPInfo->csMode != kDepthMode4) &&
			  (vPInfo->csMode != kDepthMode5) &&
			  (vPInfo->csMode != kDepthMode6)) 
			  return paramErr;
		  vPInfo->csPage = (vPInfo->csMode == kDepthMode5) ? 1 : 2;
		  ret = noErr;
	   }
	   break;
   case cscGetPageBase: /* 5 == cscGetBaseAddr */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		  if ((vPInfo->csMode != kDepthMode1) &&
			  (vPInfo->csMode != kDepthMode2) &&
			  (vPInfo->csMode != kDepthMode3) &&
			  (vPInfo->csMode != kDepthMode4) &&
			  (vPInfo->csMode != kDepthMode5) &&
			  (vPInfo->csMode != kDepthMode6)) 
			  return paramErr;
		   short npage = (vPInfo->csMode == kDepthMode5) ? 1 : 2;
		   if (vPInfo->csPage >= npage)
			   return paramErr;
		   vPInfo->csBaseAddr = vPInfo->csPage * 1024 * 1024 * 4; /* fixme for > 2 pages ? */
		   ret = noErr;
	   }
		 asm volatile(".word 0xfe16\n");
         ret = noErr;
	   break;
   case cscGetGray: /* 6 */
	   {
		   VDGrayRecord	*vGInfo = (VDGrayRecord *)*(long *)pb->csParam;
		   vGInfo->csMode = dStore->gray;
		   ret = noErr;
	   }
	   asm volatile(".word 0xfe16\n");
	   break;
   case cscGetInterrupt: /* 7 */
		 asm volatile(".word 0xfe16\n");
	   {
		   VDFlagRecord	*vdflag = (VDFlagRecord *)*(long *)pb->csParam;
		   vdflag->csMode = 1 - dStore->irqen;
		   ret = noErr;
	   }
	   break;
   case cscGetGamma: /* 8 */
	   {
		   VDGammaRecord	*vdgamma = (VDGammaRecord *)*(long *)pb->csParam;
		   vdgamma->csGTable = (Ptr)&dStore->gamma;
		   ret = noErr;
	   }
	   break;
   case cscGetDefaultMode: /* 9 */
	   { /* obsolete in PCI, not called >= 7.5 */
		   VDDefMode	*vddefm = (VDDefMode *)*(long *)pb->csParam;
		   SpBlock spb;
		   NuBusFPGAPramRecord pram;
		   OSErr err;
		   spb.spSlot = dce->dCtlSlot;
		   spb.spResult = (UInt32)&pram;
		   ret = SReadPRAMRec(&spb);
		   if (ret == noErr) {
			   vddefm->csID = pram.mode;
		   }
	   }
	   break;

   case cscGetCurMode: /* 0xa */
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0022); */
		  /* write_reg(dce, GOBOFB_DEBUG, (unsigned int)dStore->curDepth); */
		  /* write_reg(dce, GOBOFB_DEBUG, (unsigned int)dStore->curMode); */
		  vdswitch->csMode = dStore->curDepth;
		  vdswitch->csData = dStore->curMode;
		  vdswitch->csPage = dStore->curPage;
		  vdswitch->csBaseAddr = dStore->curPage * 1024 * 1024 * 4; /* fixme */
		  ret = noErr;
	   }
	   break;

   case cscGetSync: /* 0xb */
	   asm volatile(".word 0xfe16\n");
	   ret = statusErr;
	   break;

   case cscGetConnection: /* 0xc */
	   {
		   VDDisplayConnectInfoRec *vdconn = *(VDDisplayConnectInfoRec **)(long *)pb->csParam;
		   vdconn->csDisplayType = kGenericLCD;
		   vdconn->csConnectTaggedType = 0;
		   vdconn->csConnectTaggedData = 0;
		   vdconn->csConnectFlags = (1<<kTaggingInfoNonStandard) | (1<<kAllModesSafe) | (1<<kAllModesValid);
		   vdconn->csDisplayComponent = 0;
		   ret = noErr;
	   }
	   break;

   case cscGetModeTiming: /* 0xd */
	   {
		   VDTimingInfoRec *vdtim = *(VDTimingInfoRec **)(long *)pb->csParam;
		   if (((((UInt8)vdtim->csTimingMode) < nativeVidMode) ||
				(((UInt8)vdtim->csTimingMode) > dStore->maxMode)) &&
			   (vdtim->csTimingMode != kDisplayModeIDFindFirstResolution) &&
			   (vdtim->csTimingMode != kDisplayModeIDCurrent))
			   return paramErr;
		  unsigned int mode = vdtim->csTimingMode;
		  if (mode == kDisplayModeIDFindFirstResolution)
			  mode = nativeVidMode;
		  if (mode == kDisplayModeIDCurrent)
			  mode = dStore->curMode;
		  
		  switch (mode) {
		  case nativeVidMode:
			  vdtim->csTimingFormat = kDeclROMtables;
			  vdtim->csTimingData = 0;
			  vdtim->csTimingFlags = 1<<kModeValid | 1<<kModeSafe | 1<<kModeDefault;
			  break;
		  default:
			  vdtim->csTimingFormat = kDeclROMtables;//kDetailedTimingFormat;
			  vdtim->csTimingData = 0;
			  vdtim->csTimingFlags = 1<<kModeValid | 1<<kModeSafe;
			  break;
		  }
		  ret = noErr;
	   }
	   break;

   case cscGetModeBaseAddress: /* 0xe */
	   /* undocumented ??? */
	   {
		  VDBaseAddressInfoRec	*vdbase = *(VDBaseAddressInfoRec **)(long *)pb->csParam;
		  vdbase->csDevBase = 0;
		  ret = noErr;
	   }
	   ret = noErr;
	   break;

	   /* cscGetScanProc */ /* 0xf*/ /* undocumented ? could be called according to #mac68k */

   case cscGetPreferredConfiguration: /* 0x10 */
	   { /* fixme: NVRAM */
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  vdswitch->csMode = kDepthMode1; //dStore->curDepth; /* fixme: prefered not current / default */
		  vdswitch->csData = nativeVidMode; //dStore->curMode;
		  ret = noErr;
		   SpBlock spb;
		   NuBusFPGAPramRecord pram;
		   OSErr err;
		   spb.spSlot = dce->dCtlSlot;
		   spb.spResult = (UInt32)&pram;
		   ret = SReadPRAMRec(&spb);
		   if (ret == noErr) {
			   vdswitch->csMode = pram.depth;
			   vdswitch->csData = pram.mode;
		   }
	   }
	   break;

   case cscGetNextResolution: /* 0x11 */
	   {
		  VDResolutionInfoRec	*vdres = *(VDResolutionInfoRec **)(long *)pb->csParam;
		  switch (vdres->csPreviousDisplayModeID)
			  {
			  default:
				  if ((((UInt8)vdres->csPreviousDisplayModeID) < nativeVidMode) ||
					  (((UInt8)vdres->csPreviousDisplayModeID) > dStore->maxMode))
					  return paramErr;
				  if (((UInt8)vdres->csPreviousDisplayModeID) == dStore->maxMode)
					  vdres->csDisplayModeID = kDisplayModeIDNoMoreResolutions;
				  else
					  vdres->csDisplayModeID = ((UInt8)vdres->csPreviousDisplayModeID) + 1;
				  vdres->csHorizontalPixels = dStore->hres[((UInt8)vdres->csDisplayModeID) - nativeVidMode];
				  vdres->csVerticalLines = dStore->vres[((UInt8)vdres->csDisplayModeID) - nativeVidMode];
				  vdres->csRefreshRate = 60 << 16; /* Fixed(Point) 16+16 */
				  vdres->csMaxDepthMode = kDepthMode6;
				  break;
			  case kDisplayModeIDFindFirstResolution:
				  vdres->csDisplayModeID = nativeVidMode;
				  vdres->csHorizontalPixels = dStore->hres[0];
				  vdres->csVerticalLines = dStore->vres[0];
				  vdres->csRefreshRate = 60 << 16; /* Fixed(Point) 16+16 */
				  vdres->csMaxDepthMode = kDepthMode6;
				  break;
			  case kDisplayModeIDCurrent:
				  vdres->csDisplayModeID = dStore->curMode;
				  vdres->csHorizontalPixels = dStore->hres[dStore->curMode - nativeVidMode];
				  vdres->csVerticalLines = dStore->vres[dStore->curMode - nativeVidMode];
				  vdres->csRefreshRate = 60 << 16; /* Fixed(Point) 16+16 */
				  vdres->csMaxDepthMode = kDepthMode6;
				  break;
			  }
		  ret = noErr;
	   }
	   break;
 
   case cscGetVideoParameters: /* 0x12 */
	   {
		  VDVideoParametersInfoRec	*vdparam = *(VDVideoParametersInfoRec **)(long *)pb->csParam;
		  if (((((UInt8)vdparam->csDisplayModeID) < nativeVidMode) ||
			   (((UInt8)vdparam->csDisplayModeID) > dStore->maxMode)) &&
			  (vdparam->csDisplayModeID != kDisplayModeIDFindFirstResolution) &&
			  (vdparam->csDisplayModeID != kDisplayModeIDCurrent))
			  return paramErr;
		  if ((vdparam->csDepthMode != kDepthMode1) &&
			  (vdparam->csDepthMode != kDepthMode2) &&
			  (vdparam->csDepthMode != kDepthMode3) &&
			  (vdparam->csDepthMode != kDepthMode4) &&
			  (vdparam->csDepthMode != kDepthMode5) &&
			  (vdparam->csDepthMode != kDepthMode6)) 
			  return paramErr;
		  /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0022); */
		  /* write_reg(dce, GOBOFB_DEBUG, (unsigned int)vdparam->csDisplayModeID); */
		  /* write_reg(dce, GOBOFB_DEBUG, (unsigned int)vdparam->csDepthMode); */
		  VPBlock* vpblock = vdparam->csVPBlockPtr;
		  unsigned char mode = vdparam->csDisplayModeID;
		  if (mode == kDisplayModeIDFindFirstResolution)
			  mode = nativeVidMode;
		  if (mode == kDisplayModeIDCurrent)
			  mode = dStore->curMode;
		  /* basically the same as the EBVParms ? */
		  vdparam->csPageCount = (vdparam->csDepthMode == kDepthMode5) ? 1 : 2;
		  vpblock->vpBaseOffset = 0;
		  vpblock->vpBounds.left = 0;
		  vpblock->vpBounds.top = 0;
		  vpblock->vpBounds.right = dStore->hres[mode - nativeVidMode];
		  vpblock->vpBounds.bottom = dStore->vres[mode - nativeVidMode];
		  vpblock->vpVersion = 0;
		  vpblock->vpPackType = 0;
		  vpblock->vpPackSize = 0;
		  vpblock->vpHRes = 0x480000;
		  vpblock->vpVRes = 0x480000;
		  vpblock->vpPixelType = chunky; // checkme?
		  if (vdparam->csDepthMode == kDepthMode1) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 8;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 8;
		  } else if (vdparam->csDepthMode == kDepthMode2) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right/2;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 4;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 4;
		  } else if (vdparam->csDepthMode == kDepthMode3) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right/4;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 2;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 2;
		  } else if (vdparam->csDepthMode == kDepthMode4) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right/8;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 1;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 1;
		  } else if (vdparam->csDepthMode == kDepthMode5) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right*4;
			  vdparam->csDeviceType = directType;
			  vpblock->vpPixelSize = 32;
			  vpblock->vpCmpCount = 3;
			  vpblock->vpCmpSize = 8;
		  } else if (vdparam->csDepthMode == kDepthMode6) {
			  vpblock->vpRowBytes = vpblock->vpBounds.right*2;
			  vdparam->csDeviceType = directType;
			  vpblock->vpPixelSize = 16;
			  vpblock->vpCmpCount = 3;
			  vpblock->vpCmpSize = 5;
		  }
		  vpblock->vpPlaneBytes = 0;
		  ret = noErr;
	   }
	   break;

	   /* 0x13 */ /* nothing */

   case cscGetGammaInfoList: /* 0x14 */
	   ret = statusErr;
	   break;

   case cscRetrieveGammaTable: /* 0x15 */
	   asm volatile(".word 0xfe16\n");
	   ret = statusErr;
	   break;

	   /* cscSupportsHardwareCursor */ /* 0x16 */ /* never called, unfortunately */

	   /* cscGetHardwareCursorDrawState */ /* 0x17 */ /* never called, unfortunately */

   case cscGetConvolution: /* 0x18 */
	   ret = statusErr;
	   break;

	   /* cscGetPowerState */ /* 0x19 */
	   /* cscPrivateStatusCall */ /* 0x1a */
	   /* cscGetDDCBlock */ /* 0x1b */

   case cscGetMultiConnect: /* 0x1c */
	   ret = statusErr;
	   break;

	   /* cscGetClutBehavior */ /* 0x1d */
	   /* cscGetTimingRanges */ /* 0x1e */
	   /* cscGetDetailedTiming */ /* 0x1f */
	   /* cscGetCommunicationInfo */ /* 0x20 */
	   
   default: /* always return statusErr for unknown csCode */
	   asm volatile(".word 0xfe16\n");
	   ret = statusErr;
	   break;
   }
#endif
   return ret;
}
