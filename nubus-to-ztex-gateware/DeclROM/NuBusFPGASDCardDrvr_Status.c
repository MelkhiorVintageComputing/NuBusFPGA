#include "NuBusFPGASDCardDrvr.h"

#pragma parameter __D0 cNuBusFPGASDCardStatus(__A0, __A1)
OSErr cNuBusFPGASDCardStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct SDCardContext *ctx;
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0004); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->csCode); */

	ctx = *(struct SDCardContext**)dce->dCtlStorage;
	
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
