// this is the stack frame upon entry in BitBlt as described in DravingVars.a
// wrong order as it's going in negative offset
struct qdstuff_order {
	//  STACK FRAME VARS USED BY SEEKMASK (CALLED BY STRETCHBITS, RGNBLT, DRAWARC, DRAWLINE)
	//  (NOT USED IN PATEXPAND)

	uint16_t RECTFLAG;		// // EQU 	-2					;WORD
	uint16_t VERT;	//  // RECTFLAG-2
	uint32_t RGNBUFFER;	// 							 // VERT-4
	uint32_t RUNBUF;	// 						<BAL 21Sep88> // RGNBUFFER-4
	uint16_t BUFLEFT;	//  // RUNBUF-2
	uint16_t BUFSIZE;	//  // BUFLEFT-2
	uint32_t EXRTN;	//  // BUFSIZE-4
	uint32_t RUNRTN;	//  // EXRTN-4
	uint32_t SEEKMASK;	//  // RUNRTN-4
	uint32_t DSTMASKBUF;	//  // SEEKMASK-4
	uint32_t DSTMASKALIGN;	//  // DSTMASKBUF-4
	uint8_t STATEA[24];	//  STATE RECORD // DSTMASKALIGN-RGNREC
	uint8_t STATEB[24];	//  STATE RECORD // STATEA-RGNREC
	uint8_t STATEC[24];	//  STATE RECORD // STATEB-RGNREC
	uint16_t MINRECT[4];	// 						<BAL 21Sep88> // STATEC-8
	uint16_t DSTSHIFT;	// 						<BAL 21Sep88> // MINRECT-2
	uint16_t RUNBUMP;	// 						<BAL 05Nov88> // DSTSHIFT-2
	uint32_t DSTROW;	// 						<BAL 03Oct88> // RUNBUMP-4
	uint32_t GoShow;	//  Go home and show crsr <BAL 21Mar89> // DSTROW-4
	uint32_t STACKFREE;	// 	->					<BAL 21Sep88> // GoShow-4

	//  STACK FRAME VARS USED BY PATEXPAND, COLORMAP, DRAWSLAB
	// (CALLED BY STRETCHBITS, RGNBLT, BITBLT, DRAWARC, DRAWLINE)

	//													 SET UP  FOR BITBLT   FOR RGNBLT
	uint32_t EXPAT;	// 				YES // STACKFREE-4
	uint16_t PATVMASK;	//  (must follow expat) // EXPAT-2
	uint16_t PATHMASK;	//  (must follow PATVMASK) // PATVMASK-2
	uint16_t PATROW;	//  (must follow PATHMASK) // PATHMASK-2
	uint16_t PATHPOS;	// 				YES // PATROW-2
	uint8_t  filler5;	// 	<8>			YES // PATHPOS-1
	uint8_t  alphaMode;	// 	<8> // filler5-1
	uint32_t PATVPOS;	// 	<8>			YES		<BAL 22Jan89> // alphaMode-4
	uint16_t LOCMODE;	// 				YES // PATVPOS-2
	uint32_t LOCPAT;	// 				YES // LOCMODE-4
	uint32_t FCOLOR;	// 				YES // LOCPAT-4
	uint32_t BCOLOR;	// 				YES // FCOLOR-4
	uint8_t useDither;	//	//		BCOLOR-1			;(was pixsrc) 	reclaimed 07Jul88 <BAL>
	uint8_t  NEWPATTERN;	// 				YES // useDither-1
	uint8_t DSTPIX[78];	// +COLOR TABLE	   YES -> STACKFREE -54-(50+8) // NEWPATTERN-

	uint16_t weight[3];	//   weight for averaging // DSTPIX-6 //uint16_t pin[3];	//   used by max, min // weight
	uint16_t notWeight[3];	//   complement of weight (for average) // weight-6
	uint8_t  multiColor;	// 	set if source contains nonblack/white colors // notWeight-1
	uint8_t  MMUsave;	// 	MMU mode on entry to QD // multiColor-1
	uint8_t  FGnotBlack;	//  /	true if forecolor - black // MMUsave-1
	uint8_t  BGnotWhite;	//  \	true if backcolor - white (must follow FGBlack) // FGnotBlack-1
	uint32_t colorTable;	// 	pointer to color table // BGnotWhite-4
	uint32_t invColor;	// 	pointer to inverse color table // colorTable-4
	uint16_t invSize;	//  	resolution of inverse color table // invColor-2
	uint16_t rtShift;	// 	used by average how far to shift // invSize-2
	uint32_t transColor;	// 	copy of backcolor for transparent // rtShift-4
	uint32_t hilitColor;	// 	hilite color pixels-> DSTPIX-36 // transColor-4

