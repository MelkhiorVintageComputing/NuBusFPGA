#include "A4Stuff.h"
#include "SetupA4.h"
#include <OSUtils.h>
#include <Types.h>
#include <QuickDraw.h>

#include "NuBusFPGA_HW.h"

#define kINITid 0

#define _BitBlt 0xAB00

// #define QEMU


//extern pascal void CopyBits(const BitMap *srcBits, const BitMap *dstBits, const Rect *srcRect, const Rect *dstRect, short mode, RgnHandle maskRgn) ONEWORDINLINE(0xA8EC);
//extern pascal void StdBits(const BitMap *srcBits, const Rect *srcRect, const Rect *dstRect, short mode, RgnHandle maskRgn) ONEWORDINLINE(0xA8EB);

#if 0
typedef pascal void (*StdBitsProc)(BitMap *srcBits, Rect *srcRect, Rect *dstRect, short mode, RgnHandle maskRgn);
StdBitsProc oldStdBits;
#endif

typedef pascal void (*BitBltProc)(BitMap *srcBits, BitMap *maskBits, BitMap *dstBits, Rect *srcRect, Rect *maskRect, Rect *dstRect, short mode, Pattern *pat, RgnHandle rgnA, RgnHandle rgnB, RgnHandle rgnC, short multColor);
static BitBltProc oldBitBlt;

void* fb_base;
void* bt_base;
void* accel_base;

static inline unsigned long brev(const unsigned long r) {
	return (((r&0xFF000000)>>24) | ((r&0xFF0000)>>8) | ((r&0xFF00)<<8) | ((r&0xFF)<<24));
}

#define WAIT_FOR_HW(accel)						\
	while (accel->reg_status & brev(1<<WORK_IN_PROGRESS_BIT))

#define WAIT_FOR_HW_LE(accel_le)						\
	while (accel_le->reg_status & (1<<WORK_IN_PROGRESS_BIT))

#define uint8_t unsigned char
#define uint16_t unsigned short
#define uint32_t unsigned long

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


