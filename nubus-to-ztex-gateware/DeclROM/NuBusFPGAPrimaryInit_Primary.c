#include "NuBusFPGADrvr.h"
#include "NuBusFPGARAMDskDrvr.h"

#include <Traps.h>
#include <ROMDefs.h>

#define PRIM_WRITEREG(reg, val) \
	*((volatile UInt32*)(a32+GOBOFB_BASE+reg)) = (UInt32)val
#define PRIM_READREG(reg) \
	(*((volatile UInt32*)(a32+GOBOFB_BASE+reg)))

#pragma parameter __D0 Primary(__A0)
UInt32 Primary(SEBlock* seblock) {
	UInt32 a32 = 0xF0000000 | ((UInt32)seblock->seSlot << 24);
	UInt32 a32_l0, a32_l1;
	UInt32 a32_4p0, a32_4p1;
	SpBlock spblock;
	/* UInt8 pram[8]; */
	OSErr err;
	UInt16 i,j, hres, vres;
	char busMode;
	UniversalProcPtr qd32ptr, unimpptr;
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32 // this likely won't work on older MacII ???

	PRIM_WRITEREG(GOBOFB_VBL_MASK, 0);// disable interrupts on FB
	PRIM_WRITEREG(DMA_IRQ_CTL, revb(0x2));// disable/clear interrupts on DSK
	
	/* PRIM_WRITEREG(GOBOFB_DEBUG, 0x87654321);// trace */
	/* PRIM_WRITEREG(GOBOFB_DEBUG, busMode);// trace */

	hres = __builtin_bswap32((UInt32)PRIM_READREG(GOBOFB_HRES)); // fixme: endianness
	vres = __builtin_bswap32((UInt32)PRIM_READREG(GOBOFB_VRES)); // fixme: endianness
	
	/* initialize DRAM controller */
	sdram_init(a32);

	/* grey the screen */
	/* should switch to HW ? */
	a32_l0 = a32;
	a32_l1 = a32 + hres;
	for (j = 0 ; j < vres ; j+= 2) {
		a32_4p0 = a32_l0;
		a32_4p1 = a32_l1;
		for (i = 0 ; i < hres ; i += 4) {
			*((UInt32*)a32_4p0) = 0xAAAAAAAA;
			*((UInt32*)a32_4p1) = 0x55555555;
			a32_4p0 += 4;
			a32_4p1 += 4;
		}
		a32_l0 += 2*hres;
		a32_l1 += 2*hres;
	}
	
	SwapMMUMode ( &busMode ); // restore

	{ // disable non-default entries
		SpBlock spb;
		err = noErr;
		do {
			spb.spParamData = 1<<foneslot|1<<fnext;
			spb.spCategory = catDisplay;
			spb.spCType = typeVideo;
			spb.spDrvrSW = drSwApple;
			spb.spDrvrHW = 0xBEEF;
			spb.spTBMask = 0; /* match everything above */
			spb.spSlot = seblock->seSlot;
			spb.spID = nativeVidMode; /* skip over the 'good' one; we can reset as SNextTypeSRsrc skips disabled */
			spb.spExtDev = 0;
			err = SNextTypeSRsrc(&spb);
			
			if ((err == noErr) &&
				(spb.spSlot == seblock->seSlot) &&
				(((UInt8)spb.spID) > (UInt8)nativeVidMode) &&
				(((UInt8)spb.spID) < (UInt8)diskResource)) {
				spb.spParamData = 1; /* disable */
				spb.spSlot = seblock->seSlot;
				spb.spExtDev = 0;
				SetSRsrcState(&spb);
				/* PRIM_WRITEREG(GOBOFB_DEBUG, 0xBEEF000F); */
				/* PRIM_WRITEREG(GOBOFB_DEBUG, spb.spID); */
			}
		} while (err == noErr);
	}
	
#if 0

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

#if 0
	PRIM_WRITEREG(GOBOFB_DEBUG, 0x88888888);
	for (j = 0 ; j < 8 ; j++)
		PRIM_WRITEREG(GOBOFB_DEBUG, (uint32_t)pram[j]);
	PRIM_WRITEREG(GOBOFB_DEBUG, 0x88888888);
#endif
	
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

#endif

	seblock->seStatus = 1;

	return 0;
}

/* SDRAM INIT */

