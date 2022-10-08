#include "NuBusFPGARAMDskDrvr.h"

/* #include <DriverServices.h> */

__attribute__ ((section (".text.dskdriver"))) static inline void waitSome(unsigned long bound) {
	unsigned long i;
	for (i = 0 ; i < bound ; i++) {
		asm volatile("nop");
	}
}

__attribute__ ((section (".text.dskdriver"))) static void startOneOp(struct RAMDrvContext *ctx, const AuxDCEPtr dce) {
	if (ctx->op.blk_todo > 0) {
		ctx->op.blk_doing = ctx->op.blk_todo;
		if (ctx->op.blk_doing > 65535) { // fixme: read HW max
			ctx->op.blk_doing = 32768; // nice Po2
		}
		write_reg(dce, DMA_BLK_ADDR, revb(ctx->dma_blk_base + ctx->op.blk_offset));
		write_reg(dce, DMA_DMA_ADDR, revb(ctx->op.ioBuffer + (ctx->op.blk_done << ctx->dma_blk_size_shift)));
		write_reg(dce, DMA_BLK_CNT,  revb((ctx->op.write ? 0x80000000ul : 0x00000000ul) | ctx->op.blk_doing));
		ctx->op.blk_done += ctx->op.blk_doing;
		ctx->op.blk_todo -= ctx->op.blk_doing;
		ctx->op.blk_offset += ctx->op.blk_doing;
	}
}

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

/* Devices 1-34 (p54) */
#pragma parameter __D0 cNuBusFPGARAMDskPrime(__A0, __A1)
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
	} else {
		ret = offLinErr; /* r/w requested for an off-line drive */
		goto done;
	}

 done:
	if (!(pb->ioTrap & (1<<noQueueBit)))
		IODone((DCtlPtr)dce, ret);
	
	return ret;
}
