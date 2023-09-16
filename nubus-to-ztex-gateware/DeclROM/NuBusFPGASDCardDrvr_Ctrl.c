#include "NuBusFPGASDCardDrvr.h"

#if 0
OSErr changeSDCardIRQ(AuxDCEPtr dce, char en, OSErr err) {
	struct SDCardContext *ctx = *(struct SDCardContext**)dce->dCtlStorage;
	
   if (en != ctx->irqen) {
	   /* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0005); */
	   /* write_reg(dce, GOBOFB_DEBUG, en); */
	   
	   if (en) {
	   	   if (SIntInstall(ctx->siqel, dce->dCtlSlot)) {
	   		   return err;
	   	   }
	   } else {
	   	   if (SIntRemove(ctx->siqel, dce->dCtlSlot)) {
	   		   return err;
	   	   }
	   }

	   write_reg(dce, DMA_IRQ_CTL, en ? revb(0x3) : revb(0x2)); // 0x2: always clear pending interrupt
	   ctx->irqen = en;
   }
   return noErr;
}
#endif


#pragma parameter __D0 cNuBusFPGASDCardCtl(__A0, __A1)
OSErr cNuBusFPGASDCardCtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct SDCardContext *ctx;
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0002); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->csCode); */
	
	ctx = *(struct SDCardContext**)dce->dCtlStorage;
	
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
	if (!(pb->ioTrap & (1<<noQueueBit)))
		IODone((DCtlPtr)dce, ret);
	return ret;
}