int hwblit(char* stack, char* p_fb_base, /* short dstshift, */ short mode, Pattern* pat, PixMapPtr dstpix, PixMapPtr srcpix, Rect *dstrect, Rect *srcrect) {
	struct goblin_bt_regs* bt = (struct goblin_bt_regs*)(p_fb_base + GOBLIN_BT_OFFSET);
	struct goblin_accel_regs* accel_le = (struct goblin_accel_regs*)(p_fb_base + GOBLIN_ACCEL_OFFSET_LE);
	struct qdstuff* qdstack = (struct qdstuff*)(stack - sizeof(struct qdstuff));
	short height = qdstack->MINRECT.bottom - qdstack->MINRECT.top;
	short dstshift = qdstack->DSTSHIFT;
	short srcshift = qdstack->SRCSHIFT;
	
 	if ((mode != 0) && (mode != 8)) { // only copy handled for now
#ifdef QEMU
		bt->debug = -2L;
		bt->debug = mode;
		if (mode == 8) {
			bt->debug = qdstack->PATROW;
#if 0
			bt->debug = pat->pat[0];
			bt->debug = pat->pat[1];
			bt->debug = pat->pat[2];
			bt->debug = pat->pat[3];
			bt->debug = pat->pat[4];
			bt->debug = pat->pat[5];
			bt->debug = pat->pat[6];
			bt->debug = pat->pat[7];
#endif
		}
#endif
		return 0;
	}
	
	if (mode == 8) {
		register int i;
		register unsigned long expat0 = qdstack->EXPAT[0];
		if (qdstack->PATROW != 0) {
			bt->debug = -6L;
			return 0;
		}
		if ((expat0 & 0xFFFF) != ((expat0 >> 16) & 0xFFFF))
			return 0;
		if ((expat0 & 0xFF) != ((expat0 >> 8) & 0xFF))
			return 0;
		for (i = 1 ; i < 16 ; i++)
			if (expat0 != qdstack->EXPAT[i]) {
				bt->debug = -7L;
				bt->debug = i;
				bt->debug = expat0;
				bt->debug = qdstack->EXPAT[i];
				return 0;
			}
	}
	
 	if (dstshift < 3) { // only 8/16/32 bits for now
#ifdef QEMU
		bt->debug = -3L;
		bt->debug = dstshift;
#endif
 		return 0;
	}
	dstshift -= 3;
	
 	if (srcshift < 3) { // only 8/16/32 bits for now
#ifdef QEMU
		bt->debug = -8L;
		bt->debug = srcshift;
#endif
 		return 0;
	}
	srcshift -= 3;
	
	if (srcshift != dstshift) {
		bt->debug = -9L;
		bt->debug = srcshift;
		bt->debug = dstshift;
		return 0;
	}
	
	
 	if (height < 0) { // no height
 		return 0;
	}
	
	if (dstpix->baseAddr != p_fb_base) { // we're not destination
#ifdef QEMU
		bt->debug = -4L;
		bt->debug = (unsigned long)dstpix->baseAddr;
#endif
		return 0;
	}
	
	if ((srcpix->baseAddr != p_fb_base)
	    //  && ((unsigned long)srcpix->baseAddr >= 0x40000000) // and neither is main memory
	   ){ 
#ifdef QEMU
		bt->debug = -5L;
		bt->debug = (unsigned long)srcpix->baseAddr;
#endif
		return 0;
	}
	
	{	
		Rect realrect, srcv, dstv;
		short width = qdstack->MINRECT.right - qdstack->MINRECT.left;
		
		//*debug_ptr = -1L;
		
		realrect.top = qdstack->MINRECT.top;
		realrect.left = qdstack->MINRECT.left;
		//realrect.bottom = qdstack->MINRECT.bottom;
		//realrect.right = qdstack->MINRECT.right;
		
		realrect.top += (srcrect->top - dstrect->top);
		realrect.left += (srcrect->left - dstrect->left); /* A2 */
			/* qdstack->MINRECT is A3 */
		
		srcv.top = realrect.top - srcpix->bounds.top;
		srcv.left = realrect.left - srcpix->bounds.left;
		
		dstv.top = qdstack->MINRECT.top - dstpix->bounds.top;
		dstv.left = qdstack->MINRECT.left - dstpix->bounds.left;
		
		/* if .baseAddr of both pix are different, no overlap */
		/*
		// the HW can handle that for us
		if (dstpix->baseAddr == srcpix->baseAddr) {
		
		}
		*/
#ifdef QEMU
#if 0
		if ((mode == 8) && (qdstack->PATROW == 0)) {
			bt->debug = 0x87654321;
			bt->debug = qdstack->EXPAT[ 0];
			bt->debug = qdstack->EXPAT[ 1];
			bt->debug = qdstack->EXPAT[ 2];
			bt->debug = qdstack->EXPAT[ 3];
			bt->debug = qdstack->EXPAT[ 4];
			bt->debug = qdstack->EXPAT[ 5];
			bt->debug = qdstack->EXPAT[ 6];
			bt->debug = qdstack->EXPAT[ 7];
			bt->debug = qdstack->EXPAT[ 8];
			bt->debug = qdstack->EXPAT[ 9];
			bt->debug = qdstack->EXPAT[10];
			bt->debug = qdstack->EXPAT[11];
			bt->debug = qdstack->EXPAT[12];
			bt->debug = qdstack->EXPAT[13];
			bt->debug = qdstack->EXPAT[14];
			bt->debug = qdstack->EXPAT[15];
		}
#endif
		bt->debug = -1L; 
		
		bt->debug = srcpix->rowBytes;
		bt->debug = dstpix->rowBytes;
		
		bt->debug = srcv.top;
		bt->debug = srcv.left;
		
		bt->debug = height;
		bt->debug = width;
		
		bt->debug = dstv.top;
		bt->debug = dstv.left;
		
		bt->debug = (long)dstpix->baseAddr;
		bt->debug = (long)srcpix->baseAddr;
		
			return 0;
#else
		WAIT_FOR_HW_LE(accel_le);
		
		accel_le->reg_width = (width); // pixels
		accel_le->reg_height = (height);
		accel_le->reg_bitblt_dst_x = (dstv.left); // pixels
		accel_le->reg_bitblt_dst_y = (dstv.top);
		if (dstpix->baseAddr != p_fb_base)
			accel_le->reg_dst_ptr = (unsigned long)(dstpix->baseAddr);
		else
			accel_le->reg_dst_ptr = 0; // let the HW pick its internal address
		accel_le->reg_dst_stride = (dstpix->rowBytes); // bytes // we should strip the high-order bit, but the HW ignore that for us anyway
		
		if (mode == 0) {
			accel_le->reg_bitblt_src_x = (srcv.left); // pixels
			accel_le->reg_bitblt_src_y = (srcv.top);
			if (srcpix->baseAddr != p_fb_base)
				accel_le->reg_src_ptr = (unsigned long)(srcpix->baseAddr);
			else
				accel_le->reg_src_ptr = 0; // let the HW pick its internal address
			accel_le->reg_src_stride = (srcpix->rowBytes); // bytes // we should strip the high-order bit, but the HW ignore that for us anyway
			accel_le->reg_cmd = (1<<DO_BLIT_BIT);
		} else if (mode == 8) {
			accel_le->reg_fgcolor = (qdstack->EXPAT[0]);
			accel_le->reg_cmd = (1<<DO_FILL_BIT);
		}
		
		WAIT_FOR_HW_LE(accel_le);
		
		return 1;
#endif
	}
	
	return 0;
}

