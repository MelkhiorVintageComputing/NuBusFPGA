#include "NuBusFPGASDCardDrvr.h"

#include <Disks.h>

/* FYI, missing in library with Retro68 */
/* void AddDrive(short drvrRefNum, short drvNum, DrvQElPtr qEl); */

/* re-implement with Retro68 features */
/* drVNum to high-order bits of num, drvrRefNum in low-order */
/* not sure how to do "parameter" without output ? */
#pragma parameter __D0 AddDrive(__D0, __A0)
__attribute__ ((section (".text.sddriver"))) static inline int dupAddDrive(unsigned long num, DrvQElPtr qEl) {
	asm volatile(".word 0xA04E" : : "d" (num), "a" (qEl));
	return num; // should cost nothing, num is already in D0
}

static int sdcard_init(struct SDCardContext* sdcc, uint32_t sc) __attribute__ ((section (".text.sddriver")));

#include <ROMDefs.h>

#pragma parameter __D0 cNuBusFPGASDCardOpen(__A0, __A1)
OSErr cNuBusFPGASDCardOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	DrvSts2 *dsptr; // pointer to the DrvSts2 in our context
	int drvnum = 1;
	struct SDCardContext *ctx;
	OSErr ret = noErr;
	char busMode;
	char slot;
	
	busMode = 1;
	SwapMMUMode ( &busMode ); // to32 // this likely won't work on older MacII ???

	if (dce->dCtlDevBase == 0) { // for some unknown reason, we get an empty dCtlDevBase...
		if ((dce->dCtlSlot > 0xE) || (dce->dCtlSlot < 0x9)) { // safety net
			SpBlock				mySpBlock;
			SInfoRecord			mySInfoRecord;
			mySpBlock.spResult = (long)&mySInfoRecord;
			
			mySpBlock.spSlot = 0x9; // start at first
			mySpBlock.spID = 0;
			mySpBlock.spExtDev = 0;
			mySpBlock.spCategory = catProto;
			mySpBlock.spCType = 0x1000; // typeDrive;
			mySpBlock.spDrvrSW = drSwApple;
			mySpBlock.spDrvrHW = 0xbeec; // DrHwNuBusFPGADsk
			mySpBlock.spTBMask = 0;
			ret = SNextTypeSRsrc(&mySpBlock);
			if (ret)
				goto done;
			slot = mySpBlock.spSlot;
		} else {
			slot = dce->dCtlSlot;
		}
		dce->dCtlDevBase = 0xF0000000ul | ((unsigned long)slot << 24);
	}
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0000); */
	/* write_reg(dce, GOBOFB_DEBUG, dce->dCtlSlot); */

	if (dce->dCtlStorage == nil) {
		DrvQElPtr dq;
		for(dq = (DrvQElPtr)(GetDrvQHdr())->qHead; dq; dq = (DrvQElPtr)dq->qLink) {
			if (dq->dQDrive >= drvnum)
				drvnum = dq->dQDrive+1;
		}
		
		ReserveMemSys(sizeof(struct SDCardContext));
		dce->dCtlStorage = NewHandleSysClear(sizeof(struct SDCardContext));
		if (dce->dCtlStorage == nil) {
			ret = openErr;
			goto done;
		}
		
		HLock(dce->dCtlStorage);

		ctx = *(struct SDCardContext **)dce->dCtlStorage;
		ctx->slot = slot;
		ctx->toto = 0; // removeme

		/* init the SDCard, this will also fill out dsptr->driveSize & dsptr->driveS1 */
		if (!sdcard_init(ctx, dce->dCtlDevBase)) {
		  ret = openErr;
		  HUnlock(dce->dCtlStorage);
		  DisposeHandle(dce->dCtlStorage);
		  dce->dCtlStorage = NULL;
		  goto done;
		}

		ctx->dma_blk_size = exchange_with_sd_blk_size_read(dce->dCtlDevBase);
		ctx->dma_blk_size_mask = ctx->dma_blk_size - 1; // size is Po2
		ctx->dma_blk_size_shift = 0;
		while ((1 << ctx->dma_blk_size_shift) < ctx->dma_blk_size) // fixme
			   ctx->dma_blk_size_shift++;
		ctx->dma_blk_per_sdblk_lshift = 9 - ctx->dma_blk_size_shift;
		ctx->dma_blk_per_sdblk = 1 << ctx->dma_blk_per_sdblk_lshift; // 512 / ctx->dma_blk_size
		
		dsptr = &ctx->drvsts;
		// dsptr->track /* current track */
		dsptr->writeProt = 0; /* bit 7 = 1 if volume is locked */
		dsptr->diskInPlace = 8; /* disk in drive */
		// dsptr->installed /* drive installed */
		// dsptr->sides /* -1 for 2-sided, 0 for 1-sided */
		// dsptr->QLink /* next queue entry */
		dsptr->qType = 1; /* 1 for HD20 */ /* Files 2-85 (p173) : 1 to enable S1 */
		dsptr->dQDrive = drvnum; /* drive number */
		dsptr->dQRefNum = dce->dCtlRefNum; /* driver reference number */
		// dsptr->dQFSID /* file system ID */
		/* driveSize & driveS1 filled by sdcard_init */
		//dsptr->driveSize = ((DRIVE_SIZE_BYTES/512ul) & 0x0000FFFFul); /* (no comments in Disks.h) */
		//dsptr->driveS1 =   ((DRIVE_SIZE_BYTES/512ul) & 0xFFFF0000ul) >> 16; /* */
		// dsptr->driveType
		// dsptr->driveManf
		// dsptr->driveChar
		// dsptr->driveMisc
		
	//	MyAddDrive(dsptr->dQRefNum, drvnum, (DrvQElPtr)&dsptr->qLink);

	//	write_reg(dce, GOBOFB_DEBUG, 0x0000DEAD);

		// add the drive
		//MyAddDrive(dsptr->dQRefNum, drvnum, (DrvQElPtr)&dsptr->qLink);
		dupAddDrive((dsptr->dQRefNum & 0xFFFF) | (drvnum << 16), (DrvQElPtr)&dsptr->qLink);
		
#if 0
		ctx->dma_blk_size = revb( read_reg(dce, DMA_BLK_SIZE) );
		ctx->dma_blk_size_mask = ctx->dma_blk_size - 1; // size is Po2
		ctx->dma_blk_size_shift = 0;
		while ((1 << ctx->dma_blk_size_shift) < ctx->dma_blk_size) // fixme
			   ctx->dma_blk_size_shift++;
		ctx->dma_blk_base = revb( read_reg(dce, DMA_BLK_BASE) );
		ctx->dma_mem_size = revb( read_reg(dce, DMA_MEM_SIZE) );
		/* write_reg(dce, GOBOFB_DEBUG, 0xD1580002); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size_mask); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_size_shift); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_blk_base); */
		/* write_reg(dce, GOBOFB_DEBUG, ctx->dma_mem_size); */

		{
			SlotIntQElement *siqel = (SlotIntQElement *)NewPtrSysClear(sizeof(SlotIntQElement));
	   		
			if (siqel == NULL) {
				return openErr;
			}
			
			siqel->sqType = sIQType;
			siqel->sqPrio = 7;
			siqel->sqAddr = dskIrq;
			siqel->sqParm = (long)dce;
			ctx->siqel = siqel;
			ctx->irqen = 0;

			ctx->op.blk_todo = 0;
			ctx->op.blk_done = 0;
			ctx->op.blk_offset = 0;
			ctx->op.blk_doing = 0;
			ctx->op.ioBuffer = 0;
			ctx->op.write = 0;
		}
#endif

		// auto-mount
		if (0) {
			ParamBlockRec pbr;
			pbr.volumeParam.ioVRefNum = dsptr->dQDrive;
			ret = PBMountVol(&pbr);
		}
	}
		
	SwapMMUMode ( &busMode ); 

 done:
	return ret;
}