	//  MORE SHARED STACK FRAME VARS (STRETCHBITS, RGNBLT, BITBLT)

	uint16_t alignSrcPM;    //  // hilitColor-2
	uint8_t SRCPIX[78];     //      YES // alignSrcPM-
	uint16_t alignMaskPM;   //  // SRCPIX-2
	uint8_t MASKPIX[78];    //      YES // alignMaskPM-
	uint32_t SRCROW;        //                              YES // MASKPIX-4
	uint32_t MASKROW;       //                              YES // SRCROW-4
	uint16_t SRCSHIFT;      //                              YES // MASKROW-2
	uint16_t MASKSHIFT;     //                              YES // SRCSHIFT-2
	uint32_t INVERTFLAG;    //                              YES // MASKSHIFT-4
	uint32_t SAVESTK;       //                              YES // INVERTFLAG-4
	uint32_t SAVEA5;        //                              YES // SAVESTK-4

	uint32_t SRCBUF;        //  // SAVEA5-4
	uint32_t DSTBUF;        //  // SRCBUF-4
	uint32_t SCALEBUF;      //  // DSTBUF-4
	uint32_t dstBufBump;    //              <BAL 17Mar89> // SCALEBUF-4
	uint32_t scaleBufBump;  //              <BAL 17Mar89> // dstBufBump-4
	uint32_t SRCMASKBUF;    //  // scaleBufBump-4
	uint16_t filler1;       //  // SRCMASKBUF-2
	uint16_t SRCLONGS;      //  // filler1-2
	uint16_t SRCMASKLONGS;  //  // SRCLONGS-2
	uint16_t DSTMASKLONGS;  //  // SRCMASKLONGS-2
	uint16_t DSTLONGS;      //  // DSTMASKLONGS-2
	uint16_t SCALELONGS;    //  // DSTLONGS-2
	uint32_t SRCADDR;       //  // SCALELONGS-4
	uint32_t MASKADDR;      //  // SRCADDR-4
	uint32_t DSTADDR;       //  // MASKADDR-4
	uint32_t SRCLIMIT;      //  // DSTADDR-4
	uint16_t NUMER[2];      //  // SRCLIMIT-4
	uint16_t DENOM[2];      //  // NUMER-4
	uint16_t MASKNUMER[2];  //  // DENOM-4
	uint16_t MASKDENOM[2];  //  // MASKNUMER-4
	uint32_t MODECASE;      // -> hilitColor-140-2*(PMREC+CTREC) (50+8) -> -256 -> DSTPIX -292 // MASKDENOM-4

	//  STACK FRAME VARS USED BY STRETCHBITS ONLY

	uint32_t RATIOCASE;     //  // MODECASE-4
	uint32_t MASKCASE;      //  // RATIOCASE-4
	uint16_t HORIZFRACTION; //  // MASKCASE-2
	uint16_t MASKFRACT;     //  // HORIZFRACTION-2
	uint32_t SCALECASE;     //  // MASKFRACT-4
	uint16_t SRCSCANS;      //  // SCALECASE-2
	uint16_t SRCPIXCNT;     //  // SRCSCANS-2
	uint32_t SRCALIGN;      //  // SRCPIXCNT-4
	uint32_t DSTALIGN;      //  // SRCALIGN-4
	uint32_t MASKALIGN;     //  // DSTALIGN-4
	uint32_t ScaleTbl;      //  // MASKALIGN-4
	uint16_t VERROR;        //  // ScaleTbl-2
	uint16_t CRSRFLAG;      //  // VERROR-2
	uint32_t REALBOUNDS;    // -> MODECASE-44 -> DSTPIX-336 // CRSRFLAG-4


	//  STACK FRAME VARS USED BY RGNBLT ONLY

