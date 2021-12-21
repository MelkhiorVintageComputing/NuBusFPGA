	.include "atrap.inc"
	.include "globals.inc"
	.include "declrom.inc"

	.include "ROMDefs.inc"
	.include "Video.inc"
	.include "DepVideo.inc"

sRsrc_Board = 1 /*  board sResource (>0 & <128) */
sRsrc_VidS8 = 0x80 /*  functional sResources */

_sRsrcDir:
	OSLstEntry  sRsrc_Board,_sRsrc_Board     /*  board sRsrc List */
    OSLstEntry  sRsrc_VidS8,_sRsrc_VidS8     /*  video sRsrc List */
	.long EndOfList

_sRsrc_Board:	
    OSLstEntry  sRsrcType,_BoardType       /*  offset to board descriptor */
    OSLstEntry  sRsrcName,_BoardName       /*  offset to name of board */
    DatLstEntry boardId,NuBusFPGAID         /*  board ID # (assigned by DTS) */
    /* OSLstEntry  PrimaryInit,_sPInitRec   */  /*  offset to PrimaryInit exec blk */
    OSLstEntry  vendorInfo,_VendorInfo     /*  offset to vendor info record */
	/* OSLstEntry  SecondaryInit,_sSInitRec */  /* offset to SecondaryInit block	 */
	.long EndOfList

_BoardType:	
    .short catBoard            /*  board sResource */
    .short typBoard
    .short 0
    .short 0
	
_BoardName:	
    .String "SBusFPGA Video" /*  name of board */

/*  _VidICON ; optional icon, not needed */
/*  _sVidNameDir ; optional name(s), not needed */

_sPInitRec:	
    .long       _EndsPInitRec-_sPInitRec /*  physical block size */
	/* INCLUDE "NuBusFPGAPrimaryInit.a"			   /*  	the header/code */ */
    ALIGN 2
_EndsPInitRec:	

/* _sSInitRec */
/*               .long    _EndsSInitRec-_sSInitRec ; physical block size */
/*               INCLUDE "NuBusFPGASecondaryInit.a"  ; the header/code */
/*               ALIGN 2 */
								/* _EndsSInitRec */
	
_VendorInfo:	
    OSLstEntry vendorId,_VendorId      /*  offset to vendor ID */
    OSLstEntry revLevel,_RevLevel      /*  offset to revision */
    OSLstEntry partNum,_PartNum        /*  offset to part number record */
    OSLstEntry date,_Date              /*  offset to ROM build date */
    .long EndOfList
	
_VendorId:	
            .string        "Romain Dolbeau"        /*  vendor ID */
_RevLevel:	
            .string        "NuBusFPGA V1.0"        /*  revision level */
_PartNum:	
            .string        "Part Number"           /*  part number */
_Date:	
            .string        "&SysDate"              /*  date */

_sRsrc_VidS8:	
	OSLstEntry  sRsrcType,_VideoType      /*  video type descriptor */
    OSLstEntry  sRsrcName,_VideoName      /*  offset to driver name string */
/*    	          OSLstEntry  sRsrcDrvrDir,_VidDrvrDir ; offset to driver directory */
    DatLstEntry sRsrcHWDevId,1           /*  hardware device ID */
    OSLstEntry  MinorBaseOS,_MinorBase    /*  offset to frame buffer array */
    OSLstEntry  MinorLength,_MinorLength  /*  offset to frame buffer length */
    OSLstEntry  sGammaDir,_GammaDirS      /*  directory for 640x480 monitor */
/*  Parameters */
    OSLstEntry  firstVidMode,_EBMs        /*  offset to EightBitMode parms */
    .long EndOfList               /*  end of list */

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

/* _VidDrvrDir */
/*               OSLstEntry  sMacOS68020,_sMacOS68020     driver directory for Mac OS */
/*               .long EndOfList */
/*  */
/* _sMacOS68020 */
/*               .long        _End020Drvr- sMacOS68020   ;   physical block size */
/*               INCLUDE     'NuBusFPGADrvr.a'             ;   driver code */
/* _End020Drvr */


_GammaDirS:	/*  for the 640x480 monitor */
            OSLstEntry  128,_SmallGamma
            .long EndOfList

_SmallGamma:	
            .long        _EndSmallGamma-_SmallGamma
            .short        SGammaResID
            .string        "Small Gamma"                /*  Monitors name */
            ALIGN       2
            .short        $0000                        /*  gVersion */
            .short        DrHwNuBusFPGA                   /*  gType */
            .short        $0000                        /*  gFormulaSize */
            .short        $0001                        /*  gChanCnt */
            .short        $0100                        /*  gDataCnt */
            .short        $0008                        /*  gChanWidth */
            .long        $0005090B,$0E101315,$17191B1D,$1E202224
            .long        $2527282A,$2C2D2F30,$31333436,$37383A3B
            .long        $3C3E3F40,$42434445,$4748494A,$4B4D4E4F
            .long        $50515254,$55565758,$595A5B5C,$5E5F6061
            .long        $62636465,$66676869,$6A6B6C6D,$6E6F7071
            .long        $72737475,$76777879,$7A7B7C7D,$7E7F8081
            .long        $81828384,$85868788,$898A8B8C,$8C8D8E8F
            .long $90919293,$94959596,$9798999A,$9B9B9C9D
            .long $9E9FA0A1,$A1A2A3A4,$A5A6A6A7,$A8A9AAAB
            .long $ABACADAE,$AFB0B0B1,$B2B3B4B4,$B5B6B7B8
            .long $B8B9BABB,$BCBCBDBE,$BFC0C0C1,$C2C3C3C4
            .long $C5C6C7C7,$C8C9CACA,$CBCCCDCD,$CECFD0D0
            .long $D1D2D3D3,$D4D5D6D6,$D7D8D9D9,$DADBDCDC
            .long $DDDEDFDF,$E0E1E1E2,$E3E4E4E5,$E6E7E7E8
            .long $E9B9EAEB,$ECECEDEE,$EEEFF0F1,$F1F2F3F3
            .long $F4F5F5F6,$F7F8F8F9,$FAFAFBFC,$FCFDFEFF
_EndSmallGamma:	

_EBMs:	
             OSLstEntry    mVidParams,_EBVParms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages8s             /*  number of video pages */
             DatLstEntry   mDevType,defmDevType         /*  device type */
             .long   EndOfList                  /*  end of list */
_EBVParms:	
             .long          _EndEBVParms-_EBVParms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .short          RB8s                        /*  physRowBytes ; vpRowBytes */
             .short          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
             .short          defVersion                  /*  bmVersion ; vpVersion */
             .short	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .short          ChunkyIndexed               /*  bmPixelType */
             .short          8                           /*  bmPixelSize */
             .short          1                           /*  bmCmpCount */
             .short          8                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_EndEBVParms:	

	/* Declaration ROM directory at end */
DeclROMDir:
	OSLstEntry 0, _sRsrcDir
	.long DeclRomEnd-_sRsrcDir /* Length should be 0x824 */
DeclROMCRC:	.long 0x0 /* TODO: calculate this */
	.byte 1			 /* Revision Level */
	.byte appleFormat			 /* Apple Format */
	.long testPattern	 /* magic TestPattern */
	.byte 0			 /* reserved */
	.byte 0x0F		 /* byte lane marker */
DeclRomEnd:
	.end

