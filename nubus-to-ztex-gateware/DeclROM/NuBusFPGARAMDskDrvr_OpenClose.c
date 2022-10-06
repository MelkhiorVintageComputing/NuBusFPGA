#include "NuBusFPGARAMDskDrvr.h"

#include <Disks.h>

/* FYI, missing in library with Retro68 */
/* void AddDrive(short drvrRefNum, short drvNum, DrvQElPtr qEl); */

/* re-implement with Retro68 features */
/* drVNum to high-order bits of num, drvrRefNum in low-order */
/* not sure how to do "parameter" without output ? */
#pragma parameter __D0 AddDrive(__D0, __A0)
__attribute__ ((section (".text.dskdriver"))) static inline int dupAddDrive(unsigned long num, DrvQElPtr qEl) {
	asm volatile(".word 0xA04E" : : "d" (num), "a" (qEl));
	return num; // should cost nothing, num is already in D0
}

#include <ROMDefs.h>

#pragma parameter __D0 cNuBusFPGARAMDskOpen(__A0, __A1)
OSErr cNuBusFPGARAMDskOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	DrvSts2 *dsptr; // pointer to the DrvSts2 in our context
	int drvnum = 1;
	struct RAMDrvContext *ctx;
	OSErr ret = noErr;
	char busMode;
	char slot;
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32 // this likely won't work on older MacII ???

	if (dce->dCtlDevBase == 0) { // for some unknown reason, we get an empty dCtlDevBase...
		if ((dce->dCtlSlot > 0xE) || (dce->dCtlSlot < 0x9)) { // safety net
			SpBlock				mySpBlock;
			SInfoRecord			mySInfoRecord;
			mySpBlock.spResult = (long)&mySInfoRecord;
			
			mySpBlock.spSlot = 0x9; // start at first
			mySpBlock.spID = 0;
			mySpBlock.spExtDev = 0;
			mySpBlock.spCategory = catProto;
			mySpBlock.spCType = 0x1000; // typeDrive;
			mySpBlock.spDrvrSW = drSwApple;
			mySpBlock.spDrvrHW = 0xbeee; // DrHwNuBusFPGADsk
			mySpBlock.spTBMask = 0;
			ret = SNextTypeSRsrc(&mySpBlock);
			if (ret)
				goto done;
			slot = mySpBlock.spSlot;
		} else {
			slot = dce->dCtlSlot;
		}
		dce->dCtlDevBase = 0xF0000000ul | ((unsigned long)slot << 24);
	}
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0000); */
	/* write_reg(dce, GOBOFB_DEBUG, dce->dCtlSlot); */

	if (dce->dCtlStorage == nil) {
		DrvQElPtr dq;
		for(dq = (DrvQElPtr)(GetDrvQHdr())->qHead; dq; dq = (DrvQElPtr)dq->qLink) {
			if (dq->dQDrive >= drvnum)
				drvnum = dq->dQDrive+1;
		}
		
		ReserveMemSys(sizeof(struct RAMDrvContext));
		dce->dCtlStorage = NewHandleSysClear(sizeof(struct RAMDrvContext));
		if (dce->dCtlStorage == nil) {
			ret = openErr;
			goto done;
		}
		
		HLock(dce->dCtlStorage);

		ctx = *(struct RAMDrvContext **)dce->dCtlStorage;
		ctx->slot = slot;
		
		dsptr = &ctx->drvsts;
		// dsptr->track /* current track */
		dsptr->writeProt = 0; /* bit 7 = 1 if volume is locked */
		dsptr->diskInPlace = 8; /* disk in drive */
		// dsptr->installed /* drive installed */
		// dsptr->sides /* -1 for 2-sided, 0 for 1-sided */
		// dsptr->QLink /* next queue entry */
		dsptr->qType = 1; /* 1 for HD20 */ /* Files 2-85 (p173) : 1 to enable S1 */
		dsptr->dQDrive = drvnum; /* drive number */
		dsptr->dQRefNum = dce->dCtlRefNum; /* driver reference number */
		// dsptr->dQFSID /* file system ID */
		dsptr->driveSize = ((DRIVE_SIZE_BYTES/512ul) & 0x0000FFFFul); /* (no comments in Disks.h) */
		dsptr->driveS1 =   ((DRIVE_SIZE_BYTES/512ul) & 0xFFFF0000ul) >> 16; /* */
		// dsptr->driveType
		// dsptr->driveManf
		// dsptr->driveChar
		// dsptr->driveMisc
		
	//	MyAddDrive(dsptr->dQRefNum, drvnum, (DrvQElPtr)&dsptr->qLink);

	//	write_reg(dce, GOBOFB_DEBUG, 0x0000DEAD);

		// initialize to our empty volume
		{
			unsigned long *superslot = (unsigned long*)(((unsigned long)ctx->slot) << 28ul);
			unsigned long *compressed = (unsigned long*)(dce->dCtlDevBase + 0x00FF8000ul);
			unsigned long res;
			res = rledec(superslot, compressed, 730); // FIXME: 730 = 2920/4 (compressed size in words)
		}

		// add the drive
		//MyAddDrive(dsptr->dQRefNum, drvnum, (DrvQElPtr)&dsptr->qLink);
		dupAddDrive((dsptr->dQRefNum & 0xFFFF) | (drvnum << 16), (DrvQElPtr)&dsptr->qLink);
		
#ifdef ENABLE_DMA
		ctx->dma_blk_size = revb( read_reg(dce, DMA_BLK_SIZE) );
		ctx->dma_blk_size_mask = ctx->dma_blk_size - 1; // size is Po2
		ctx->dma_blk_size_shift = 0;
		while ((1 << ctx->dma_blk_size_shift) < ctx->dma_blk_size) // fixme
			   ctx->dma_blk_size_shift++;
		ctx->dma_blk_base = revb( read_reg(dce, DMA_BLK_BASE) );
		ctx->dma_mem_size = revb( read_reg(dce, DMA_MEM_SIZE) );
		/* write_reg(dce, GOBOFB_DEBUG, 0xD1580002); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size_mask); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size_shift); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_base); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_mem_size); */
#endif

		// auto-mount
		{
			ParamBlockRec pbr;
			pbr.volumeParam.ioVRefNum = dsptr->dQDrive;
			ret = PBMountVol(&pbr);
		}

		
	}
		
	SwapMMUMode ( &busMode ); 

 done:
	return ret;
}

#pragma parameter __D0 cNuBusFPGARAMDskClose(__A0, __A1)
OSErr cNuBusFPGARAMDskClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	//RAMDrvContext *ctx = *(RAMDrvContext**)dce->dCtlStorage;
	
	/* dce->dCtlDevBase = 0xfc000000; */
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0001); */
	
	if (dce->dCtlStorage) {
		/* HUnlock(dce->dCtlStorage); */ /* not needed before DisposeHandle */
		DisposeHandle(dce->dCtlStorage);
		dce->dCtlStorage = NULL;
	}
	return ret;
}

