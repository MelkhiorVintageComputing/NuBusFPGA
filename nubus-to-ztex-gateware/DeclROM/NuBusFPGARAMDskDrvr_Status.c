#include "NuBusFPGARAMDskDrvr.h"

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
   return ret;
}
