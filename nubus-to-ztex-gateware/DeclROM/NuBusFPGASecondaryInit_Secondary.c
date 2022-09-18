#include "NuBusFPGADrvr.h"

#include <Traps.h>

#define SECO_WRITEREG(reg, val) \
	*((volatile UInt32*)(a32+GOBOFB_BASE+reg)) = (UInt32)val;

UniversalProcPtr toto;

void local_BitBlt(void);
asm("	.ALIGN 2\n"
"        .type   local_BitBlt, @function\n"
"local_BitBlt:\n"
"	move.l %a0,-(%sp)\n"
"	move.l #0xfc90001c, %a0\n"
"	move.l #0xDEADBEEF, (%a0)\n"
"	/* move.l %pc@(orig_BitBlt), (%a0) */\n"
"	move.l %sp@(4), (%a0)\n"
"	move.l %a1, (%a0)\n"
"	move.l %a2, (%a0)\n"
"	move.l %a3, (%a0)\n"
"	move.l %a4, (%a0)\n"
"	move.l %a5, (%a0)\n"
"	move.l %a6, (%a0)\n"
"	move.l %a2@(0),(%a0)\n"
"	move.l %a2@(4),(%a0)\n"
"	move.l %a3@(0),(%a0)\n"
"	move.l %a3@(4),(%a0)\n"
"	move.l (%sp)+,%a0\n"
"	move.l %pc@(toto),(%a0)\n"
"	move.l %pc@(toto),-(%sp)\n"
"	rts\n"
".size   local_BitBlt, .-local_BitBlt\n"
	);

UInt32 Secondary(SEBlock* seblock) {
	UInt32 a32 = 0xF0000000 | ((UInt32)seblock->seSlot << 24);
	UInt32 a32_l0, a32_l1;
	UInt32 a32_4p0, a32_4p1;
	SpBlock spblock;
	/* UInt8 pram[8]; */
	OSErr err;
	UInt16 i,j;
	char busMode;
	UniversalProcPtr qd32ptr, unimpptr;
	
	busMode = 1;

	/* call SVersion to figure out if we have a recent SlotManager */
#if 0
	//spblock.spSlot = seblock->seSlot;
	//spblock.spExtDev = 0;
	err = SVersion(&spblock);

	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (err) {
		/* DCDMF3 p178: if error, old slot manager*/
		/* SECO_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);*/
		/* SECO_WRITEREG(GOBOFB_DEBUG, err);*/
	} else {
		/* DCDMF3 p178: new slot manager */
		/* SECO_WRITEREG(GOBOFB_DEBUG, 0);*/
		/* SECO_WRITEREG(GOBOFB_DEBUG, spblock.spResult);*/
	}
	SwapMMUMode ( &busMode ); // restore
#endif

#if 1
	/* check for 32-bits QuickDraw */
	qd32ptr = GetTrapAddress(Check32QDTrap);
	unimpptr = GetTrapAddress(_Unimplemented);
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (qd32ptr == unimpptr) {
		/* no 32QD */
		SECO_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);
		SECO_WRITEREG(GOBOFB_DEBUG, unimpptr);
	} else {
		/* yes 32QD */
		SECO_WRITEREG(GOBOFB_DEBUG, 0x00C0FFEE);
	}
	SwapMMUMode ( &busMode ); // restore
#endif


#if 0
	/* check the content of the PRAM */
	spblock.spSlot = seblock->seSlot;
	spblock.spResult = (UInt32)pram;
	err = SReadPRAMRec(&spblock);

#if 0
	SECO_WRITEREG(GOBOFB_DEBUG, 0x88888888);
	for (j = 0 ; j < 8 ; j++)
		SECO_WRITEREG(GOBOFB_DEBUG, (uint32_t)pram[j]);
	SECO_WRITEREG(GOBOFB_DEBUG, 0x88888888);
#endif
#endif
	
#if 0
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (err) {
		/* SECO_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);*/
		/* SECO_WRITEREG(GOBOFB_DEBUG, err);*/
	} else {
		/* SECO_WRITEREG(GOBOFB_DEBUG, 0xC0FFEE00);*/
		/* for (i = 0 ; i < 8 ; i++) */
		/* 	SECO_WRITEREG(GOBOFB_DEBUG, pram[i]);*/
	}
	SwapMMUMode ( &busMode ); // restore
#endif

#if 0
	// patch some traps
	UniversalProcPtr orig_BitBlt = GetToolTrapAddress(0xAB00); // BitBlt
	SECO_WRITEREG(GOBOFB_DEBUG, orig_BitBlt);
	SECO_WRITEREG(GOBOFB_DEBUG, unimpptr);
	toto = orig_BitBlt;
	SECO_WRITEREG(GOBOFB_DEBUG, toto);
	UniversalProcPtr tutu;
	asm("lea %%pc@(local_BitBlt),%0\n" : "=a"(tutu));
	SECO_WRITEREG(GOBOFB_DEBUG, tutu);
	SetToolTrapAddress(orig_BitBlt, 0xAB00);
#endif
	
	seblock->seStatus = 1;

	return 0;
}