	uint16_t FIRSTV;        //  // REALBOUNDS-2
	uint16_t LASTV; //  // FIRSTV-2
	uint16_t VBUMP; // , MUST BE ABOVE HBUMP // LASTV-2
	uint16_t HBUMP; //  // VBUMP-2
	uint32_t RGNADDR;       //  // HBUMP-4
	uint16_t filler2;       //  // RGNADDR-2
	uint16_t SRCSIZE;       //  // filler2-2
	uint32_t SAVESTK2;      // -> REALBOUNDS-20 -> DSTPIX-356 // SRCSIZE-4


	//  STACK FRAME VARS USED BY BITBLT ONLY

	uint16_t SRCV;  //  // SAVESTK2-2
	uint16_t DSTV;  //  // SRCV-2
	uint16_t SRCBUMP;       //  // DSTV-2
	uint16_t HEIGHT;        //  // SRCBUMP-2
	uint16_t SRCRECT2[4];   // -> SAVESTK2-16 -> DSTPIX-372 // HEIGHT-8
	uint32_t FIRSTMASK;     //  // SRCRECT2-4
	uint16_t LONGCNT;       //  // FIRSTMASK-2


	//  STACK FRAME VARS USED BY RGNBLT/BITBLT

	uint8_t  doneMid;       //   two flags used to control loop // LONGCNT-1
	uint8_t  endSwitch;     //   three-way switch chooses from src, pat, bigpat // doneMid-1
	uint32_t lastMask;      //   mask for last long blitted on line // endSwitch-4
	uint16_t midCount;      //   # of pixels on line less mask longs - 1 // lastMask-2
	uint16_t pixInLong;     //   # of pixels in a long - 1 // midCount-2
	uint32_t patOffset;     //   pattern horizontal initial offset   // pixInLong-4
	uint16_t patPos;        //   pattern vertical offset // patOffset-2
	uint16_t destPixCnt;    //   1-based cnt of pixels to blit<02Mar89 BAL> // patPos-2
	uint32_t destPixOffset; //   destination pixel offset   <08Jan89 BAL> // destPixCnt-4
	uint16_t pixInLong1;    //   same as pixInLong, 1 based (for transparent) // destPixOffset-2
	uint16_t longBump;      //   32 signed direction of blit (for transparent) // pixInLong1-2
};

// same as above, but lines are in reverse order so it can be used directly once the pointer to the stack frame is known
// some types have been hand-converted (e.g. MINRECT to Rect)
struct qdstuff {
	uint16_t longBump;      //   32 signed direction of blit (for transparent) // pixInLong1-2
	uint16_t pixInLong1;    //   same as pixInLong, 1 based (for transparent) // destPixOffset-2
	uint32_t destPixOffset; //   destination pixel offset   <08Jan89 BAL> // destPixCnt-4
	uint16_t destPixCnt;    //   1-based cnt of pixels to blit<02Mar89 BAL> // patPos-2
	uint16_t patPos;        //   pattern vertical offset // patOffset-2
	uint32_t patOffset;     //   pattern horizontal initial offset   // pixInLong-4
	uint16_t pixInLong;     //   # of pixels in a long - 1 // midCount-2
	uint16_t midCount;      //   # of pixels on line less mask longs - 1 // lastMask-2
	uint32_t lastMask;      //   mask for last long blitted on line // endSwitch-4
	uint8_t  endSwitch;     //   three-way switch chooses from src, pat, bigpat // doneMid-1
	uint8_t  doneMid;       //   two flags used to control loop // LONGCNT-1

	//  STACK FRAME VARS USED BY RGNBLT/BITBLT


	uint16_t LONGCNT;       //  // FIRSTMASK-2
	uint32_t FIRSTMASK;     //  // SRCRECT2-4
	uint16_t SRCRECT2[4];   // -> SAVESTK2-16 -> DSTPIX-372 // HEIGHT-8
	uint16_t HEIGHT;        //  // SRCBUMP-2
	uint16_t SRCBUMP;       //  // DSTV-2
	uint16_t DSTV;  //  // SRCV-2
	uint16_t SRCV;  //  // SAVESTK2-2

	//  STACK FRAME VARS USED BY BITBLT ONLY


