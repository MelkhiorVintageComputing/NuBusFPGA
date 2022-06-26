#include "NuBusFPGARAMDskDrvr.h"

/* Devices 1-34 (p54) */
OSErr cNuBusFPGARAMDskPrime(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct RAMDrvContext *ctx;
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0003); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioTrap); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioPosMode); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioReqCount); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioPosOffset); */

	ctx = *(struct RAMDrvContext**)dce->dCtlStorage;
	
	if (ctx) {
		unsigned char* superslot = (unsigned char*)(((unsigned long)ctx->slot) << 28ul);
		unsigned long abs_offset = 0;
		/* IOParamPtr: Devices 1-53 (p73) */
		/* **** WHERE **** */
		switch(pb->ioPosMode & 0x000F) { // ignore rdVerify
		case fsAtMark:
			abs_offset = dce->dCtlPosition;
			break;
		case fsFromStart:
			abs_offset = pb->ioPosOffset;
			break;
		case fsFromMark:
			abs_offset = dce->dCtlPosition + pb->ioPosOffset;
			break;
		default:
			break;
		}
		/* **** WHAT **** */
		/* Devices 1-33 (p53) */
		if ((pb->ioTrap & 0x00FF) == aRdCmd) {
			if(!(pb->ioPosMode & 0x40)) { // rdVerify, let's ignore it for now
				BlockMoveData((superslot + abs_offset), pb->ioBuffer, pb->ioReqCount);
			}
			pb->ioActCount = pb->ioReqCount;
			dce->dCtlPosition = abs_offset + pb->ioReqCount;
			pb->ioPosOffset = dce->dCtlPosition;
		} else if ((pb->ioTrap & 0x00FF) == aWrCmd) {
			BlockMoveData(pb->ioBuffer, (superslot + abs_offset), pb->ioReqCount);
			pb->ioActCount = pb->ioReqCount;
			dce->dCtlPosition = abs_offset + pb->ioReqCount;
			pb->ioPosOffset = dce->dCtlPosition;
		} else {
			ret = paramErr;
			goto done;
		}
	} else {
		ret = offLinErr; /* r/w requested for an off-line drive */
		goto done;
	}

 done:
	return ret;
}
