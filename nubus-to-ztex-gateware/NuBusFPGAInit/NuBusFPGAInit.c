#include "A4Stuff.h"
#include "SetupA4.h"
#include <OSUtils.h>
#include <Types.h>
#include <QuickDraw.h>

#include "NuBusFPGA_HW.h"

#define kINITid 0

#define _BitBlt 0xAB00

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

#if 0
pascal void myStdBits(BitMap *srcBits, Rect *srcRect, Rect *dstRect, short mode, RgnHandle maskRgn){
	long	oldA4;
	volatile unsigned long * const debug_ptr = (unsigned long*)0xFC90001c;
	*debug_ptr = 0xC0FFEE00;
	
	oldA4 = SetCurrentA4();
	RememberA4();
	
	oldStdBits(srcBits, srcRect, dstRect, mode, maskRgn);
	
	SetA4(oldA4);
}

pascal void myBitBltX(BitMap *srcBits, BitMap *maskBits, BitMap *dstBits, Rect *srcRect, Rect *maskRect, Rect *dstRect, short mode, Pattern *pat, RgnHandle rgnA, RgnHandle rgnB, RgnHandle rgnC, short multColor){
	register BitBltProc loldBitBlt;
	register long oldA4;
	volatile unsigned long * const debug_ptr = (unsigned long*)0xFC90001c;
	*debug_ptr = 0xC0FFEE00;
	
	oldA4 = SetCurrentA4();
	RememberA4();
	
	//oldBitBlt(srcBits, maskBits, dstBits, srcRect, maskRect, dstRect, mode, pat, rgnA, rgnB, rgnC, multColor);
	loldBitBlt = oldBitBlt;
	
	SetA4(oldA4);
	
	loldBitBlt(srcBits, maskBits, dstBits, srcRect, maskRect, dstRect, mode, pat, rgnA, rgnB, rgnC, multColor);
}
#endif

static inline unsigned long brev(const unsigned long r) {
	return (((r&0xFF000000)>>24) | ((r&0xFF0000)>>8) | ((r&0xFF00)<<8) | ((r&0xFF)<<24));
}

