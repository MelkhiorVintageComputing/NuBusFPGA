#include "NuBusFPGARAMDskDrvr.h"

/* #include <DriverServices.h> */

__attribute__ ((section (".text.dskdriver"))) static inline void waitSome(unsigned long bound) {
	unsigned long i;
	for (i = 0 ; i < bound ; i++) {
		asm volatile("nop");
	}
}

#ifdef ENABLE_DMA
__attribute__ ((section (".text.dskdriver"))) static void startOneOp(struct RAMDrvContext *ctx, const AuxDCEPtr dce) {
	if (ctx->op.blk_todo > 0) {
		ctx->op.blk_doing = ctx->op.blk_todo;
		if (ctx->op.blk_doing > 65535) { // fixme: read HW max
			ctx->op.blk_doing = 32768; // nice Po2
		}
		write_reg(dce, DMA_BLK_ADDR, revb(ctx->dma_blk_base + ctx->op.blk_offset));
		write_reg(dce, DMA_DMA_ADDR, revb(ctx->op.ioBuffer + (ctx->op.blk_done << ctx->dma_blk_size_shift)));
		ctx->op.blk_done += ctx->op.blk_doing;
		ctx->op.blk_todo -= ctx->op.blk_doing;
		ctx->op.blk_offset += ctx->op.blk_doing;
		write_reg(dce, DMA_BLK_CNT,  revb((ctx->op.write ? 0x80000000ul : 0x00000000ul) | ctx->op.blk_doing));
	}
}
#endif

#ifdef ENABLE_DMA
__attribute__ ((section (".text.dskdriver"))) static OSErr waitForHW(struct RAMDrvContext *ctx, const AuxDCEPtr dce) {
	unsigned long count, max_count, delay;
	unsigned long blk_cnt, status;
	OSErr ret = noErr;
	max_count = 32 * ctx->op.blk_doing;
	delay = (ctx->op.blk_doing >> 4);
	if (delay > 65536)
		delay = 65536;
	waitSome(delay);
	count = 0;
	blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
	status = revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
	while (((blk_cnt != 0) ||
			(status != 0)) &&
		   (count < max_count)) {
		count ++;
		waitSome(delay);
		if (blk_cnt) blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
		if (status) status = revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
	}
	if (blk_cnt || status) {
		ret = ctx->op.write ? writErr : readErr;
	}
	return ret;
}
#endif

#ifdef ENABLE_DMA
/* see the comment for the FB irq */
#pragma parameter __D0 dskIrq(__A1)
__attribute__ ((section (".text.dskdriver"))) short dskIrq(const long sqParameter) {
	register unsigned long p_D1 asm("d1"), p_D2 asm("d2");
	AuxDCEPtr dce;
	struct RAMDrvContext *ctx;
	unsigned int irq;
	short ret;
	asm volatile("" : "+d" (p_D1), "+d" (p_D2));
	dce = (AuxDCEPtr)sqParameter;
	ctx = *(struct RAMDrvContext**)dce->dCtlStorage;
	ret = 0;
	irq = revb(read_reg(dce, DMA_IRQSTATUS));
	if (irq & 1) {
		unsigned int irqctrl = revb(read_reg(dce, DMA_IRQ_CTL));
		irqctrl |= 0x2; // irq clear
		write_reg(dce, DMA_IRQ_CTL, revb(irqctrl));
		if (ctx->op.blk_todo > 0) {
			startOneOp(ctx, dce);
		} else {
			if (ctx->op.blk_doing > 0) {
				ctx->op.blk_doing = 0; // reset just in case
				IODone((DCtlPtr)dce, noErr);
			}
		}
		ret = 1;
	}
	asm volatile("" : : "d" (p_D1), "d" (p_D2));
	return ret;
}
#endif

