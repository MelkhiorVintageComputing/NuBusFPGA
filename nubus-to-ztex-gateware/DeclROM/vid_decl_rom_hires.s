
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
	ALIGN 2
_HiRes15Modes:	
             OSLstEntry    mVidParams,_HRV15Parms         /*  offset to vid parameters */
             DatLstEntry   mPageCnt,Pages15s             /*  number of video pages */
             DatLstEntry   mDevType,directType         /*  device type */
             .long   EndOfList                  /*  end of list */
_HRV15Parms:	
             .long          _EndHRV15Parms-_HRV15Parms      /*  physical block size  */
             .long          defmBaseOffset              /*  QuickDraw base offset ; vpBaseOffset */
             .word          RB15s                        /*  physRowBytes ; vpRowBytes */
             .word          defmBounds_Ts,defmBounds_Ls,defmBounds_Bs,defmBounds_Rs /*  vpBounds */
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
_EndHRV15Parms:	