#pragma parameter __D0 cNuBusFPGASDCardClose(__A0, __A1)
OSErr cNuBusFPGASDCardClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	struct SDCardContext *ctx = *(struct SDCardContext**)dce->dCtlStorage;
	
	/* dce->dCtlDevBase = 0xfc000000; */
	
	/* write_reg(dce, GOBOFB_DEBUG, 0xDEAD0001); */
	
	if (dce->dCtlStorage) {
		//DisposePtr((Ptr)ctx->siqel);
		/* HUnlock(dce->dCtlStorage); */ /* not needed before DisposeHandle */
		DisposeHandle(dce->dCtlStorage);
		dce->dCtlStorage = NULL;
	}
	return ret;
}

/*-----------------------------------------------------------------------*/
/* Helpers                                                               */
/*-----------------------------------------------------------------------*/

#define max(x, y) (((x) > (y)) ? (x) : (y))
#define min(x, y) (((x) < (y)) ? (x) : (y))

/* In MacOS
   Delay(unsigned long numTicks, unsigned long *  finalTicks)
   has ticks in 1/60th of a second or 16.6666 ms
*/

/* in NetBSD/sparc busy_wait is 1ms * d */
void busy_wait(int d) {
  waitSome(d * 20000); // improveme
  return;
}
/* in NetBSD/sparc delay is 1us * d */
void delay(int d) {
  waitSome(d * 20); // improveme
  return;
}

