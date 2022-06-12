#include "NuBusFPGARAMDskDrvr.h"

OSErr cNuBusFPGARAMDskCtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct RAMDrvContext *ctx;
	
	dce->dCtlDevBase = 0xfc000000;
	
	write_reg(dce, GOBOFB_DEBUG, 0xDEAD0002);
	write_reg(dce, GOBOFB_DEBUG, pb->csCode);
	
	ctx = *(struct RAMDrvContext**)dce->dCtlStorage;
	
	if (ctx) {
		switch (pb->csCode)
			{
			case kFormat:
				ret = noErr;
				break;
			default:
				ret = controlErr;
				break;
			}
	} else {
		ret = offLinErr; /* r/w requested for an off-line drive */
		goto done;
	}

 done:
	return ret;
}
