	.include "atrap.inc"
	.include "globals.inc"
	.include "declrom.inc"

	.include "ROMDefs.inc"
	.include "Video.inc"
	.include "DepVideo.inc"

sRsrc_Board = 1 /*  board sResource (>0 & <128) */
	.include "VidRomDef.s"
sRsrc_RAMDsk = 0x90 /*  functional sResources */

	.include "VidRomRsrcDir.s"

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

	.include "VidRomName.s" /* contains _VidName */

	.include "VidRomDir.s"

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

	.include "VidRomRes.s"
	
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
	