#ifdef ENABLE_DMA
__attribute__ ((section (".text.dskdriver"))) static OSErr doAsync(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce, struct RAMDrvContext *ctx) {
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
			unsigned long blk_cnt, status;
			blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
			status =  revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
			if ((blk_cnt == 0) && (status == 0)) {
				ctx->op.blk_todo = pb->ioReqCount >> ctx->dma_blk_size_shift;
				ctx->op.blk_done = 0;
				ctx->op.blk_offset = abs_offset >> ctx->dma_blk_size_shift;
				ctx->op.ioBuffer = pb->ioBuffer;
				ctx->op.write = 0;
		/* should we do it now ? */
		pb->ioActCount = pb->ioReqCount;
		dce->dCtlPosition = abs_offset + pb->ioReqCount;
		pb->ioPosOffset = dce->dCtlPosition;
				if (ctx->op.blk_todo > 0) {
					startOneOp(ctx, dce);
					goto done;
				}
			}
			if (blk_cnt || status) {
				ret = readErr;
				goto done;
			}
		}
	} else if ((pb->ioTrap & 0x00FF) == aWrCmd) {
		unsigned long blk_cnt, status;
		blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
		status =  revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
		if ((blk_cnt == 0) && (status == 0)) {
			ctx->op.blk_todo = pb->ioReqCount >> ctx->dma_blk_size_shift;
			ctx->op.blk_done = 0;
			ctx->op.blk_offset = abs_offset >> ctx->dma_blk_size_shift;
			ctx->op.ioBuffer = pb->ioBuffer;
			ctx->op.write = 1;
		/* should we do it now ? */
		pb->ioActCount = pb->ioReqCount;
		dce->dCtlPosition = abs_offset + pb->ioReqCount;
		pb->ioPosOffset = dce->dCtlPosition;
			if (ctx->op.blk_todo > 0) {
				startOneOp(ctx, dce);
				goto done;
			}
		}
		if (blk_cnt || status) {
			ret = writErr;
			goto done;
		}
	} else {
		ret = paramErr;
		goto done;
	}

 done:
	return ret;
}
#endif // ENABLE_DMA

__attribute__ ((section (".text.dskdriver"))) static OSErr doSync(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce, struct RAMDrvContext *ctx) {
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
#ifdef ENABLE_DMA
			/* write_reg(dce, GOBOFB_DEBUG, 0xD1580000); */
			/* write_reg(dce, GOBOFB_DEBUG, (unsigned long)pb->ioBuffer); */
			/* write_reg(dce, GOBOFB_DEBUG, pb->ioReqCount); */
			if ((((unsigned long)pb->ioBuffer & ctx->dma_blk_size_mask) == 0) &&
				(((unsigned long)pb->ioReqCount & ctx->dma_blk_size_mask) == 0) &&
				(((unsigned long)abs_offset & ctx->dma_blk_size_mask) == 0)) {
				unsigned long blk_cnt, status;
				blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
				status =  revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
				if ((blk_cnt == 0) && (status == 0)) {
					ctx->op.blk_todo = pb->ioReqCount >> ctx->dma_blk_size_shift;
					ctx->op.blk_done = 0;
					ctx->op.blk_offset = abs_offset >> ctx->dma_blk_size_shift;
					ctx->op.ioBuffer = pb->ioBuffer;
					ctx->op.write = 0;
					while (ctx->op.blk_todo > 0) {
						startOneOp(ctx, dce);
						ret = waitForHW(ctx, dce);
						if (ret != noErr)
							goto done;
					}
				}
				if (blk_cnt || status) {
					ret = readErr;
					goto done;
				}
			} else
#endif
				{
					BlockMoveData((superslot + abs_offset), pb->ioBuffer, pb->ioReqCount);
				}
		}
		pb->ioActCount = pb->ioReqCount;
		dce->dCtlPosition = abs_offset + pb->ioReqCount;
		pb->ioPosOffset = dce->dCtlPosition;
	} else if ((pb->ioTrap & 0x00FF) == aWrCmd) {
#ifdef ENABLE_DMA
		/* write_reg(dce, GOBOFB_DEBUG, 0xD1580001); */
		/* write_reg(dce, GOBOFB_DEBUG, (unsigned long)pb->ioBuffer); */
		/* write_reg(dce, GOBOFB_DEBUG, pb->ioReqCount); */
		if ((((unsigned long)pb->ioBuffer & ctx->dma_blk_size_mask) == 0) &&
			(((unsigned long)pb->ioReqCount & ctx->dma_blk_size_mask) == 0) &&
			(((unsigned long)abs_offset & ctx->dma_blk_size_mask) == 0)) {
			unsigned long blk_cnt, status;
			blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
			status =  revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
			if ((blk_cnt == 0) && (status == 0)) {
				ctx->op.blk_todo = pb->ioReqCount >> ctx->dma_blk_size_shift;
				ctx->op.blk_done = 0;
				ctx->op.blk_offset = abs_offset >> ctx->dma_blk_size_shift;
				ctx->op.ioBuffer = pb->ioBuffer;
				ctx->op.write = 1;
				while (ctx->op.blk_todo > 0) {
					startOneOp(ctx, dce);
					ret = waitForHW(ctx, dce);
					if (ret != noErr)
						goto done;
				}
			}
			if (blk_cnt || status) {
				ret = writErr;
				goto done;
			}
		} else
#endif
			{
				BlockMoveData(pb->ioBuffer, (superslot + abs_offset), pb->ioReqCount);
			}
		pb->ioActCount = pb->ioReqCount;
		dce->dCtlPosition = abs_offset + pb->ioReqCount;
		pb->ioPosOffset = dce->dCtlPosition;
	} else {
		ret = paramErr;
		goto done;
	}

 done:
	ctx->op.blk_doing = 0;
	return ret;
}

