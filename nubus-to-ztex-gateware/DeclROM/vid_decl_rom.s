	.include "atrap.inc"
	.include "globals.inc"
	.include "declrom.inc"

	.include "ROMDefs.inc"
	.include "Video.inc"
	.include "DepVideo.inc"

sRsrc_Board = 1 /*  board sResource (>0 & <128) */
sRsrc_VidHiRes = 0x80 /*  functional sResources */

_sRsrcDir:
	OSLstEntry  sRsrc_Board,_sRsrc_Board     /*  board sRsrc List */
    OSLstEntry  sRsrc_VidHiRes,_sRsrc_VidHiRes     /*  video sRsrc List */
	.long EndOfList

_sRsrc_Board:	
    OSLstEntry  sRsrcType,_BoardType       /*  offset to board descriptor */
    OSLstEntry  sRsrcName,_BoardName       /*  offset to name of board */
    DatLstEntry boardId,NuBusFPGAID         /*  board ID # (assigned by DTS) */
    OSLstEntry  primaryInit,_sPInitRec     /*  offset to PrimaryInit exec blk */
    OSLstEntry  vendorInfo,_VendorInfo     /*  offset to vendor info record */
	OSLstEntry  secondaryInit,_sSInitRec  /* offset to SecondaryInit block	 */
	OSLstEntry	sRsrcVidNames, _VModeName
	.long EndOfList

_BoardType:	
    .short catBoard            /*  board sResource */
    .short typeBoard
    .short 0
    .short 0
	
_BoardName: 
    .string "NuBusFPGA Video\0" /*  name of board */
	ALIGN 2

/*  _VidICON ; optional icon, not needed */
/*  _sVidNameDir ; optional name(s), not needed */

_sPInitRec:	
    .long       _EndsPInitRec-_sPInitRec /*  physical block size */
	.include  "NuBusFPGAPrimaryInit.s"			   /*  	the header/code */
	.text	
    ALIGN 2
_EndsPInitRec:

_sSInitRec:	
    .long    _EndsSInitRec-_sSInitRec /* physical block size */
    .include "NuBusFPGASecondaryInit.s"  /* the header/code */
	.text
    ALIGN 2
_EndsSInitRec:
	
	ALIGN 2
_VendorInfo:	
    OSLstEntry vendorId,_VendorId      /*  offset to vendor ID */
    OSLstEntry serialNum,_SerialNum      /*  offset to revision */
    OSLstEntry revLevel,_RevLevel      /*  offset to revision */
    OSLstEntry partNum,_PartNum        /*  offset to part number record */
    OSLstEntry date,_Date              /*  offset to ROM build date */
    .long EndOfList
	
_VendorId:	
            .string        "Romain Dolbeau\0"        /*  vendor ID */
_SerialNum:	
            .string        "0000000001\0"        /*  serial number */
_RevLevel:	
            .string        "NuBusFPGA V1.0\0"        /*  revision level */
_PartNum:	
            .string        "Part Number\0"           /*  part number */
_Date:	
    .string        "&SysDate"              /*  date */

	ALIGN 2
	
_VModeName:	
	OSLstEntry	sRsrc_VidHiRes, _ScreenNameVidHiRes
	DatLstEntry	endOfList,	0	

	ALIGN 2
_ScreenNameVidHiRes:	
	.long		_ScreenNameVidHiResEnd - _ScreenNameVidHiRes
	.word		0
	.string		"That one resolution\0"
_ScreenNameVidHiResEnd:	

	ALIGN 2
_sRsrc_VidHiRes:	
	OSLstEntry  sRsrcType,_VideoType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_VideoName      /*  offset to driver name string */
    OSLstEntry  sRsrcDrvrDir,_VidDrvrDir /* offset to driver directory */
	DatLstEntry  sRsrcFlags,6    /* force 32 bits mode & open */
    DatLstEntry sRsrcHWDevId,1           /*  hardware device ID */
    OSLstEntry  MinorBaseOS,_MinorBase    /*  offset to frame buffer array */
    OSLstEntry  MinorLength,_MinorLength  /*  offset to frame buffer length */
    /* OSLstEntry  sGammaDir,_GammaDirS      /*  directory for 640x480 monitor */
/*  Parameters */
    OSLstEntry  firstVidMode,_HiRes8Modes        /*  offset to 8 Bit Mode parms */
    OSLstEntry  secondVidMode,_HiRes4Modes        /*  offset to 4 Bit Mode parms */
    OSLstEntry  thirdVidMode,_HiRes2Modes        /*  offset to 2 Bit Mode parms */
    OSLstEntry  fourthVidMode,_HiRes1Modes        /*  offset to 1 Bit Mode parms */
    OSLstEntry  fifthVidMode,_HiRes24Modes        /*  offset to 24 Bit Mode parms */
    .long EndOfList               /*  end of list */

	ALIGN 2
_VideoType:	
    .short        catDisplay               /*      <Category> */
    .short        typeVideo                 /*      <Type> */
    .short        drSwApple                /*      <DrvrSw> */
    .short        DrHwNuBusFPGA             /*      <DrvrHw> */
			  
_VideoName:	
    .string        "Video_NuBusFPGA"        /*  video driver name */
_MinorBase:	
    .long        defMinorBase             /*  frame buffer offset */
_MinorLength:	
    .long        defMinorLength           /*  frame buffer length */

	ALIGN 2
