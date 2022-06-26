#include "A4Stuff.h"
#include "SetupA4.h"
#include <OSUtils.h>
#include <Types.h>
#include <QuickDraw.h>
#include	<Slots.h>
#include	<ROMDefs.h>

#include "NuBusFPGA_HW.h"

#include "ShowInitIcon.h"

#define kINITid 0

#define _BitBlt 0xAB00

// #define QEMU


int hwblit(char* stack, char* p_fb_base, /* short dstshift, */ short mode, Pattern* pat, PixMapPtr dstpix, PixMapPtr srcpix, Rect *dstrect, Rect *srcrect);
pascal asm void myBitBlt(BitMap *srcBits, BitMap *maskBits, BitMap *dstBits, Rect *srcRect, Rect *maskRect, Rect *dstRect, short mode, Pattern *pat, RgnHandle rgnA, RgnHandle rgnB, RgnHandle rgnC, short multColor);
short check_slots(char list[6]);

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

#include "NuBusFPGA_QD.h"

#ifdef QEMU
#define DLOG(x) bt->debug = (x);
#else
#define DLOG(X)
#endif

int hwblit(char* stack, char* p_fb_base, /* short dstshift, */ short mode, Pattern* pat, PixMapPtr dstpix, PixMapPtr srcpix, Rect *dstrect, Rect *srcrect) {
	struct goblin_bt_regs* bt = (struct goblin_bt_regs*)(p_fb_base + GOBLIN_BT_OFFSET);
	struct goblin_accel_regs* accel_le = (struct goblin_accel_regs*)(p_fb_base + GOBLIN_ACCEL_OFFSET_LE);
	struct qdstuff* qdstack = (struct qdstuff*)(stack - sizeof(struct qdstuff));
	short height = qdstack->MINRECT.bottom - qdstack->MINRECT.top;
	short dstshift = qdstack->DSTSHIFT;
	short srcshift = qdstack->SRCSHIFT;
	short expat_size = 0;
	short expat_const = 0;
	
 	if ((mode != 0) && (mode != 8)) { // only copy handled for now
#if 0
		DLOG(-2L)
		DLOG(mode)
#endif
		return 0;
	}
	
	if (mode == 8) {
		register int i, n;
		register unsigned long expat0 = qdstack->EXPAT[0];
		if (qdstack->PATROW != 0) {
			expat_size = (qdstack->PATVMASK+1) >> 2;
#if 0
			DLOG(-6L)
			DLOG((unsigned long)qdstack->EXPAT)
			DLOG(expat_size)
			for (i = 0 ; i < expat_size ; i++) {
			  DLOG(qdstack->EXPAT[i])
			}
			// PATROW is the stride between lines (bytes)
			DLOG(qdstack->PATROW)
			// PATVMASK has the number of bytes-1 in the pattern?
			DLOG(qdstack->PATVMASK)
			// PATHMASK has ???
			DLOG(qdstack->PATHMASK)
			DLOG(qdstack->PATVPOS)
			DLOG(qdstack->PATHPOS)
#endif
			if (expat_size > 512)
				return 0;
				
			expat_const = 0;
		} else {
			expat_const = 1;
			if ((expat0 & 0xFFFF) != ((expat0 >> 16) & 0xFFFF))
				expat_const = 0;
			if ((expat0 & 0xFF) != ((expat0 >> 8) & 0xFF))
				expat_const = 0;
			for (i = 1 ; expat_const && i < 16 ; i++)
				if (expat0 != qdstack->EXPAT[i])
					expat_const = 0;
				
#ifdef QEMU
			if (!expat_const) {
				DLOG(-7L)
				// PATROW is the stride between lines (bytes)
				DLOG(qdstack->PATROW)
				// PATVMASK has the number of bytes-1 in the pattern?
				DLOG(qdstack->PATVMASK)
				// PATHMASK has ???
				DLOG(qdstack->PATHMASK)
				DLOG(qdstack->PATVPOS)
				DLOG(qdstack->PATHPOS)
				for (i = 0 ; i < 16 ; i++)
					DLOG(qdstack->EXPAT[i])
				//return 0;
			}
#endif
			expat_size = 16;
		}
	}
	
	if (srcshift != dstshift) {
		DLOG(-9L)
		DLOG(srcshift)
		DLOG(dstshift)
		return 0;
	}
	
	
 	if (height < 0) { // no height
 		return 0;
	}
	
	if (dstpix->baseAddr != p_fb_base) { // we're not destination
#if 0//def QEMU
		DLOG(-4L)
		DLOG((unsigned long)dstpix->baseAddr)
#endif
		return 0;
	}
	
	if ((srcpix->baseAddr != p_fb_base)
	   //   && ((unsigned long)srcpix->baseAddr >= 0x40000000) // and neither is main memory
	   ){ 
#if 0//def QEMU
		DLOG(-5L)
		DLOG((unsigned long)srcpix->baseAddr)
#endif
		return 0;
	}
	
	{	
		Rect realrect, srcv, dstv;
		short width = qdstack->MINRECT.right - qdstack->MINRECT.left;
		short src_check = 0x07 >> srcshift;
		short dst_check = 0x07 >> dstshift;
		
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
		
		// must be byte-aligned for now
		if (width & src_check) {
			DLOG(-15);
			DLOG(width);
			return 0;
		}
		if (srcv.left & src_check) {
			DLOG(-16);
			DLOG(srcv.left);
			return 0;
		}
		if (dstv.left & dst_check) {
			DLOG(-17);
			DLOG(dstv.left);
			return 0;
		}
		if (width < 4)
			return 0;
		
		/* if .baseAddr of both pix are different, no overlap */
		/*
		// the HW can handle that for us
		if (dstpix->baseAddr == srcpix->baseAddr) {
		
		}
		*/
#ifdef QEMU
#if 1
		DLOG(-1L) 
		
		DLOG(srcpix->rowBytes)
		DLOG(dstpix->rowBytes)
		
		DLOG(srcv.top)
		DLOG(srcv.left)
		
		DLOG(height)
		DLOG(width)
		
		DLOG(dstv.top)
		DLOG(dstv.left)
		
		DLOG((long)dstpix->baseAddr)
		DLOG((long)srcpix->baseAddr)
#endif
		
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
			register unsigned short i;
			if (expat_const) {
				accel_le->reg_fgcolor = qdstack->EXPAT[0];
				accel_le->reg_cmd = (1<<DO_FILL_BIT);
			} else {
				if (qdstack->PATROW == 0) { // same as 4 ?
					accel_le->reg_bitblt_src_x = 0x3;
					accel_le->reg_bitblt_src_y = 0xf;
					accel_le->reg_src_stride = 4;
					expat_size = 16;
				} else {
					accel_le->reg_bitblt_src_x = qdstack->PATROW - 1;
					accel_le->reg_bitblt_src_y = ((qdstack->PATVMASK+1)/qdstack->PATROW)-1;
					accel_le->reg_src_stride = qdstack->PATROW;
				}
				for (i = 0 ; i < expat_size ; i++) {
					((unsigned long*)(p_fb_base + GOBLIN_PATTERN_OFFSET))[i] = qdstack->EXPAT[i];
				}
				accel_le->reg_cmd = (1<<DO_PATT_BIT);
			}
		}
		WAIT_FOR_HW_LE(accel_le);
		
		return 1;
#endif
	}
	
	return 0;
}

