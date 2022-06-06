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

#include "NuBusFPGA_QD.h"

#ifdef QEMU
#define DLOG(x) bt->debug - (x);
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
	
 	if ((mode != 0) && (mode != 8)) { // only copy handled for now
#ifdef QEMU
		DLOG(-2L)
		DLOG(mode)
		if (mode == 8) {
			DLOG(qdstack->PATROW)
#if 0
			DLOG(pat->pat[0])
			DLOG(pat->pat[1])
			DLOG(pat->pat[2])
			DLOG(pat->pat[3])
			DLOG(pat->pat[4])
			DLOG(pat->pat[5])
			DLOG(pat->pat[6])
			DLOG(pat->pat[7])
#endif
		}
#endif
		return 0;
	}
	
	if (mode == 8) {
		register int i;
		register unsigned long expat0 = qdstack->EXPAT[0];
		if (qdstack->PATROW != 0) {
			DLOG(-6L)
			return 0;
		}
		if ((expat0 & 0xFFFF) != ((expat0 >> 16) & 0xFFFF))
			return 0;
		if ((expat0 & 0xFF) != ((expat0 >> 8) & 0xFF))
			return 0;
		for (i = 1 ; i < 16 ; i++)
			if (expat0 != qdstack->EXPAT[i]) {
				DLOG(-7L)
				DLOG(i)
				DLOG(expat0)
				DLOG(qdstack->EXPAT[i])
				return 0;
			}
	}

#if 0	
 	if (dstshift < 3) { // only 8/16/32 bits for now
#ifdef QEMU
		DLOG(-3L)
		DLOG(dstshift)
#endif
 		return 0;
	}
	dstshift -= 3;
	
 	if (srcshift < 3) { // only 8/16/32 bits for now
#ifdef QEMU
		DLOG(-8L)
		DLOG(srcshift)
#endif
 		return 0;
	}
	srcshift -= 3;
#endif
	
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
#ifdef QEMU
		DLOG(-4L)
		DLOG((unsigned long)dstpix->baseAddr)
#endif
		return 0;
	}
	
	if ((srcpix->baseAddr != p_fb_base)
	   //   && ((unsigned long)srcpix->baseAddr >= 0x40000000) // and neither is main memory
	   ){ 
#ifdef QEMU
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
		if (width & src_check)
			return 0;
		if (srcv.left & src_check)
			return 0;
		if (dstv.left & dst_check)
			return 0;
		
		/* if .baseAddr of both pix are different, no overlap */
		/*
		// the HW can handle that for us
		if (dstpix->baseAddr == srcpix->baseAddr) {
		
		}
		*/
#ifdef QEMU
#if 0
		if ((mode == 8) && (qdstack->PATROW == 0)) {
			DLOG(0x87654321)
			DLOG(qdstack->EXPAT[ 0])
			DLOG(qdstack->EXPAT[ 1])
			DLOG(qdstack->EXPAT[ 2])
			DLOG(qdstack->EXPAT[ 3])
			DLOG(qdstack->EXPAT[ 4])
			DLOG(qdstack->EXPAT[ 5])
			DLOG(qdstack->EXPAT[ 6])
			DLOG(qdstack->EXPAT[ 7])
			DLOG(qdstack->EXPAT[ 8])
			DLOG(qdstack->EXPAT[ 9])
			DLOG(qdstack->EXPAT[10])
			DLOG(qdstack->EXPAT[11])
			DLOG(qdstack->EXPAT[12])
			DLOG(qdstack->EXPAT[13])
			DLOG(qdstack->EXPAT[14])
			DLOG(qdstack->EXPAT[15])
		}
#endif
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
	
	/* restore the a4 world */
	SetA4(oldA4);
	//	*debug_ptr = 0xBEEFDEAD;
}

