	.include "atrap.inc"
	.include "globals.inc"
	.include "declrom.inc"

	.include "ROMDefs.inc"
	.include "Video.inc"
	.include "DepVideo.inc"

sRsrc_Board = 1 /*  board sResource (>0 & <128) */
	.include "VidRomDef.s"
sRsrc_RAMDsk = 0x90 /*  functional sResources */
sRsrc_HDMIAudio = 0xA0 /*  functional sResources */
	
    .global DeclROMDir

    .section .text.begin

	.include "VidRomRsrcDir.s"

    .global _sRsrc_Board
_sRsrc_Board:	
    OSLstEntry  sRsrcType,_BoardType       /*  offset to board descriptor */
    OSLstEntry  sRsrcName,_BoardName       /*  offset to name of board */
    DatLstEntry boardId,NuBusFPGAID         /*  board ID # (assigned by DTS) */
    /* OSLstEntry  primaryInit,_sPInitRec */    /*  offset to PrimaryInit exec blk */
	.long entry_sPInitRec
    OSLstEntry  vendorInfo,_VendorInfo     /*  offset to vendor info record */
	/* OSLstEntry  secondaryInit,_sSInitRec */  /* offset to SecondaryInit block	 */
	.long entry_sSInitRec
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

	.section .text.primary_init
/* _sPInitRec: */
    /* .long       _EndsPInitRec-_sPInitRec */ /*  physical block size */
	.long size_sPInitRec
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	Primary-.					/* Offset to C code. */
    ALIGN 2
/* _EndsPInitRec: */

	.section .text.secondary_init
/* _sSInitRec: */
    /* .long    _EndsSInitRec-_sSInitRec */ /* physical block size */
	.long size_sSInitRec
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	Secondary-.					/* Offset to C code. */
    ALIGN 2
/* _EndsSInitRec: */

    .section .text.begin
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
	.section .text.begin
	.global _GoboFBDrvrDir
_GoboFBDrvrDir:	
    /* OSLstEntry  sMacOS68020,_GoboFBDrvrMacOS68020  */   /* driver directory for Mac OS */
	.long entry_GoboFBDrvrMacOS68020
    .long EndOfList 

	ALIGN 2
	.section .text.fbdriver_init
/* _GoboFBDrvrMacOS68020: */ /* supplied by linker script */
    .long        _GoboFBEnd020Drvr-.   /*  physical block size */
    .include     "NuBusFPGADrvr.s"             /*   driver code */
/* _GoboFBEnd020Drvr: */ /* supplied by linker script */
	
	.section .text.begin
	.include "VidRomRes.s"
	
	.section .text.begin
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
	.section .text.begin
	.global _RAMDskDrvrDir
_RAMDskDrvrDir:	
    /* OSLstEntry  sMacOS68020,_RAMDskDrvrMacOS68020 */    /* driver directory for Mac OS */
	.long entry_RAMDskDrvrMacOS68020
    .long EndOfList 

	ALIGN 2
	.section .text.dskdriver_init
/* _RAMDskDrvrMacOS68020: */ /* supplied by linker script */
    .long        _RAMDskEnd020Drvr-.   /*  physical block size */
    .include     "NuBusFPGARAMDskDrvr.s"             /*   driver code */
/* _RAMDskEnd020Drvr: */ /* supplied by linker script */

	
	.section .text.begin
	ALIGN 2
_sRsrc_HDMIAudio:	
	OSLstEntry  sRsrcType,_HDMIAudioType      /*  video type descriptor */
    .long EndOfList               /*  end of list */

	ALIGN 2
_HDMIAudioType:	
    .short        catProto               /*      <Category> */
    .short        typeAudio /* custom */                 /*      <Type> */
    .short        drSwApple                /*      <DrvrSw> */
    .short        DrHwNuBusFPGAAudio             /*      <DrvrHw> */
	
	
    /* Declaration ROM directory at end */
       .section .romblock
       ALIGN 2
DeclROMDir:
       .long RsrcDirOffset /* supplied by linker script, replace OSLstEntry 0, _sRsrcDir */
DeclROMCRC:
       .long ROMSize /* supplied by linker script */
       .long 0 /* crc TBComputed after the fact */
       .byte 1                  /* Revision Level */
       .byte appleFormat        /* Apple Format */
       .long testPattern        /* magic TestPattern */
       .byte 0                  /* reserved */
       .byte 0x0F               /* byte lane marker */
DeclRomEnd:
       .end
