#ifndef __NUBUSFPGARAMDSKDRVR_H__
#define __NUBUSFPGARAMDSKDRVR_H__

#include <Files.h>
#include <Devices.h>
#include <Slots.h>
#include <MacErrors.h>
#include <MacMemory.h>
#include <Disks.h>

#define ENABLE_DMA 1

#include "NuBusFPGADrvr.h"

#ifdef ENABLE_DMA
typedef struct {
	unsigned long blk_todo;
	unsigned long blk_done;
	unsigned long blk_offset;
	unsigned long blk_doing;
	void *ioBuffer;
	int write;
} ram_dsk_op;
#endif

struct RAMDrvContext {
	DrvSts2 drvsts;
	char slot;
#ifdef ENABLE_DMA
	unsigned int dma_blk_size;
	unsigned int dma_blk_size_mask;
	unsigned int dma_blk_size_shift;
	unsigned long dma_blk_base;
	unsigned long dma_mem_size;
	SlotIntQElement *siqel;
	ram_dsk_op op;
	char irqen;
#endif
};

#define DRIVE_SIZE_BYTES ((256ul-8ul)*1024ul*1024ul) // FIXME: mem size minus fb size

#ifdef ENABLE_DMA
/* FIXME; should be auto-generated for CSR addresses... */
/* WARNING: 0x00100800 is the offset to GOBOFB_BASE !! */
#define DMA_BLK_SIZE (0x00100800 | 0x00)
#define DMA_BLK_BASE (0x00100800 | 0x04)
#define DMA_MEM_SIZE (0x00100800 | 0x08)
#define DMA_IRQ_CTL  (0x00100800 | 0x0c)
#define DMA_BLK_ADDR (0x00100800 | 0x10)
#define DMA_DMA_ADDR (0x00100800 | 0x14)
#define DMA_BLK_CNT  (0x00100800 | 0x18)

#define DMA_STATUS   (0x00100800 | 0x2c)
#define DMA_STATUS_CHECK_BITS (0x01F)

#define DMA_IRQSTATUS (0x00100800 | 0x34)

#endif

/* ctrl */
OSErr changeRAMdskIRQ(AuxDCEPtr dce, char en, OSErr err) __attribute__ ((section (".text.dskdriver")));
OSErr cNuBusFPGARAMDskCtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.dskdriver")));
/* open, close */
OSErr cNuBusFPGARAMDskOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.dskdriver")));
OSErr cNuBusFPGARAMDskClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.dskdriver")));
/* prime */
OSErr cNuBusFPGARAMDskPrime(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.dskdriver")));
/* status */
OSErr cNuBusFPGARAMDskStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.dskdriver")));

uint32_t rledec(uint32_t* out, const uint32_t* in, const uint32_t len) __attribute__ ((section (".text.dskdriver")));;

#endif