	uint32_t SAVESTK2;      // -> REALBOUNDS-20 -> DSTPIX-356 // SRCSIZE-4
	uint16_t SRCSIZE;       //  // filler2-2
	uint16_t filler2;       //  // RGNADDR-2
	uint32_t RGNADDR;       //  // HBUMP-4
	uint16_t HBUMP; //  // VBUMP-2
	uint16_t VBUMP; // , MUST BE ABOVE HBUMP // LASTV-2
	uint16_t LASTV; //  // FIRSTV-2
	uint16_t FIRSTV;        //  // REALBOUNDS-2

	//  STACK FRAME VARS USED BY RGNBLT ONLY


	uint32_t REALBOUNDS;    // -> MODECASE-44 -> DSTPIX-336 // CRSRFLAG-4
	uint16_t CRSRFLAG;      //  // VERROR-2
	uint16_t VERROR;        //  // ScaleTbl-2
	uint32_t ScaleTbl;      //  // MASKALIGN-4
	uint32_t MASKALIGN;     //  // DSTALIGN-4
	uint32_t DSTALIGN;      //  // SRCALIGN-4
	uint32_t SRCALIGN;      //  // SRCPIXCNT-4
	uint16_t SRCPIXCNT;     //  // SRCSCANS-2
	uint16_t SRCSCANS;      //  // SCALECASE-2
	uint32_t SCALECASE;     //  // MASKFRACT-4
	uint16_t MASKFRACT;     //  // HORIZFRACTION-2
	uint16_t HORIZFRACTION; //  // MASKCASE-2
	uint32_t MASKCASE;      //  // RATIOCASE-4
	uint32_t RATIOCASE;     //  // MODECASE-4

	//  STACK FRAME VARS USED BY STRETCHBITS ONLY

	uint32_t MODECASE;      // -> hilitColor-140-2*(PMREC+CTREC) (50+8) -> -256 -> DSTPIX -292 // MASKDENOM-4
	uint16_t MASKDENOM[2];  //  // MASKNUMER-4
	uint16_t MASKNUMER[2];  //  // DENOM-4
	uint16_t DENOM[2];      //  // NUMER-4
	uint16_t NUMER[2];      //  // SRCLIMIT-4
	uint32_t SRCLIMIT;      //  // DSTADDR-4
	uint32_t DSTADDR;       //  // MASKADDR-4
	uint32_t MASKADDR;      //  // SRCADDR-4
	uint32_t SRCADDR;       //  // SCALELONGS-4
	uint16_t SCALELONGS;    //  // DSTLONGS-2
	uint16_t DSTLONGS;      //  // DSTMASKLONGS-2
	uint16_t DSTMASKLONGS;  //  // SRCMASKLONGS-2
	uint16_t SRCMASKLONGS;  //  // SRCLONGS-2
	uint16_t SRCLONGS;      //  // filler1-2
	uint16_t filler1;       //  // SRCMASKBUF-2
	uint32_t SRCMASKBUF;    //  // scaleBufBump-4
	uint32_t scaleBufBump;  //              <BAL 17Mar89> // dstBufBump-4
	uint32_t dstBufBump;    //              <BAL 17Mar89> // SCALEBUF-4
	uint32_t SCALEBUF;      //  // DSTBUF-4
	uint32_t DSTBUF;        //  // SRCBUF-4
	uint32_t SRCBUF;        //  // SAVEA5-4

	uint32_t SAVEA5;        //                              YES // SAVESTK-4
	uint32_t SAVESTK;       //                              YES // INVERTFLAG-4
	uint32_t INVERTFLAG;    //                              YES // MASKSHIFT-4
	uint16_t MASKSHIFT;     //                              YES // SRCSHIFT-2
	uint16_t SRCSHIFT;      //                              YES // MASKROW-2
	uint32_t MASKROW;       //                              YES // SRCROW-4
	uint32_t SRCROW;        //                              YES // MASKPIX-4
	uint8_t MASKPIX[78];    //      YES // alignMaskPM-
	uint16_t alignMaskPM;   //  // SRCPIX-2
	uint8_t SRCPIX[78];     //      YES // alignSrcPM-
	uint16_t alignSrcPM;    //  // hilitColor-2

	//  MORE SHARED STACK FRAME VARS (STRETCHBITS, RGNBLT, BITBLT)

