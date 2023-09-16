#include "NuBusFPGASDCardDrvr.h"

/* #include <DriverServices.h> */

inline void waitSome(unsigned long bound) {
  unsigned long i;
  for (i = 0 ; i < bound ; i++) {
    asm volatile("nop");
  }
}

__attribute__ ((section (".text.sddriver"))) static OSErr doSync(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce, struct SDCardContext *ctx) {
	OSErr ret = noErr;

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
	    if (abs_offset & 0x01FF) {
	      ret = paramErr;
	      *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x804) = abs_offset;
	      *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x808) = pb->ioReqCount;
	      goto done;
	    }
	    if (pb->ioReqCount & 0x01FF) {
	      ret = paramErr;
	      *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x804) = abs_offset;
	      *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x808) = pb->ioReqCount;
	      goto done;
	    }
	    if (sdcard_read(dce->dCtlDevBase, ctx, abs_offset >> 9, pb->ioReqCount >> 9, pb->ioBuffer)) {
	      ret = readErr;
	      goto done;
	    }
	  }
	  pb->ioActCount = pb->ioReqCount;
	  dce->dCtlPosition = abs_offset + pb->ioReqCount;
	  pb->ioPosOffset = dce->dCtlPosition;
	} else if ((pb->ioTrap & 0x00FF) == aWrCmd) {
	  if (abs_offset & 0x01FF) {
	    ret = paramErr;
	    *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x804) = abs_offset;
	    *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x808) = pb->ioReqCount;
	    goto done;
	  }
	  if (pb->ioReqCount & 0x01FF) {
	    ret = paramErr;
	    *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x804) = abs_offset;
	    *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x808) = pb->ioReqCount;
	    goto done;
	  }
	  if (sdcard_write(dce->dCtlDevBase, ctx, abs_offset >> 9, pb->ioReqCount >> 9, pb->ioBuffer)) {
	    ret = writErr;
	    goto done;
	  }
	  pb->ioActCount = pb->ioReqCount;
	  dce->dCtlPosition = abs_offset + pb->ioReqCount;
	  pb->ioPosOffset = dce->dCtlPosition;
	} else {
	  ret = paramErr;
	  goto done;
	}
 done:
	if (ret != noErr)
	  *(uint32_t*)(dce->dCtlDevBase | 0x00902000 | 0x800) = ret | (((pb->ioTrap & 0x00FF) == aRdCmd) ? 0x11000000 : 0x22000000);
	return ret;
}

/* Devices 1-34 (p54) */
#pragma parameter __D0 cNuBusFPGASDCardPrime(__A0, __A1)
OSErr cNuBusFPGASDCardPrime(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) {
	OSErr ret = noErr;
	struct SDCardContext *ctx;
	unsigned long abs_offset = 0;

	ctx = *(struct SDCardContext**)dce->dCtlStorage;
	
	if (ctx) {
	  ret = doSync(pb, dce, ctx);
	  if (!(pb->ioTrap & (1<<noQueueBit))) {
	    IODone((DCtlPtr)dce, ret);
	  }
	  goto done;
	} else {
	  ret = offLinErr;  /* r/w requested for an off-line drive */
	  if (!(pb->ioTrap & (1<<noQueueBit)))
	    IODone((DCtlPtr)dce, ret);
	  goto done;
	}

 done:
	return ret;
}