pascal asm void myBitBlt(BitMap *srcBits, BitMap *maskBits, BitMap *dstBits, Rect *srcRect, Rect *maskRect, Rect *dstRect, short mode, Pattern *pat, RgnHandle rgnA, RgnHandle rgnB, RgnHandle rgnC, short multColor) {
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
	short cnt;
	char list[6];
	char slot;
	Handle h;
	struct goblin_bt_regs* bt;
	 
	//volatile unsigned long * const debug_ptr = (unsigned long*)0xFC90001c;
	//*debug_ptr = 0xDEADBEEF;
	
	oldA4 = SetCurrentA4();
	RememberA4();
	
	cnt = check_slots(list);
	
	if (!cnt)
		goto finish;
		
	slot = list[0]; // FIXME: what if more than one ???
	
	//fb_base = (void*)GOBLIN_FB_BASE; // FIXME !!!
	fb_base = (void*)(0xF0000000ul | (((unsigned long)slot) << 24));
	bt_base = ((char*)fb_base + GOBLIN_BT_OFFSET);
	accel_base = ((char*)fb_base + GOBLIN_ACCEL_OFFSET);
	
	bt = (struct goblin_bt_regs*)bt_base;
	DLOG(0xDEADBEEF)
	DLOG((unsigned long)fb_base)
	DLOG((unsigned long)bt_base)
	DLOG((unsigned long)accel_base)
	
	h = Get1Resource('INIT', kINITid);
	if (h) {
		DetachResource(h);
	} else {
		DebugStr("\pargh");
	}

	oldBitBlt = (BitBltProc)GetToolTrapAddress(_BitBlt);
	//*debug_ptr = (unsigned long)oldBitBlt;
	SetToolTrapAddress((UniversalProcPtr)myBitBlt, _BitBlt);
	
	ShowInitIcon(121 + slot, true);
	
finish:
	/* restore the a4 world */
	SetA4(oldA4);
	//	*debug_ptr = 0xBEEFDEAD;
}

short check_slots(char list[6]) {
	int		i;
	short cnt;
	OSErr	err;
	SpBlock				mySpBlock;
	SInfoRecord			mySInfoRecord;
	cnt = 0;
	// check all slots
	for (i = 0x9 ; i < 0xf ; i++) {
		// check if there's something there
		mySpBlock.spResult = (long)&mySInfoRecord;
		mySpBlock.spSlot = i;
		mySpBlock.spSize = 0; // unused by SReadInfo, can be altered
		err = SReadInfo(&mySpBlock);
		if (!err) {
			if (mySInfoRecord.siInitStatusA == smEmptySlot) {
				// oups ?
			} else {
				// check for what exactly is here
				mySpBlock.spSlot = i;
				mySpBlock.spID = 0;
				mySpBlock.spExtDev = 0;
				mySpBlock.spCategory = catDisplay;
				mySpBlock.spCType = typeVideo;
				mySpBlock.spDrvrSW = drSwApple;
				mySpBlock.spDrvrHW = 0xbeef; // DrHwNuBusFPGA
				mySpBlock.spTBMask = 0;
				err = SNextTypeSRsrc(&mySpBlock);
				if (!err) {
					if ((mySpBlock.spCategory == catDisplay) &&
						(mySpBlock.spCType == typeVideo) &&
						(mySpBlock.spDrvrSW == drSwApple) &&
						(mySpBlock.spDrvrHW == 0xbeef) &&
						(mySpBlock.spSlot == i))  {
						list[cnt] = i;
						cnt ++;
					}
				}
			}
		}
	}
	return cnt;
}