/* Devices 1-34 (p54) */
#pragma parameter __D0 cNuBusFPGARAMDskPrime(__A0, __A1)
OSErr cNuBusFPGARAMDskPrime(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct RAMDrvContext *ctx;
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
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0003); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioTrap); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioPosMode); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioReqCount); */
	/* write_reg(dce, GOBOFB_DEBUG, pb->ioPosOffset); */

	ctx = *(struct RAMDrvContext**)dce->dCtlStorage;
	
	if (ctx) {
#ifdef ENABLE_DMA
		if ((((unsigned long)pb->ioBuffer & ctx->dma_blk_size_mask) == 0) &&
			(((unsigned long)pb->ioReqCount & ctx->dma_blk_size_mask) == 0) &&
			(((unsigned long)abs_offset & ctx->dma_blk_size_mask) == 0) &&
			(!(pb->ioTrap & (1<<noQueueBit)))) {
			ret = changeRAMDskIRQ(dce, 1, (pb->ioTrap & 0x00FF) == aWrCmd ? writErr : readErr);
			if (ret != noErr) {
				IODone((DCtlPtr)dce, ret);
				goto done;
			}
			// DMA-ifiable & queuable, go async
			ret = doAsync(pb, dce, ctx);
			// no IODone if ongoing, done at interrupt time
			if (ret != noErr)
				IODone((DCtlPtr)dce, ret);
			goto done;
		} else
#endif
		{
#ifdef ENABLE_DMA
			ret = changeRAMDskIRQ(dce, 0, (pb->ioTrap & 0x00FF) == aWrCmd ? writErr : readErr);
#endif
			if (ret)
				goto done;
			ret = doSync(pb, dce, ctx);
			if (!(pb->ioTrap & (1<<noQueueBit))) {
				IODone((DCtlPtr)dce, ret);
			}
			goto done;
		}
	} else {
		ret = offLinErr; /* r/w requested for an off-line drive */
		if (!(pb->ioTrap & (1<<noQueueBit)))
			IODone((DCtlPtr)dce, ret);
		goto done;
	}

 done:
	return ret;
}