pascal asm void myBitBlt(BitMap *srcBits, BitMap *maskBits, BitMap *dstBits, Rect *srcRect, Rect *maskRect, Rect *dstRect, short mode, Pattern *pat, RgnHandle rgnA, RgnHandle rgnB, RgnHandle rgnC, short multColor){
	// a2: srcrect
	// a3: dstrect
	// a4: srcpix
	// a5: dstpix
	// d3: srcshift (not used)
	// d4: dstshift
	// d7: invert flag

	link a6,#-4
		//moveq #-1,d0
		//move.l d0,0xfc90001c
		jsr SetCurrentA4
		move.l d0,-4(a6)
		jsr RememberA4
		////movea.l 0(a4), a0
		movea.l oldBitBlt, a0
		movea.l fb_base, a1
		//move.l a0,0xfc90001c
		move.l -4(a6), d0
		//move.l d0,0xfc90001c
		exg d0,a4
		unlk a6

		//move.l #0xF00FF00F,d0
		//move.l a0,0xfc90001c
		//move.l d0,0xfc90001c
		move.l a0,-(sp) // save oldBitBlt, not a parameter
		
		move.l a2,-(sp) // srcrect*
		move.l a3,-(sp) // dstrect*
		move.l a4,-(sp) // srcpix*
		move.l a5,-(sp) // dstpix*
		move.l 22(a6),-(sp) // pat*
		move.w 26(a6),-(sp) // mode
		//move.w d4,-(sp) // dstshift
		move.l a1,-(sp) // fb_base
		move.l a6,-(sp) // top of stack
		jsr hwblit
		add #0x1e,sp

		move.l (sp)+,a0 // restore oldBitBlt
		//move.l a0,0xfc90001c
		cmpi #1,d0 // if hwblit returned 1, it did the copy
		beq finish
		jmp (a0)
		finish:
	rts
		}

void main(void)
{
	long	oldA4;

	Handle h;
	struct goblin_bt_regs* bt;
	 
	//volatile unsigned long * const debug_ptr = (unsigned long*)0xFC90001c;
	//*debug_ptr = 0xDEADBEEF;
	
	oldA4 = SetCurrentA4();
	RememberA4();
	
	fb_base = (void*)GOBLIN_FB_BASE; // FIXME !!!
	bt_base = ((char*)fb_base + GOBLIN_BT_OFFSET);
	accel_base = ((char*)fb_base + GOBLIN_ACCEL_OFFSET);
	
	bt = (struct goblin_bt_regs*)bt_base;
	bt->debug = 0xDEADBEEF;
	bt->debug = (unsigned long)fb_base;
	bt->debug = (unsigned long)bt_base;
	bt->debug = (unsigned long)accel_base;
	
	h = Get1Resource('INIT', kINITid);
	if (h) {
		DetachResource(h);
	} else {
		DebugStr("\pargh");
	}

	oldBitBlt = (BitBltProc)GetToolTrapAddress(_BitBlt);
	//*debug_ptr = (unsigned long)oldBitBlt;
	SetToolTrapAddress((UniversalProcPtr)myBitBlt, _BitBlt);
	
	/* restore the a4 world */
	SetA4(oldA4);
	//	*debug_ptr = 0xBEEFDEAD;
}