#define WAIT_FOR_HW(accel) \
	while (accel->reg_status & brev(1<<WORK_IN_PROGRESS_BIT))

 int hwblit(char* p_fb_base, short dstshift, short mode, PixMapPtr dstpix, PixMapPtr srcpix, Rect *dstrect, Rect *srcrect, Rect minrect) {
	//volatile unsigned long * const debug_ptr = (unsigned long*)0xFC90001c;
	struct goblin_bt_regs* bt = (struct goblin_bt_regs*)(p_fb_base + GOBLIN_BT_OFFSET);
	struct goblin_accel_regs* accel = (struct goblin_accel_regs*)(p_fb_base + GOBLIN_ACCEL_OFFSET);
	short height = minrect.bottom - minrect.top;
	//*debug_ptr = 0xC0FFEE00;
	//*debug_ptr = (unsigned long)p_fb_base;
	
 	if (mode != 0) { // only copy for now
		//*debug_ptr = -2L;
		//*debug_ptr = mode;
        return 0;
	}
 	if (dstshift < 3) { // only 8/16/32 bits for now
		//*debug_ptr = -3L;
		//*debug_ptr = dstshift;
 		return 0;
	}
	dstshift -= 3;
 	if (height < 0) { // no height
		//*debug_ptr = -4L;
		//*debug_ptr = height;
 		return 0;
	}
	
	if (dstpix->baseAddr != p_fb_base) { // we're not destination
		return 0;
	}
	if (srcpix->baseAddr != p_fb_base) { // we're not source
		return 0;
	}
	
    if ((minrect.top == 0x0) & (minrect.bottom == 0x14) &
        (minrect.left == 0x5c9) & (minrect.right == 0x5f6)) { // ignore that one until later
		//*debug_ptr = -5L;
        return 0;
	}
	
	{	
		Rect realrect, srcv, dstv;
		short width = minrect.right - minrect.left;
		
		//*debug_ptr = -1L;
		
		realrect.top = minrect.top;
		realrect.left = minrect.left;
		//realrect.bottom = minrect.bottom;
		//realrect.right = minrect.right;
		
		realrect.top += (srcrect->top - dstrect->top);
		realrect.left += (srcrect->left - dstrect->left); /* A2 */
		/* minrect is A3 */
		
		srcv.top = realrect.top - srcpix->bounds.top;
		srcv.left = realrect.left - srcpix->bounds.left;
		
		dstv.top = minrect.top - dstpix->bounds.top;
		dstv.left = minrect.left - dstpix->bounds.left;
		
		/* if .baseAddr of both pix are different, no overlap */
		/*
		// the HW can handle that for us
		if (dstpix->baseAddr == srcpix->baseAddr) {
			
		}
		*/
		bt->debug = srcv.top;
		bt->debug = srcv.left;
		
		bt->debug = dstv.top;
		bt->debug = dstv.left;
		
		bt->debug = (long)dstpix->baseAddr;
		bt->debug = (long)srcpix->baseAddr;
		
		bt->debug = height;
		bt->debug = width;
		
		WAIT_FOR_HW(accel);
		
		accel->reg_width = brev(width);
		accel->reg_height = brev(height);
		accel->reg_bitblt_src_x = brev(srcv.left << dstshift);
		accel->reg_bitblt_src_y = brev(srcv.top);
		accel->reg_bitblt_dst_x = brev(dstv.left << dstshift);
		accel->reg_bitblt_dst_y = brev(dstv.top);
		
		accel->reg_cmd = brev(1<<DO_BLIT_BIT);
		
		WAIT_FOR_HW(accel);
		
		return 1;
	}
        
//	*debug_ptr = a;
    
#if 0
	*debug_ptr = dstshift;
	*debug_ptr = mode;

	*debug_ptr = dstrect->top;
	*debug_ptr = dstrect->left;
	*debug_ptr = dstrect->bottom;
	*debug_ptr = dstrect->right;
	
	*debug_ptr = srcrect->top;
	*debug_ptr = srcrect->left;
	*debug_ptr = srcrect->bottom;
	*debug_ptr = srcrect->right;
	
	*debug_ptr = minrect.top;
	*debug_ptr = minrect.left;
	*debug_ptr = minrect.bottom;
	*debug_ptr = minrect.right;
#endif

	
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
 move.l a0,-(sp) // save oldBitBlt
 // MINRECT
 move.l -112(a6),-(sp) // parameter (last first)
 move.l -116(a6),-(sp) // parameter (last first)
 move.l a2,-(sp) // srcrect*
 move.l a3,-(sp) // dstrect*
 move.l a4,-(sp) // srcpix*
 move.l a5,-(sp) // dstpix*
 move.w 26(a6),-(sp) // mode
 move.w d4,-(sp) // dstshift
 move.l a1,-(sp) // fb_base
 jsr hwblit
 add #0x20,sp

 move.l (sp)+,a0 // restore oldBitBlt
 //move.l a0,0xfc90001c
 cmpi #1,d0 // if hwblit returned 1, it did the copy
 beq finish
 jmp (a0)
finish:
 rts
}
//616 610
#if 0
CQDProcs customCProcs;
#endif

void main(void)
{
	long	oldA4;

#if 0
	GrafPtr currPort;
#endif
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
	
#if 0
	GetPort(&currPort);
	if (currPort->portBits.rowBytes < 0) /* color port */ {
		SetStdCProcs(&customCProcs);
		customCProcs.bitsProc = myStdBits;
		currPort->grafProcs = (QDProcs*)&customCProcs;
	*debug_ptr = 0;
	} else {
		*debug_ptr = 0xF00FF00F;
	}
#endif

#if 0
	oldStdBits = (StdBitsProc)GetToolTrapAddress(_StdBits);
	*debug_ptr = (unsigned long)oldStdBits;
	SetToolTrapAddress((UniversalProcPtr)myStdBits, _StdBits);
#endif

	oldBitBlt = (BitBltProc)GetToolTrapAddress(_BitBlt);
	//*debug_ptr = (unsigned long)oldBitBlt;
	SetToolTrapAddress((UniversalProcPtr)myBitBlt, _BitBlt);
	
	/* restore the a4 world */
	SetA4(oldA4);
//	*debug_ptr = 0xBEEFDEAD;
}