	uint32_t hilitColor;	// 	hilite color pixels-> DSTPIX-36 // transColor-4
	uint32_t transColor;	// 	copy of backcolor for transparent // rtShift-4
	uint16_t rtShift;	// 	used by average how far to shift // invSize-2
	uint16_t invSize;	//  	resolution of inverse color table // invColor-2
	uint32_t invColor;	// 	pointer to inverse color table // colorTable-4
	uint32_t colorTable;	// 	pointer to color table // BGnotWhite-4
	uint8_t  BGnotWhite;	//  \	true if backcolor - white (must follow FGBlack) // FGnotBlack-1
	uint8_t  FGnotBlack;	//  /	true if forecolor - black // MMUsave-1
	uint8_t  MMUsave;	// 	MMU mode on entry to QD // multiColor-1
	uint8_t  multiColor;	// 	set if source contains nonblack/white colors // notWeight-1
	uint16_t notWeight[3];	//   complement of weight (for average) // weight-6
	uint16_t weight[3];	//   weight for averaging // DSTPIX-6 //uint16_t pin[3];	//   used by max, min // weight

	uint8_t DSTPIX[78];	// +COLOR TABLE	   YES -> STACKFREE -54-(50+8) // NEWPATTERN-
	uint8_t  NEWPATTERN;	// 				YES // useDither-1
	uint8_t useDither;	//	//		BCOLOR-1			;(was pixsrc) 	reclaimed 07Jul88 <BAL>
	uint32_t BCOLOR;	// 				YES // FCOLOR-4
	uint32_t FCOLOR;	// 				YES // LOCPAT-4
	uint32_t LOCPAT;	// 				YES // LOCMODE-4
	uint16_t LOCMODE;	// 				YES // PATVPOS-2
	uint32_t PATVPOS;	// 	<8>			YES		<BAL 22Jan89> // alphaMode-4
	uint8_t  alphaMode;	// 	<8> // filler5-1
	uint8_t  filler5;	// 	<8>			YES // PATHPOS-1
	uint16_t PATHPOS;	// 				YES // PATROW-2
	uint16_t PATROW;	//  (must follow PATHMASK) // PATHMASK-2
	uint16_t PATHMASK;	//  (must follow PATVMASK) // PATVMASK-2
	uint16_t PATVMASK;	//  (must follow expat) // EXPAT-2
	uint32_t* EXPAT;	// 				YES // STACKFREE-4
	//													 SET UP  FOR BITBLT   FOR RGNBLT

	// (CALLED BY STRETCHBITS, RGNBLT, BITBLT, DRAWARC, DRAWLINE)
	//  STACK FRAME VARS USED BY PATEXPAND, COLORMAP, DRAWSLAB

	uint32_t STACKFREE;	// 	->					<BAL 21Sep88> // GoShow-4
	uint32_t GoShow;	//  Go home and show crsr <BAL 21Mar89> // DSTROW-4
	uint32_t DSTROW;	// 						<BAL 03Oct88> // RUNBUMP-4
	uint16_t RUNBUMP;	// 						<BAL 05Nov88> // DSTSHIFT-2
	uint16_t DSTSHIFT;	// 						<BAL 21Sep88> // MINRECT-2
	Rect MINRECT;	// 						<BAL 21Sep88> // STATEC-8
	uint8_t STATEC[24];	//  STATE RECORD // STATEB-RGNREC
	uint8_t STATEB[24];	//  STATE RECORD // STATEA-RGNREC
	uint8_t STATEA[24];	//  STATE RECORD // DSTMASKALIGN-RGNREC
	uint32_t DSTMASKALIGN;	//  // DSTMASKBUF-4
	uint32_t DSTMASKBUF;	//  // SEEKMASK-4
	uint32_t SEEKMASK;	//  // RUNRTN-4
	uint32_t RUNRTN;	//  // EXRTN-4
	uint32_t EXRTN;	//  // BUFSIZE-4
	uint16_t BUFSIZE;	//  // BUFLEFT-2
	uint16_t BUFLEFT;	//  // RUNBUF-2
	uint32_t RUNBUF;	// 						<BAL 21Sep88> // RGNBUFFER-4
	uint32_t RGNBUFFER;	// 							 // VERT-4
	uint16_t VERT;	//  // RECTFLAG-2
	uint16_t RECTFLAG;		// // EQU 	-2					;WORD

	//  (NOT USED IN PATEXPAND)
	//  STACK FRAME VARS USED BY SEEKMASK (CALLED BY STRETCHBITS, RGNBLT, DRAWARC, DRAWLINE)
};