/*-----------------------------------------------------------------------*/
/* SDCard command helpers                                                */
/*-----------------------------------------------------------------------*/

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_wait_cmd_done(uint32_t sc) {
	unsigned int event;
#ifdef SDCARD_DEBUG
	uint32_t r[SD_CMD_RESPONSE_SIZE/4];
#endif
	for (;;) {
		event = sdcore_cmd_event_read(sc);
#ifdef SDCARD_DEBUG
		printf("cmdevt: %08x\n", event);
#endif
		delay(10);
		if (event & 0x1)
			break;
	}
#ifdef SDCARD_DEBUG
	csr_rd_buf_uint32(sc, sc->sc_bhregs_sdcore + (CSR_SDCORE_CMD_RESPONSE_ADDR - CSR_SDCORE_BASE), r, SD_CMD_RESPONSE_SIZE/4);
	printf("%08x %08x %08x %08x\n", r[0], r[1], r[2], r[3]);
#endif
	if (event & 0x4)
		return SD_TIMEOUT;
	if (event & 0x8)
		return SD_CRCERROR;
	return SD_OK;
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_wait_data_done(uint32_t sc) {
	unsigned int event;
	for (;;) {
		event = sdcore_data_event_read(sc);
#ifdef SDCARD_DEBUG
		printf("dataevt: %08x\n", event);
#endif
		if (event & 0x1)
			break;
		delay(10);
	}
	if (event & 0x4)
		return SD_TIMEOUT;
	else if (event & 0x8)
		return SD_CRCERROR;
	return SD_OK;
}

/*-----------------------------------------------------------------------*/
/* SDCard clocker functions                                              */
/*-----------------------------------------------------------------------*/

/* round up to closest power-of-two */
__attribute__ ((section (".text.sddriver"))) static inline uint32_t pow2_round_up(uint32_t r) {
	r--;
	r |= r >>  1;
	r |= r >>  2;
	r |= r >>  4;
	r |= r >>  8;
	r |= r >> 16;
	r++;
	return r;
}

__attribute__ ((section (".text.sddriver"))) static inline void sdcard_set_clk_freq(uint32_t sc, uint32_t clk_freq, int show) {
	uint32_t divider;
	divider = clk_freq ? CONFIG_CLOCK_FREQUENCY/clk_freq : 256;
	divider = pow2_round_up(divider);
	divider = min(max(divider, 2), 256);
#ifdef SDCARD_DEBUG
	show = 1;
#endif
	if (show) {
		/* this is the *effective* new clk_freq */
		clk_freq = CONFIG_CLOCK_FREQUENCY/divider;
		/*
		  printf("Setting SDCard clk freq to ");
		if (clk_freq > 1000000)
			printf("%d MHz\n", clk_freq/1000000);
		else
			printf("%d KHz\n", clk_freq/1000);
		*/
	}
	sdphy_clocker_divider_write(sc, divider);
}

/*-----------------------------------------------------------------------*/
/* SDCard commands functions                                             */
/*-----------------------------------------------------------------------*/

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_send_command(uint32_t sc, uint32_t arg, uint8_t cmd, uint8_t rsp) {
	sdcore_cmd_argument_write(sc, arg);
	sdcore_cmd_command_write(sc, (cmd << 8) | rsp);
	sdcore_cmd_send_write(sc, 1);
	return sdcard_wait_cmd_done(sc);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_go_idle(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("CMD0: GO_IDLE\n");
#endif
	return sdcard_send_command(sc, 0, 0, SDCARD_CTRL_RESPONSE_NONE);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_send_ext_csd(uint32_t sc) {
	uint32_t arg = 0x000001aa;
#ifdef SDCARD_DEBUG
	printf("CMD8: SEND_EXT_CSD, arg: 0x%08x\n", arg);
#endif
	return sdcard_send_command(sc, arg, 8, SDCARD_CTRL_RESPONSE_SHORT);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_app_cmd(uint32_t sc, uint16_t rca) {
#ifdef SDCARD_DEBUG
	printf("CMD55: APP_CMD\n");
#endif
	return sdcard_send_command(sc, rca << 16, 55, SDCARD_CTRL_RESPONSE_SHORT);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_app_send_op_cond(uint32_t sc, int hcs) {
	uint32_t arg = 0x10ff8000;
	if (hcs)
		arg |= 0x60000000;
#ifdef SDCARD_DEBUG
	printf("ACMD41: APP_SEND_OP_COND, arg: %08x\n", arg);
#endif
	return sdcard_send_command(sc, arg, 41, SDCARD_CTRL_RESPONSE_SHORT_BUSY);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_all_send_cid(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("CMD2: ALL_SEND_CID\n");
#endif
	return sdcard_send_command(sc, 0, 2, SDCARD_CTRL_RESPONSE_LONG);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_set_relative_address(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("CMD3: SET_RELATIVE_ADDRESS\n");
#endif
	return sdcard_send_command(sc, 0, 3, SDCARD_CTRL_RESPONSE_SHORT);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_send_cid(uint32_t sc, uint16_t rca) {
#ifdef SDCARD_DEBUG
	printf("CMD10: SEND_CID\n");
#endif
	return sdcard_send_command(sc, rca << 16, 10, SDCARD_CTRL_RESPONSE_LONG);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_send_csd(uint32_t sc, uint16_t rca) {
#ifdef SDCARD_DEBUG
	printf("CMD9: SEND_CSD\n");
#endif
	return sdcard_send_command(sc, rca << 16, 9, SDCARD_CTRL_RESPONSE_LONG);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_select_card(uint32_t sc, uint16_t rca) {
#ifdef SDCARD_DEBUG
	printf("CMD7: SELECT_CARD\n");
#endif
	return sdcard_send_command(sc, rca << 16, 7, SDCARD_CTRL_RESPONSE_SHORT_BUSY);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_app_set_bus_width(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("ACMD6: SET_BUS_WIDTH\n");
#endif
	return sdcard_send_command(sc, 2, 6, SDCARD_CTRL_RESPONSE_SHORT);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_switch(uint32_t sc, unsigned int mode, unsigned int group, unsigned int value) {
	unsigned int arg;
	arg = (mode << 31) | 0xffffff;
	arg &= ~(0xf << (group * 4));
	arg |= value << (group * 4);
	//device_printf(sc->dk.sc_dev, "switch arg is 0x%08x\n", arg);
#ifdef SDCARD_DEBUG
	printf("CMD6: SWITCH_FUNC\n");
#endif
	sdcore_block_length_write(sc, 64);
	sdcore_block_count_write(sc, 1);
	while (sdcard_send_command(sc, arg, 6,
		(SDCARD_CTRL_DATA_TRANSFER_READ << 5) |
		SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return sdcard_wait_data_done(sc);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_app_send_scr(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("CMD51: APP_SEND_SCR\n");
#endif
	sdcore_block_length_write(sc, 8);
	sdcore_block_count_write(sc, 1);
	while (sdcard_send_command(sc, 0, 51,
		(SDCARD_CTRL_DATA_TRANSFER_READ << 5) |
		SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return sdcard_wait_data_done(sc);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_app_set_blocklen(uint32_t sc, unsigned int blocklen) {
#ifdef SDCARD_DEBUG
	printf("CMD16: SET_BLOCKLEN\n");
#endif
	return sdcard_send_command(sc, blocklen, 16, SDCARD_CTRL_RESPONSE_SHORT);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_write_single_block(uint32_t sc, unsigned int blockaddr) {
#ifdef SDCARD_DEBUG
	printf("CMD24: WRITE_SINGLE_BLOCK\n");
#endif
	sdcore_block_length_write(sc, 512);
	sdcore_block_count_write(sc, 1);
	while (sdcard_send_command(sc, blockaddr, 24,
	    (SDCARD_CTRL_DATA_TRANSFER_WRITE << 5) |
	    SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return SD_OK;
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_write_multiple_block(uint32_t sc, unsigned int blockaddr, unsigned int blockcnt) {
#ifdef SDCARD_DEBUG
	printf("CMD25: WRITE_MULTIPLE_BLOCK\n");
#endif
	sdcore_block_length_write(sc, 512);
	sdcore_block_count_write(sc, blockcnt);
	while (sdcard_send_command(sc, blockaddr, 25,
	    (SDCARD_CTRL_DATA_TRANSFER_WRITE << 5) |
	    SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return SD_OK;
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_read_single_block(uint32_t sc, unsigned int blockaddr) {
#ifdef SDCARD_DEBUG
	printf("CMD17: READ_SINGLE_BLOCK\n");
#endif
	sdcore_block_length_write(sc, 512);
	sdcore_block_count_write(sc, 1);
	while (sdcard_send_command(sc, blockaddr, 17,
	    (SDCARD_CTRL_DATA_TRANSFER_READ << 5) |
	    SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return sdcard_wait_data_done(sc);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_read_multiple_block(uint32_t sc, unsigned int blockaddr, unsigned int blockcnt) {
#ifdef SDCARD_DEBUG
	printf("CMD18: READ_MULTIPLE_BLOCK\n");
#endif
	sdcore_block_length_write(sc, 512);
	sdcore_block_count_write(sc, blockcnt);
	while (sdcard_send_command(sc, blockaddr, 18,
		(SDCARD_CTRL_DATA_TRANSFER_READ << 5) |
		SDCARD_CTRL_RESPONSE_SHORT) != SD_OK);
	return sdcard_wait_data_done(sc);
}

__attribute__ ((section (".text.sddriver"))) static inline int sdcard_stop_transmission(uint32_t sc) {
#ifdef SDCARD_DEBUG
	printf("CMD12: STOP_TRANSMISSION\n");
#endif
	return sdcard_send_command(sc, 0, 12, SDCARD_CTRL_RESPONSE_SHORT_BUSY);
}

#if 0
__attribute__ ((section (".text.sddriver"))) static inline int sdcard_send_status(uint32_t sc, uint16_t rca) {
#ifdef SDCARD_DEBUG
	printf("CMD13: SEND_STATUS\n");
#endif
	return sdcard_send_command(sc, rca << 16, 13, SDCARD_CTRL_RESPONSE_SHORT);
}
#endif

#if 0
__attribute__ ((section (".text.sddriver"))) static inline int sdcard_set_block_count(uint32_t sc, unsigned int blockcnt) {
#ifdef SDCARD_DEBUG
	printf("CMD23: SET_BLOCK_COUNT\n");
#endif
	return sdcard_send_command(sc, blockcnt, 23, SDCARD_CTRL_RESPONSE_SHORT);
}
#endif

__attribute__ ((section (".text.sddriver"))) static inline uint16_t sdcard_decode_rca(uint32_t sc) {
	uint32_t r[SD_CMD_RESPONSE_SIZE/4];
	csr_rd_buf_uint32(sc, CSR_SDCORE_CMD_RESPONSE_ADDR, r, SD_CMD_RESPONSE_SIZE/4);
	return (r[3] >> 16) & 0xffff;
}

__attribute__ ((section (".text.sddriver"))) static inline void sdcard_decode_cid(uint32_t sc) {
	uint32_t r[SD_CMD_RESPONSE_SIZE/4];
	csr_rd_buf_uint32(sc, CSR_SDCORE_CMD_RESPONSE_ADDR, r, SD_CMD_RESPONSE_SIZE/4);
	/* aprint_normal_dev(sc->dk.sc_dev, */
	/* 	"CID Register: 0x%08x%08x%08x%08x " */
	/* 	"Manufacturer ID: 0x%x " */
	/* 	"Application ID 0x%x " */
	/* 	"Product name: %c%c%c%c%c " */
	/* 	"CRC: %02x " */
	/* 	"Production date(m/yy): %d/%d " */
	/* 	"PSN: %08x " */
	/* 	"OID: %c%c\n", */
	/* 	r[0], r[1], r[2], r[3], */
	/* 	(r[0] >> 16) & 0xffff, */
	/* 	r[0] & 0xffff, */
	/* 	(r[1] >> 24) & 0xff, (r[1] >> 16) & 0xff, */
	/* 	(r[1] >>  8) & 0xff, (r[1] >>  0) & 0xff, (r[2] >> 24) & 0xff, */
	/* 	r[3] & 0xff, */
	/* 	(r[3] >>  8) & 0x0f, (r[3] >> 12) & 0xff, */
	/* 	(r[3] >> 24) | (r[2] <<  8), */
	/* 	(r[0] >> 16) & 0xff, (r[0] >>  8) & 0xff */
	/* ); */
}

__attribute__ ((section (".text.sddriver"))) static inline void sdcard_decode_csd(struct SDCardContext* sdcc, uint32_t sc) {
	uint32_t r[SD_CMD_RESPONSE_SIZE/4];
	csr_rd_buf_uint32(sc, CSR_SDCORE_CMD_RESPONSE_ADDR, r, SD_CMD_RESPONSE_SIZE/4);
	/* FIXME: only support CSR structure version 2.0 */
	//sc->max_rd_blk_len = (1 << ((r[1] >> 16) & 0xf));
	//sc->max_size_in_blk = ((r[2] >> 16) + ((r[1] & 0xff) << 16) + 1) * 512 * 2;
	uint32_t max_size_in_blk = ((r[2] >> 16) + ((r[1] & 0xff) << 16) + 1) * 512 * 2; // weird spec in 512KiB unit
	if (max_size_in_blk >= 4194304) // 2 GiB
	  max_size_in_blk = 4194303; // 2 GiB - 512 B

#define MAX_DSK_SIZE_MB 80
	if (max_size_in_blk >= (MAX_DSK_SIZE_MB*(1048576/512))) // TEMPORARY FOR TESTING
	  max_size_in_blk = (MAX_DSK_SIZE_MB*(1048576/512)); // TEMPORARY FOR TESTING
	
	sdcc->drvsts.driveSize = max_size_in_blk & 0x0000FFFF;
	sdcc->drvsts.driveS1 = (max_size_in_blk & 0xFFFF0000) >> 16;
	sdcc->max_rd_blk_len = (1 << ((r[1] >> 16) & 0xf)); // READ_BL_LEN ? should always be 9 ?
	/* aprint_normal_dev(sc->dk.sc_dev, */
	/* 				  "CSD Register: 0x%08x%08x%08x%08x " */
	/* 				  "Max data transfer rate: %d MB/s " */
	/* 				  "Max read block length: %d bytes " */
	/* 				  "Device size: %d GiB (%d blocks)\n", */
	/* 				  r[0], r[1], r[2], r[3], */
	/* 				  (r[0] >> 24) & 0xff, */
	/* 				  sc->max_rd_blk_len, */
	/* 				  ((r[2] >> 16) + ((r[1] & 0xff) << 16) + 1) * 512 / (1024 * 1024), */
	/* 				  sc->max_size_in_blk */
	/* 				  ); */
}

/*-----------------------------------------------------------------------*/
/* SDCard user functions                                                 */
/*-----------------------------------------------------------------------*/
static int sdcard_init(struct SDCardContext* sdcc, uint32_t sc) {
  uint16_t rca, timeout;
  int res;

  /* Set SD clk freq to Initialization frequency */
  sdcard_set_clk_freq(sc, SDCARD_CLK_FREQ_INIT, 0);
  busy_wait(1);

  for (timeout=1000; timeout>0; timeout--) {
    /* Set SDCard in SPI Mode (generate 80 dummy clocks) */
    sdphy_init_initialize_write(sc, 1);
    busy_wait(1);

    /* Set SDCard in Idle state */
    if (sdcard_go_idle(sc) == SD_OK)
      break;
    busy_wait(1);
  }
  if (timeout == 0) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard timeout (1)\n");
    return 0;
  }

  /* Set SDCard voltages, only supported by ver2.00+ SDCards */
  if ((res = sdcard_send_ext_csd(sc)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_send_ext_csd failed\n");
    return 0;
  }

  /* Set SD clk freq to Operational frequency */
  sdcard_set_clk_freq(sc, SDCARD_CLK_FREQ, 0);
  busy_wait(1);

  /* Set SDCard in Operational state */
  for (timeout=1000; timeout>0; timeout--) {
    sdcard_app_cmd(sc, 0);
    if ((res = sdcard_app_send_op_cond(sc, 1)) != SD_OK)
      break;
    busy_wait(1);
  }
  if (timeout == 0) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard timeout (2)\n");
    return 0;
  }

  /* Send identification */
  if ((res = sdcard_all_send_cid(sc)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_all_send_cid failed (%d)\n", res);
    return 0;
  }
  sdcard_decode_cid(sc);
	
  /* Set Relative Card Address (RCA) */
  if ((res = sdcard_set_relative_address(sc)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_set_relative_address failed (%d)\n", res);
    return 0;
  }
  rca = sdcard_decode_rca(sc);
  //device_printf(sc->dk.sc_dev, "rca is 0x%08x\n", rca);

  /* Set CID */
  if ((res = sdcard_send_cid(sc, rca)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_send_cid failed (%d)\n", res);
    return 0;
  }
#ifdef SDCARD_DEBUG
  /* FIXME: add cid decoding (optional) */
#endif

  /* Set CSD */
  if ((res = sdcard_send_csd(sc, rca)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_send_csd failed (%d)\n", res);
    return 0;
  }
	
  sdcard_decode_csd(sdcc, sc);

  /* Select card */
  if ((res = sdcard_select_card(sc, rca)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_select_card failed (%d)\n", res);
    return 0;
  }

  /* Set bus width */
  if ((res = sdcard_app_cmd(sc, rca)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_app_cmd failed (%d)\n", res);
    return 0;
  }
  if((res = sdcard_app_set_bus_width(sc)) != SD_OK){
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_app_set_bus_width failed (%d)\n", res);
    return 0;
  }

  /* Switch speed */
  if ((res = sdcard_switch(sc, SD_SWITCH_SWITCH, SD_GROUP_ACCESSMODE, SD_SPEED_SDR25)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_switch failed (%d)\n", res);
    return 0;
  }

  /* Send SCR */
  /* FIXME: add scr decoding (optional) */
  if ((res = sdcard_app_cmd(sc, rca)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_app_cmd failed (%d)\n", res);
    return 0;
  }
  if ((res = sdcard_app_send_scr(sc)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_app_send_scr failed (%d)\n", res);
    return 0;
  }

  /* Set block length */
  if ((res = sdcard_app_set_blocklen(sc, 512)) != SD_OK) {
    //aprint_error_dev(sc->dk.sc_dev, "sdcard_app_set_blocklen failed (%d)\n", res);
    return 0;
  }

  return 1;
}

#if 1
__attribute__ ((section (".text.sddriver"))) static inline void do_copy_rev(uint32_t *src, uint32_t *dst, uint32_t size) {
  uint32_t i;
  for (i = 0 ; i < size/4 ; i++) {
    dst[i] = revb(src[i]);
  }
}
#endif

__attribute__ ((section (".text.sddriver"))) static inline OSErr start_dma_read(uint32_t sc, struct SDCardContext *ctx, uint32_t count, uint8_t* buf) {
  unsigned int dma_blk_cnt = count << ctx->dma_blk_per_sdblk_lshift;

  exchange_with_sd_blk_addr_write(sc, 0);
  exchange_with_sd_dma_addr_write(sc, buf);
  exchange_with_sd_blk_cnt_write(sc, dma_blk_cnt | 0x80000000); // MSb==1, read
  return noErr;
}
__attribute__ ((section (".text.sddriver"))) static inline OSErr start_dma_write(uint32_t sc, struct SDCardContext *ctx, uint32_t count, uint8_t* buf) {
  unsigned int dma_blk_cnt = count << ctx->dma_blk_per_sdblk_lshift;

  exchange_with_sd_blk_addr_write(sc, 0);
  exchange_with_sd_dma_addr_write(sc, buf);
  exchange_with_sd_blk_cnt_write(sc, dma_blk_cnt); // MSb==0, write
  return noErr;
}
#if 0
#define DMA_STATUS_CHECK_BITS (0x01F)
__attribute__ ((section (".text.sddriver"))) static inline OSErr wait_dma(uint32_t sc, uint32_t blk_count, OSErr err) {
  unsigned long count, max_count, delay;
  unsigned long blk_cnt, status;
  OSErr ret = noErr;
  max_count = 32 * blk_count;
  delay = blk_count >> 2;
  if (delay > 65536)
    delay = 65536;
  waitSome(delay);
  count = 0;
  blk_cnt = exchange_with_sd_blk_cnt_blk_cnt_read(sc);
  status = exchange_with_sd_dma_status_read(sc) & DMA_STATUS_CHECK_BITS;
  while (((blk_cnt != 0) ||
	  (status != 0)) &&
	 (count < max_count)) {
    count ++;
    waitSome(delay);
    if (blk_cnt) blk_cnt = exchange_with_sd_blk_cnt_blk_cnt_read(sc);
    if (status) status = exchange_with_sd_dma_status_read(sc) & DMA_STATUS_CHECK_BITS;
  }
  if (blk_cnt || status) {
    ret = err;
  }
  return ret;
}
#endif

int sdcard_read(uint32_t sc, struct SDCardContext *ctx, uint32_t block, uint32_t count, uint8_t* buf) {
  while (count) {
    uint32_t nblocks;
    //uint64_t buf_hw_addr = ((uint64_t)((uint32_t)buf));// << 32;
    uint32_t buf_hw_addr = (uint32_t)buf; // TEMPORARY FOR TESTING
    uint32_t stage_addr_dma = 0x80000000; // DDR // TEMPORARY FOR TESTING
    uint32_t stage_addr_cpu = sc << 4; // superslot // TEMPORARY FOR TESTING
#ifdef SDCARD_CMD18_SUPPORT
    nblocks = count;
    if (nblocks > 16)
      nblocks = 16;
#else
    nblocks = 1;
#endif
    
#if 1
    /* Initialize DMA Writer */
    sdblock2mem_dma_enable_write(sc, 0);
    /* sdblock2mem_dma_base_write takes an uint64_t */
    ////sdblock2mem_dma_base_write(sc, buf_hw_addr);
    sdblock2mem_dma_base_write(sc, stage_addr_dma);
    sdblock2mem_dma_length_write(sc, 512*nblocks);
    sdblock2mem_dma_enable_write(sc, 1);
#else
    start_dma_write(sc, ctx, nblocks, buf_hw_addr); // read from sdcard, write to memory
#endif

    /* Read Block(s) from SDCard */
#ifdef SDCARD_CMD23_SUPPORT
    sdcard_set_block_count(sc, nblocks);
#endif
    if (nblocks > 1)
      sdcard_read_multiple_block(sc, block, nblocks);
    else
      sdcard_read_single_block(sc, block);

#if 1
    //int timeout = 64 * nblocks;
    int timeout = 1024 * nblocks;
    /* Wait for DMA Writer to complete */
    while (((sdblock2mem_dma_done_read(sc) & 0x1) == 0) && timeout) {
      //delay(2);
      delay(20);
      timeout --;
    }
    if ((sdblock2mem_dma_done_read(sc) & 0x1) == 0) {
      /* device_printf(sc->dk.sc_dev, "%s: SD card timeout\n", __PRETTY_FUNCTION__); */
      return 1;
    }
#else
    if (wait_dma(sc, nblocks, readErr) != noErr)
      return 1;
#endif

    /* Stop transmission (Only for multiple block reads) */
    if (nblocks > 1)
      sdcard_stop_transmission(sc);

    BlockMoveData((void*)stage_addr_cpu, (void*)buf_hw_addr, 512*nblocks);
    //do_copy_rev((void*)stage_addr_cpu, (void*)buf_hw_addr, 512*nblocks);
   

    /* Update Block/Buffer/Count */
    block += nblocks;
    buf += 512*nblocks;
    count -= nblocks;
  }

  return 0;
}

int sdcard_write(uint32_t sc, struct SDCardContext *ctx, uint32_t block, uint32_t count, uint8_t* buf) {
  while (count) {
    uint32_t nblocks;
    //uint64_t buf_hw_addr = ((uint64_t)((uint32_t)buf));// << 32;
    uint32_t buf_hw_addr = (uint32_t)buf; // TEMPORARY FOR TESTING
    uint32_t stage_addr_dma = 0x80000000; // DDR // TEMPORARY FOR TESTING
    uint32_t stage_addr_cpu = sc << 4; // superslot // TEMPORARY FOR TESTING
#ifdef SDCARD_CMD25_SUPPORT
    nblocks = count;
    if (nblocks > 16)
      nblocks = 16;
#else
    nblocks = 1;
#endif

    BlockMoveData((void*)buf_hw_addr, (void*)stage_addr_cpu, 512*nblocks);
    //do_copy_rev((void*)buf_hw_addr, (void*)stage_addr_cpu, 512*nblocks);

#if 1
    /* Initialize DMA Reader */
    sdmem2block_dma_enable_write(sc, 0);
    /* sdblock2mem_dma_base_write takes an uint64_t */
    ////sdmem2block_dma_base_write(sc, buf_hw_addr);
    sdmem2block_dma_base_write(sc, stage_addr_dma);
    sdmem2block_dma_length_write(sc, 512*nblocks);
    sdmem2block_dma_enable_write(sc, 1);
#else
    start_dma_read(sc, ctx, nblocks, buf_hw_addr); // write to sdcard, read from memory
#endif

    /* Write Block(s) to SDCard */
#ifdef SDCARD_CMD23_SUPPORT
    sdcard_set_block_count(sc, nblocks);
#endif
    if (nblocks > 1)
      sdcard_write_multiple_block(sc, block, nblocks);
    else
      sdcard_write_single_block(sc, block);

    /* Stop transmission (Only for multiple block writes) */
    if (nblocks > 1)
      sdcard_stop_transmission(sc);

#if 1
    /* Wait for DMA Reader to complete */
    //int timeout = 64 * nblocks;
    int timeout = 1024 * nblocks;
    while (((sdmem2block_dma_done_read(sc) & 0x1) == 0) && timeout) {
      //delay(2);
      delay(20);
      timeout --;
    }
    if ((sdmem2block_dma_done_read(sc) & 0x1) == 0) {
      /* device_printf(sc->dk.sc_dev, "%s: SD card timeout\n", __PRETTY_FUNCTION__); */
      return 1;
    }
#else
    if (wait_dma(sc, nblocks, writErr) != noErr)
      return 1;
#endif

    /* Update Block/Buffer/Count */
    block += nblocks;
    buf += 512*nblocks;
    count -= nblocks;
  }
	
  return 0;
}
