	.include "atrap.inc"
	.include "globals.inc"
	.include "declrom.inc"

	.include "ROMDefs.inc"
	.include "Video.inc"
	.include "DepVideo.inc"

sRsrc_Board = 1 /*  board sResource (>0 & <128) */
sRsrc_GoboFB = 0x80 /*  functional sResources */
sRsrc_GoboFB_13 = 0x81 /*  functional sResources */
sRsrc_RAMDsk = 0x90 /*  functional sResources */
sRsrc_GoboFB_HiRes = 0x80 /*  functional sResources */

_sRsrcDir:
	OSLstEntry  sRsrc_Board,_sRsrc_Board       /*  board sRsrc List */
    OSLstEntry  sRsrc_GoboFB,_sRsrc_GoboFB     /*  video sRsrc List */
    OSLstEntry  sRsrc_GoboFB_13,_sRsrc_GoboFB_13     /*  video sRsrc List */
/*    OSLstEntry  sRsrc_RAMDsk,_sRsrc_RAMDsk     /*  video sRsrc List */
	.long EndOfList

_sRsrc_Board:	
    OSLstEntry  sRsrcType,_BoardType       /*  offset to board descriptor */
    OSLstEntry  sRsrcName,_BoardName       /*  offset to name of board */
    DatLstEntry boardId,NuBusFPGAID         /*  board ID # (assigned by DTS) */
    OSLstEntry  primaryInit,_sPInitRec     /*  offset to PrimaryInit exec blk */
    OSLstEntry  vendorInfo,_VendorInfo     /*  offset to vendor info record */
	OSLstEntry  secondaryInit,_sSInitRec  /* offset to SecondaryInit block	 */
	OSLstEntry	sRsrcVidNames, _VModeName /* video name directory */
	.long EndOfList

_BoardType:	
    .short catBoard            /*  board sResource */
    .short typeBoard
    .short 0
    .short 0
	
_BoardName: 
    .string "NuBusFPGA GoboFB\0" /*  name of board */
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
	OSLstEntry	sRsrc_GoboFB, _ScreenNameGoboFBHiRes
	OSLstEntry	sRsrc_GoboFB_13, _ScreenNameGoboFB13
	DatLstEntry	endOfList,	0

	ALIGN 2
_ScreenNameGoboFBHiRes:	
	.long		_ScreenNameGoboFBHiResEnd - _ScreenNameGoboFBHiRes
	.word		0
	.string		"GoblinFB Native\0"
_ScreenNameGoboFBHiResEnd:
	
	ALIGN 2
_ScreenNameGoboFB13:	
	.long		_ScreenNameGoboFB13End - _ScreenNameGoboFB13
	.word		0
	.string		"GoblinFB 640x480WB\0"
_ScreenNameGoboFB13End:

	ALIGN 2
_sRsrc_GoboFB:	
	OSLstEntry  sRsrcType,_GoboFBType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_GoboFBName      /*  offset to driver name string */
    OSLstEntry  sRsrcDrvrDir,_GoboFBDrvrDir /* offset to driver directory */
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
    OSLstEntry  fifthVidMode,_HiRes24Modes        /*  offset to 24/32 Bit Mode parms */
    OSLstEntry  sixthVidMode,_HiRes15Modes        /*  offset to 15/16 Bit Mode parms */
    .long EndOfList               /*  end of list */

	ALIGN 2
_sRsrc_GoboFB_13:	
	OSLstEntry  sRsrcType,_GoboFBType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_GoboFBName      /*  offset to driver name string */
    OSLstEntry  sRsrcDrvrDir,_GoboFBDrvrDir /* offset to driver directory */
	DatLstEntry  sRsrcFlags,6    /* force 32 bits mode & open */
    DatLstEntry sRsrcHWDevId,1           /*  hardware device ID */
    OSLstEntry  MinorBaseOS,_MinorBase    /*  offset to frame buffer array */
    OSLstEntry  MinorLength,_MinorLength  /*  offset to frame buffer length */
    /* OSLstEntry  sGammaDir,_GammaDirS      /*  directory for 640x480 monitor */
/*  Parameters */
    OSLstEntry  firstVidMode,_M13_8Modes        /*  offset to 8 Bit Mode parms */
    OSLstEntry  secondVidMode,_M13_4Modes        /*  offset to 4 Bit Mode parms */
    OSLstEntry  thirdVidMode,_M13_2Modes        /*  offset to 2 Bit Mode parms */
    OSLstEntry  fourthVidMode,_M13_1Modes        /*  offset to 1 Bit Mode parms */
    OSLstEntry  fifthVidMode,_M13_24Modes        /*  offset to 24/32 Bit Mode parms */
    OSLstEntry  sixthVidMode,_M13_15Modes        /*  offset to 15/16 Bit Mode parms */
    .long EndOfList               /*  end of list */


	ALIGN 2
_GoboFBType:	
    .short        catDisplay               /*      <Category> */
    .short        typeVideo                 /*      <Type> */
    .short        drSwApple                /*      <DrvrSw> */
    .short        DrHwNuBusFPGA             /*      <DrvrHw> */
			  
_GoboFBName:	
    .string        "GoboFB_NuBusFPGA"        /*  video driver name */
	
_MinorBase:	
    .long        defMinorBase             /*  frame buffer offset */
_MinorLength:	
    .long        defMinorLength           /*  frame buffer length */

	ALIGN 2
_GoboFBDrvrDir:	
    OSLstEntry  sMacOS68020,_GoboFBDrvrMacOS68020     /* driver directory for Mac OS */
    .long EndOfList 

	ALIGN 2
_GoboFBDrvrMacOS68020:	
    .long        _GoboFBEnd020Drvr-.   /*  physical block size */
    .include     "NuBusFPGADrvr.s"             /*   driver code */
	.text
_GoboFBEnd020Drvr:

	.include "vid_decl_rom_hires.s"
	
	.include "vid_decl_rom_13.s"
	
	ALIGN 2
_sRsrc_RAMDsk:	
	OSLstEntry  sRsrcType,_RAMDskType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_RAMDskName      /*  offset to driver name string */
    OSLstEntry  sRsrcDrvrDir,_RAMDskDrvrDir /* offset to driver directory */
	DatLstEntry  sRsrcFlags,6    /* force 32 bits mode & open */
    DatLstEntry sRsrcHWDevId,2           /*  hardware device ID */
    .long EndOfList               /*  end of list */

	ALIGN 2
_RAMDskType:	
    .short        catProto               /*      <Category> */
    .short        typeDrive /* custom */                 /*      <Type> */
    .short        drSwApple                /*      <DrvrSw> */
    .short        DrHwNuBusFPGADsk             /*      <DrvrHw> */
			  
_RAMDskName:	
    .string        "RAMDsk_NuBusFPGA"        /*  video driver name */
	
	ALIGN 2
_RAMDskDrvrDir:	
    OSLstEntry  sMacOS68020,_RAMDskDrvrMacOS68020     /* driver directory for Mac OS */
    .long EndOfList 

	ALIGN 2
_RAMDskDrvrMacOS68020:	
    .long        _RAMDskEnd020Drvr-.   /*  physical block size */
    .include     "NuBusFPGARAMDskDrvr.s"             /*   driver code */
	.text
_RAMDskEnd020Drvr:
	
