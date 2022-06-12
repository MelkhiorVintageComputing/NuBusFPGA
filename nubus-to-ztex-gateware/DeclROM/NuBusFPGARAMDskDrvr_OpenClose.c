#include "NuBusFPGARAMDskDrvr.h"

/* duplicated */
 void MyAddDrive(short drvrRefNum, short drvNum, DrvQElPtr qEl);

OSErr cNuBusFPGARAMDskOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	DrvSts2 *dsptr; // pointer to the DrvSts2 in our context
	DrvQElPtr dq;
	int drvnum = 1;
	struct RAMDrvContext *ctx;
	OSErr ret = noErr;

	dce->dCtlDevBase = 0xfc000000;
	
	write_reg(dce, GOBOFB_DEBUG, 0xDEAD0000);
	/* write_reg(dce, GOBOFB_DEBUG, dce->dCtlRefNum); */

	if (dce->dCtlStorage == nil) {
		for(dq = (DrvQElPtr)(GetDrvQHdr())->qHead; dq; dq = (DrvQElPtr)dq->qLink) {
			if (dq->dQDrive >= drvnum)
				drvnum = dq->dQDrive+1;
		}
		
		dce->dCtlStorage = NewHandleSysClear(sizeof(struct RAMDrvContext));
		if (dce->dCtlStorage == nil) {
			ret = openErr;
			goto done;
		}
		
		HLock(dce->dCtlStorage);

		ctx = *(struct RAMDrvContext **)dce->dCtlStorage;
		
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
		{
			unsigned char* superslot = 0xc0000000; // FIXME
			unsigned long *compressed = 0xFcFF8000; // FIXME
			unsigned long res;
			/*
        write_reg(dce, GOBOFB_DEBUG, 0xDEAD0000);
        write_reg(dce, GOBOFB_DEBUG, compressed);
	write_reg(dce, GOBOFB_DEBUG, compressed[0]);
        write_reg(dce, GOBOFB_DEBUG, compressed[1]);
        write_reg(dce, GOBOFB_DEBUG, compressed[2]);
        write_reg(dce, GOBOFB_DEBUG, compressed[3]);
	*/
			res = rledec(superslot, compressed, 730);
			/*
	write_reg(dce, GOBOFB_DEBUG, res);
	write_reg(dce, GOBOFB_DEBUG, 0xDEEEEEAD);
	*/
		}


		MyAddDrive(dsptr->dQRefNum, drvnum, (DrvQElPtr)&dsptr->qLink);
	}
		

 done:
	return ret;
}

OSErr cNuBusFPGARAMDskClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	//RAMDrvContext *ctx = *(RAMDrvContext**)dce->dCtlStorage;
	
	dce->dCtlDevBase = 0xfc000000;
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0001); */
	
	if (dce->dCtlStorage) {
		HUnlock(dce->dCtlStorage);
		DisposeHandle(dce->dCtlStorage);
		dce->dCtlStorage = NULL;
	}
	return ret;
}

