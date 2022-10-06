#include "NuBusFPGARAMDskDrvr.h"

#pragma parameter __D0 cNuBusFPGARAMDskStatus(__A0, __A1)
OSErr cNuBusFPGARAMDskStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct RAMDrvContext *ctx;
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0004); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->csCode); */

	ctx = *(struct RAMDrvContext**)dce->dCtlStorage;
	
	if (ctx) {
		switch (pb->csCode)
			{
			default:
				ret = statusErr;
				break;
			}
	} else {
		ret = offLinErr; /* r/w requested for an off-line drive */
		goto done;
	}

 done:
	if (!(pb->ioTrap & (1<<noQueueBit)))
		IODone((DCtlPtr)dce, ret);
   return ret;
}