_VidDrvrDir:	
    OSLstEntry  sMacOS68020,_DrvrMacOS68020     /* driver directory for Mac OS */
    .long EndOfList 

	ALIGN 2
_DrvrMacOS68020:	
    .long        _End020Drvr-.   /*  physical block size */
    .include     "NuBusFPGADrvr.s"             /*   driver code */
	.text
_End020Drvr:	

/* 	ALIGN 2 */
/* _GammaDirS: */
/*             OSLstEntry  128,_SmallGamma */
/*             .long EndOfList */
/* _SmallGamma: */	
/*             .long        _EndSmallGamma-_SmallGamma */
/*             .short        SGammaResID */
/*             .string        "Small Gamma"                /*  Monitors name */
/*             ALIGN       2 */
/*             .short        0x0000                        /*  gVersion */
/*             .short        DrHwNuBusFPGA                   /*  gType */
/*             .short        0x0000                        /*  gFormulaSize */
/*             .short        0x0001                        /*  gChanCnt */
/*             .short        0x0100                        /*  gDataCnt */
/*             .short        0x0008                        /*  gChanWidth */
/*             .long        0x0005090B,0x0E101315,0x17191B1D,0x1E202224
             .long        0x2527282A,0x2C2D2F30,0x31333436,0x37383A3B
             .long        0x3C3E3F40,0x42434445,0x4748494A,0x4B4D4E4F
             .long        0x50515254,0x55565758,0x595A5B5C,0x5E5F6061
             .long        0x62636465,0x66676869,0x6A6B6C6D,0x6E6F7071
             .long        0x72737475,0x76777879,0x7A7B7C7D,0x7E7F8081
             .long        0x81828384,0x85868788,0x898A8B8C,0x8C8D8E8F
             .long 0x90919293,0x94959596,0x9798999A,0x9B9B9C9D
             .long 0x9E9FA0A1,0xA1A2A3A4,0xA5A6A6A7,0xA8A9AAAB
             .long 0xABACADAE,0xAFB0B0B1,0xB2B3B4B4,0xB5B6B7B8
             .long 0xB8B9BABB,0xBCBCBDBE,0xBFC0C0C1,0xC2C3C3C4
             .long 0xC5C6C7C7,0xC8C9CACA,0xCBCCCDCD,0xCECFD0D0
             .long 0xD1D2D3D3,0xD4D5D6D6,0xD7D8D9D9,0xDADBDCDC
             .long 0xDDDEDFDF,0xE0E1E1E2,0xE3E4E4E5,0xE6E7E7E8
             .long 0xE9B9EAEB,0xECECEDEE,0xEEEFF0F1,0xF1F2F3F3
             .long 0xF4F5F5F6,0xF7F8F8F9,0xFAFAFBFC,0xFCFDFEFF */
/* _EndSmallGamma: */

	ALIGN 2
_HiRes8Modes:	
             OSLstEntry    mVidParams,_HRV8Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages8s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV8Parms:	
             .long          _EndHRV8Parms-_HRV8Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB8s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyIndexed               /*  bmPixelType */
             .word          8                           /*  bmPixelSize */
             .word          1                           /*  bmCmpCount */
             .word          8                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV8Parms:	
	ALIGN 2
_HiRes4Modes:	
             OSLstEntry    mVidParams,_HRV4Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages4s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV4Parms:	
             .long          _EndHRV4Parms-_HRV4Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB4s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyIndexed               /*  bmPixelType */
             .word          4                           /*  bmPixelSize */
             .word          1                           /*  bmCmpCount */
             .word          4                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV4Parms:
	ALIGN 2
_HiRes2Modes:	
             OSLstEntry    mVidParams,_HRV2Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages2s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV2Parms:	
             .long          _EndHRV2Parms-_HRV2Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB2s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyIndexed               /*  bmPixelType */
             .word          2                           /*  bmPixelSize */
             .word          1                           /*  bmCmpCount */
             .word          2                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV2Parms:
	ALIGN 2
_HiRes1Modes:	
             OSLstEntry    mVidParams,_HRV1Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages1s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV1Parms:	
             .long          _EndHRV1Parms-_HRV1Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB1s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyIndexed               /*  bmPixelType */
             .word          1                           /*  bmPixelSize */
             .word          1                           /*  bmCmpCount */
             .word          1                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV1Parms:	
	ALIGN 2
_HiRes24Modes:	
             OSLstEntry    mVidParams,_HRV24Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages24s             /*  number of video pages */
             DatLstEntry   mDevType,directType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV24Parms:	
             .long          _EndHRV24Parms-_HRV24Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB24s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyDirect                /*  bmPixelType */
             .word          32                          /*  bmPixelSize */
             .word          3                           /*  bmCmpCount */
             .word          8                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndHRV24Parms:	

	/* Declaration ROM directory at end */
	ALIGN 2
DeclROMDir:
	OSLstEntry 0, _sRsrcDir
	.long DeclRomEnd-_sRsrcDir /* Length should be 0x824 */
DeclROMCRC:
	.long 0x0 /* TODO: calculate this */
	.byte 1			 /* Revision Level */
	.byte appleFormat			 /* Apple Format */
	.long testPattern	 /* magic TestPattern */
	.byte 0			 /* reserved */
	.byte 0x0F		 /* byte lane marker */
DeclRomEnd:
	.end

