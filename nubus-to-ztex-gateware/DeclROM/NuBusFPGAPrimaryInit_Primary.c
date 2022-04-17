#include "NuBusFPGADrvr.h"

#include <Traps.h>

#define PRIM_WRITEREG(reg, val) \
	*((volatile UInt32*)(a32+GOBOFB_BASE+reg)) = (UInt32)val;

UInt32 Primary(SEBlock* seblock) {
	UInt32 a32 = 0xF0000000 | ((UInt32)seblock->seSlot << 24);
	UInt32 a32_l0, a32_l1;
	UInt32 a32_4p0, a32_4p1;
	SpBlock spblock;
	UInt8 pram[8];
	OSErr err;
	UInt16 i,j;
	char busMode;
	UniversalProcPtr qd32ptr, unimpptr;
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32 // this likely won't work on older MacII ???

	PRIM_WRITEREG(GOBOFB_VBL_MASK, 0);// disable interrupts
	
	/* PRIM_WRITEREG(GOBOFB_DEBUG, busMode);// trace */

	/* grey the screen */
	a32_l0 = a32;
	a32_l1 = a32 + HRES;
	for (j = 0 ; j < VRES ; j+= 2) {
		a32_4p0 = a32_l0;
		a32_4p1 = a32_l1;
		for (i = 0 ; i < HRES ; i += 4) {
			*((UInt32*)a32_4p0) = 0xAAAAAAAA;
			*((UInt32*)a32_4p1) = 0x55555555;
			a32_4p0 += 4;
			a32_4p1 += 4;
		}
		a32_l0 += 2*HRES;
		a32_l1 += 2*HRES;
	}
	
	SwapMMUMode ( &busMode ); // restore

	/* call SVersion to figure out if we have a recent SlotManager */
	//spblock.spSlot = seblock->seSlot;
	//spblock.spExtDev = 0;
	err = SVersion(&spblock);

	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (err) {
		/* DCDMF3 p178: if error, old slot manager*/
		/* PRIM_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);*/
		/* PRIM_WRITEREG(GOBOFB_DEBUG, err);*/
	} else {
		/* DCDMF3 p178: new slot manager */
		/* PRIM_WRITEREG(GOBOFB_DEBUG, 0);*/
		/* PRIM_WRITEREG(GOBOFB_DEBUG, spblock.spResult);*/
	}
	SwapMMUMode ( &busMode ); // restore

	/* check for 32-bits QuickDraw */
	qd32ptr = GetTrapAddress(Check32QDTrap);
	unimpptr = GetTrapAddress(_Unimplemented);
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (qd32ptr == unimpptr) {
		/* no 32QD */
		PRIM_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);
		PRIM_WRITEREG(GOBOFB_DEBUG, unimpptr);
	} else {
		/* yes 32QD */
		PRIM_WRITEREG(GOBOFB_DEBUG, 0x00C0FFEE);
	}
	SwapMMUMode ( &busMode ); // restore

	/* check the content of the PRAM */
	spblock.spSlot = seblock->seSlot;
	spblock.spResult = (UInt32)pram;
	err = SReadPRAMRec(&spblock);
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32
	if (err) {
		/* PRIM_WRITEREG(GOBOFB_DEBUG, 0xFFFFFFFF);*/
		/* PRIM_WRITEREG(GOBOFB_DEBUG, err);*/
	} else {
		/* PRIM_WRITEREG(GOBOFB_DEBUG, 0xC0FFEE00);*/
		/* for (i = 0 ; i < 8 ; i++) */
		/* 	PRIM_WRITEREG(GOBOFB_DEBUG, pram[i]);*/
	}
	SwapMMUMode ( &busMode ); // restore
	

	seblock->seStatus = 1;

	return 0;
}

