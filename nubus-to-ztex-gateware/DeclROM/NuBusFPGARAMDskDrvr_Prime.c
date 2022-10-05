#include "NuBusFPGARAMDskDrvr.h"

/* #include <DriverServices.h> */

static inline void waitSome(unsigned long bound) {
	unsigned long i;
	for (i = 0 ; i < bound ; i++) {
		asm volatile("nop");
	}
}

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
#ifdef ENABLE_DMA
				/* write_reg(dce, GOBOFB_DEBUG, 0xD1580000); */
				/* write_reg(dce, GOBOFB_DEBUG, (unsigned long)pb->ioBuffer); */
				/* write_reg(dce, GOBOFB_DEBUG, pb->ioReqCount); */
				if ((((unsigned long)pb->ioBuffer & ctx->dma_blk_size_mask) == 0) &&
					(((unsigned long)pb->ioReqCount & ctx->dma_blk_size_mask) == 0) &&
					(((unsigned long)abs_offset & ctx->dma_blk_size_mask) == 0)) {
					unsigned long blk_todo = (pb->ioReqCount >> ctx->dma_blk_size_shift), blk_doing, blk_done;
					unsigned long count, max_count, delay;
					unsigned long blk_cnt, status;
					blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
					status =  revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
					blk_done = 0;
					while (blk_todo > 0) {
						blk_doing = blk_todo;
						if (blk_doing > 65535) { // fixme: read HW max
							blk_doing = 32768; // nice Po2
						}
						max_count = 32 * blk_doing;
						delay = (blk_doing >> 4);
						if (delay > 65536)
							delay = 65536;
						if ((blk_cnt == 0) && (status == 0)) {
							write_reg(dce, DMA_BLK_ADDR, revb(ctx->dma_blk_base + (abs_offset >> ctx->dma_blk_size_shift) + blk_done));
							write_reg(dce, DMA_DMA_ADDR, revb(pb->ioBuffer + (blk_done << ctx->dma_blk_size_shift)));
							write_reg(dce, DMA_BLK_CNT,  revb(0x00000000ul | blk_doing));
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
						}
						blk_done += blk_doing;
						blk_todo -= blk_doing;
					}
					if (blk_cnt || status) {
						return readErr;
						BlockMoveData((superslot + abs_offset), pb->ioBuffer, pb->ioReqCount);
					}
#ifdef DMA_DEBUG
					else {
						unsigned int k = 0;
						while ((((unsigned long*)(superslot))[5] == 0x12345678) && (((unsigned long*)(superslot))[9] == 0x87654321) && (k < 7)) {
							k++;
							superslot += 64;
						}
						if ((((unsigned long*)(superslot))[5] != 0x12345678) || (((unsigned long*)(superslot))[9] != 0x87654321)) {
							unsigned int i;
							for (i = 0 ; i < pb->ioReqCount ; i+=4 ) {
								if ((*(unsigned long*)(superslot + abs_offset + i)) != (*(unsigned long*)((char*)pb->ioBuffer + i))) {
									((unsigned long*)(superslot))[0] = ctx->dma_blk_size;
									((unsigned long*)(superslot))[1] = ctx->dma_blk_size_mask;
									((unsigned long*)(superslot))[2] = ctx->dma_blk_size_shift;
									((unsigned long*)(superslot))[3] = ctx->dma_blk_base;
									((unsigned long*)(superslot))[4] = ctx->dma_mem_size;
									((unsigned long*)(superslot))[5] = 0x12345678;
									((unsigned long*)(superslot))[6] = pb->ioBuffer;
									((unsigned long*)(superslot))[7] = pb->ioReqCount;
									((unsigned long*)(superslot))[8] = abs_offset;
									((unsigned long*)(superslot))[9] = 0x87654321;
									((unsigned long*)(superslot))[10] = i;
									((unsigned long*)(superslot))[11] = (*(unsigned long*)(superslot + abs_offset + i));
									((unsigned long*)(superslot))[12] = (*(unsigned long*)((char*)pb->ioBuffer + i));
									((unsigned long*)(superslot))[13] = (*(unsigned long*)(superslot + abs_offset + i + 4));
									((unsigned long*)(superslot))[14] = (*(unsigned long*)((char*)pb->ioBuffer + i + 4));
									i += 4;
								}
							}
						}
					}
#endif
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
					unsigned long blk_todo = (pb->ioReqCount >> ctx->dma_blk_size_shift), blk_doing, blk_done;
					unsigned long count, max_count, delay;
					unsigned long blk_cnt, status;
					blk_cnt = revb(read_reg(dce, DMA_BLK_CNT)) & 0xFFFF;
					status = revb(read_reg(dce, DMA_STATUS)) & DMA_STATUS_CHECK_BITS;
					blk_done = 0;
					while (blk_todo > 0) {
						blk_doing = blk_todo;
						if (blk_doing > 65535) { // fixme: read HW max
							blk_doing = 32768; // nice Po2
						}
						max_count = 32 * blk_doing;
						delay = (blk_doing >> 4);
						if (delay > 65536)
							delay = 65536;
						if ((blk_cnt == 0) && (status == 0)) {
							write_reg(dce, DMA_BLK_ADDR, revb(ctx->dma_blk_base + (abs_offset >> ctx->dma_blk_size_shift) + blk_done));
							write_reg(dce, DMA_DMA_ADDR, revb(pb->ioBuffer + (blk_done << ctx->dma_blk_size_shift)));
							write_reg(dce, DMA_BLK_CNT,  revb(0x80000000ul | blk_doing));
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
						}
						blk_done += blk_doing;
						blk_todo -= blk_doing;
					}
					if (blk_cnt || status) {
						return writErr;
						BlockMoveData(pb->ioBuffer, (superslot + abs_offset), pb->ioReqCount);
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
		IODone(dce, ret);
	
	return ret;
}
