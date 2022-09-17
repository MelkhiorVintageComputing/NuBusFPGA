
	ALIGN 2
_M13_8Modes:	
             OSLstEntry    mVidParams,_M13_V8Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages8s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V8Parms:	
             .long          _End_M13_V8Parms-_M13_V8Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          640                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
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
_End_M13_V8Parms:	
	ALIGN 2
_M13_4Modes:	
             OSLstEntry    mVidParams,_M13_V4Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages4s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V4Parms:	
             .long          _End_M13_V4Parms-_M13_V4Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          320                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
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
_End_M13_V4Parms:
	ALIGN 2
_M13_2Modes:	
             OSLstEntry    mVidParams,_M13_V2Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages2s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V2Parms:	
             .long          _End_M13_V2Parms-_M13_V2Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          160                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
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
_End_M13_V2Parms:
	ALIGN 2
_M13_1Modes:	
             OSLstEntry    mVidParams,_M13_V1Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages1s             /*  number of video pages */
             DatLstEntry   mDevType,clutType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V1Parms:	
             .long          _End_M13_V1Parms-_M13_V1Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          80                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
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
_End_M13_V1Parms:	
	ALIGN 2
_M13_24Modes:	
             OSLstEntry    mVidParams,_M13_V24Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages24s             /*  number of video pages */
             DatLstEntry   mDevType,directType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V24Parms:	
             .long          _End_M13_V24Parms-_M13_V24Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          2560                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
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
_End_M13_V24Parms:	
	ALIGN 2
_M13_15Modes:	
             OSLstEntry    mVidParams,_M13_V15Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages15s             /*  number of video pages */
             DatLstEntry   mDevType,directType         /*  device type */
             .long   EndOfList                  /*  end of list */
_M13_V15Parms:	
             .long          _End_M13_V15Parms-_M13_V15Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          1280                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,480,640 /*  vpBounds */
             .word          defVersion                  /*  bmVersion ; vpVersion */
             .word	   0				/*  packType not used ; vpPackType */
             .long	   0 				/*  packSize not used ; vpPackSize */
             .long          defmHRes                    /*  bmHRes  */
             .long          defmVRes                    /*  bmVRes */
             .word          ChunkyDirect                /*  bmPixelType */
             .word          16                          /*  bmPixelSize */
             .word          3                           /*  bmCmpCount */
             .word          5                           /*  bmCmpSize */
             .long          defmPlaneBytes              /*  bmPlaneBytes */
_End_M13_V15Parms:	
