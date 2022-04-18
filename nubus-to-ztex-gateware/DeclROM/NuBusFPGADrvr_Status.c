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
   
   write_reg(dce, GOBOFB_DEBUG, 0xBEEF0002);
   write_reg(dce, GOBOFB_DEBUG, pb->csCode);
   
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
		   vPInfo->csMode = dStore->curMode; /* checkme: PCI says depth, 7.5+ doesn't call anyway? */ 
		   vPInfo->csPage = 0;
		   vPInfo->csBaseAddr = 0;
		   ret = noErr;
	   }
	   break;
   case cscGetEntries: /* 3 */
	   /* FIXME: TODO */
		 asm volatile(".word 0xfe16\n");
         ret = noErr;
	   break;
   case cscGetPageCnt: /* 4 == cscGetPages */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   switch (vPInfo->csMode) {
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
		   default:
			   return paramErr;
		   }
		   vPInfo->csPage = 0;
		   ret = noErr;
	   }
		 asm volatile(".word 0xfe16\n");
         ret = noErr;
	   break;
   case cscGetPageBase: /* 5 == cscGetBaseAddr */
	   {
		   VDPageInfo	*vPInfo = (VDPageInfo *)*(long *)pb->csParam;
		   if (vPInfo->csPage != 0)
			   return paramErr;
		   vPInfo->csBaseAddr = 0;
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
		   vddefm->csID = firstVidMode;
		   ret = noErr;
	   }
	   break;

   case cscGetCurMode: /* 0xa */
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  vdswitch->csMode = dStore->curDepth;
		  vdswitch->csData = dStore->curMode;
		  vdswitch->csPage = 0;
		  vdswitch->csBaseAddr = 0;
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
		   vdconn->csConnectFlags = (1<<kTaggingInfoNonStandard) | (1<<kIsMonoDev) | (1<<kAllModesSafe) | (1<<kAllModesValid);
		   vdconn->csDisplayComponent = 0;
		   ret = noErr;
	   }
	   break;

   case cscGetModeTiming: /* 0xd */
	   {
		   VDTimingInfoRec *vdtim = *(VDTimingInfoRec **)(long *)pb->csParam;
		  ret = noErr;
		  if ((vdtim->csTimingMode != firstVidMode) &&
			  (vdtim->csTimingMode != kDisplayModeIDFindFirstResolution) &&
			  (vdtim->csTimingMode != kDisplayModeIDCurrent))
			  return paramErr;
		  vdtim->csTimingFormat = kDeclROMtables;
		  vdtim->csTimingData = 0;
		  vdtim->csTimingFlags = kModeDefault; 
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

   case cscGetPreferredConfiguration: /* 0x10 */
	   {
		  VDSwitchInfoRec	*vdswitch = *(VDSwitchInfoRec **)(long *)pb->csParam;
		  vdswitch->csMode = kDepthMode1; //dStore->curDepth; /* fixme: prefered not current / default */
		  vdswitch->csData = firstVidMode; //dStore->curMode;
		  ret = noErr;
	   }
	   break;

   case cscGetNextResolution: /* 0x11 */
	   {
		  VDResolutionInfoRec	*vdres = *(VDResolutionInfoRec **)(long *)pb->csParam;
		  vdres->csHorizontalPixels = HRES;
		  vdres->csVerticalLines = VRES;
		  vdres->csRefreshRate = 60 << 16; /* Fixed 16+16 */
		  switch (vdres->csPreviousDisplayModeID)
			  {
			  case firstVidMode:
				  vdres->csDisplayModeID = kDisplayModeIDNoMoreResolutions;
				  break;
			  case kDisplayModeIDFindFirstResolution:
				  vdres->csDisplayModeID = firstVidMode;
				  vdres->csMaxDepthMode = kDepthMode5;
				  break;
			  case kDisplayModeIDCurrent:
				  vdres->csDisplayModeID = firstVidMode;
				  vdres->csMaxDepthMode = kDepthMode5;
				  break;
			  default:
				  return paramErr;
			  }
		  ret = noErr;
	   }
	   break;
 
   case cscGetVideoParameters: /* 0x12 */
	   {
		  VDVideoParametersInfoRec	*vdparam = *(VDVideoParametersInfoRec **)(long *)pb->csParam;
		  if ((vdparam->csDisplayModeID != firstVidMode) &&
			  (vdparam->csDisplayModeID != kDisplayModeIDFindFirstResolution) &&
			  (vdparam->csDisplayModeID != kDisplayModeIDCurrent))
			  return paramErr;
		  if ((vdparam->csDepthMode != kDepthMode1) &&
			  (vdparam->csDepthMode != kDepthMode2) &&
			  (vdparam->csDepthMode != kDepthMode3) &&
			  (vdparam->csDepthMode != kDepthMode4) &&
			  (vdparam->csDepthMode != kDepthMode5)) 
			  return paramErr;
		  VPBlock* vpblock = vdparam->csVPBlockPtr;
		  /* basically the same as the EBVParms ? */
		  vdparam->csPageCount = 0;
		  vpblock->vpBaseOffset = 0;
		  vpblock->vpBounds.left = 0;
		  vpblock->vpBounds.top = 0;
		  vpblock->vpBounds.right = HRES;
		  vpblock->vpBounds.bottom = VRES;
		  vpblock->vpVersion = 0;
		  vpblock->vpPackType = 0;
		  vpblock->vpPackSize = 0;
		  vpblock->vpHRes = 0x480000;
		  vpblock->vpVRes = 0x480000;
		  vpblock->vpPixelType = chunky; // checkme?
		  if (vdparam->csDepthMode == kDepthMode1) {
			  vpblock->vpRowBytes = HRES;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 8;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 8;
		  } else if (vdparam->csDepthMode == kDepthMode2) {
			  vpblock->vpRowBytes = HRES/2;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 4;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 4;
		  } else if (vdparam->csDepthMode == kDepthMode3) {
			  vpblock->vpRowBytes = HRES/4;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 2;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 2;
		  } else if (vdparam->csDepthMode == kDepthMode4) {
			  vpblock->vpRowBytes = HRES/8;
			  vdparam->csDeviceType = clutType;
			  vpblock->vpPixelSize = 1;
			  vpblock->vpCmpCount = 1;
			  vpblock->vpCmpSize = 1;
		  } else if (vdparam->csDepthMode == kDepthMode5) {
			  vpblock->vpRowBytes = HRES*4;
			  vdparam->csDeviceType = directType;
			  vpblock->vpPixelSize = 32;
			  vpblock->vpCmpCount = 3;
			  vpblock->vpCmpSize = 8;
		  }
		  vpblock->vpPlaneBytes = 0;
		  ret = noErr;
	   }
	   break;

	   /* 0x13 */ /* nothing */

   case cscGetGammaInfoList: /* 0x14 */
	   ret = statusErr;
	   break;

   case cscRetrieveGammaTable: /* 0x17 */
	   asm volatile(".word 0xfe16\n");
	   ret = statusErr;
	   break;

   case cscGetConvolution: /* 0x18 */
	   ret = statusErr;
	   break;	   

   case cscGetMultiConnect: /* 0x1c */
	   ret = statusErr;
	   break;
	   
   default: /* always return statusErr for unknown csCode */
	   asm volatile(".word 0xfe16\n");
	   ret = statusErr;
	   break;
   }
#endif
   return ret;
}
