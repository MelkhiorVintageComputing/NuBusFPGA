#ifndef __NUBUSFPGARAMDSKDRVR_H__
#define __NUBUSFPGARAMDSKDRVR_H__

#include <Files.h>
#include <Devices.h>
#include <Slots.h>
#include <MacErrors.h>
#include <MacMemory.h>
#include <Disks.h>

#include "NuBusFPGADrvr.h"

struct SDCardContext {
  DrvSts2 drvsts;
  unsigned int dma_blk_size;
  unsigned int dma_blk_size_mask;
  unsigned int dma_blk_size_shift;
  unsigned int dma_blk_per_sdblk;
  unsigned int dma_blk_per_sdblk_lshift;
  char slot;
  char toto;
  unsigned int max_rd_blk_len;
  SlotIntQElement *siqel;
};

#include "nubusfpga_csr_common.h"
#include "../nubusfpga_csr_sdblock2mem.h"
#include "../nubusfpga_csr_sdcore.h"
//#include "../nubusfpga_csr_sdirq.h"
#include "../nubusfpga_csr_sdmem2block.h"
#include "../nubusfpga_csr_sdphy.h"

#include "../nubusfpga_csr_exchange_with_sd.h"

/* basically Litex BIOS code */

#ifndef CONFIG_CLOCK_FREQUENCY
#define CONFIG_CLOCK_FREQUENCY 100000000
#endif


#define CLKGEN_STATUS_BUSY		0x1
#define CLKGEN_STATUS_PROGDONE	0x2
#define CLKGEN_STATUS_LOCKED	0x4

#define SD_CMD_RESPONSE_SIZE 16

#define SD_OK         0
#define SD_CRCERROR   1
#define SD_TIMEOUT    2
#define SD_WRITEERROR 3

#define SD_SWITCH_CHECK  0
#define SD_SWITCH_SWITCH 1

#define SD_SPEED_SDR12  0
#define SD_SPEED_SDR25  1
#define SD_SPEED_SDR50  2
#define SD_SPEED_SDR104 3
#define SD_SPEED_DDR50  4

#define SD_DRIVER_STRENGTH_B 0
#define SD_DRIVER_STRENGTH_A 1
#define SD_DRIVER_STRENGTH_C 2
#define SD_DRIVER_STRENGTH_D 3

#define SD_GROUP_ACCESSMODE     0
#define SD_GROUP_COMMANDSYSTEM  1
#define SD_GROUP_DRIVERSTRENGTH 2
#define SD_GROUP_POWERLIMIT     3

#define SDCARD_STREAM_STATUS_OK           0b000
#define SDCARD_STREAM_STATUS_TIMEOUT      0b001
#define SDCARD_STREAM_STATUS_DATAACCEPTED 0b010
#define SDCARD_STREAM_STATUS_CRCERROR     0b101
#define SDCARD_STREAM_STATUS_WRITEERROR   0b110

#define SDCARD_CTRL_DATA_TRANSFER_NONE  0
#define SDCARD_CTRL_DATA_TRANSFER_READ  1
#define SDCARD_CTRL_DATA_TRANSFER_WRITE 2

#define SDCARD_CTRL_RESPONSE_NONE       0
#define SDCARD_CTRL_RESPONSE_SHORT      1
#define SDCARD_CTRL_RESPONSE_LONG       2
#define SDCARD_CTRL_RESPONSE_SHORT_BUSY 3

//#define SDCARD_DEBUG
//#define SDCARD_CMD23_SUPPORT /* SET_BLOCK_COUNT */
#define SDCARD_CMD18_SUPPORT /* READ_MULTIPLE_BLOCK */
#define SDCARD_CMD25_SUPPORT /* WRITE_MULTIPLE_BLOCK */

#ifndef SDCARD_CLK_FREQ_INIT
#define SDCARD_CLK_FREQ_INIT 400000
#endif

#ifndef SDCARD_CLK_FREQ
#define SDCARD_CLK_FREQ 25000000
//#define SDCARD_CLK_FREQ 12500000
#endif


/* ctrl */
OSErr cNuBusFPGASDCardCtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.sddriver")));
/* open, close */
OSErr cNuBusFPGASDCardOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.sddriver")));
OSErr cNuBusFPGASDCardClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.sddriver")));
void busy_wait(int d) __attribute__ ((section (".text.sddriver")));
void delay(int d) __attribute__ ((section (".text.sddriver")));
int sdcard_read(uint32_t sc, struct SDCardContext *ctx, uint32_t block, uint32_t count, uint8_t* buf) __attribute__ ((section (".text.sddriver")));
int sdcard_write(uint32_t sc, struct SDCardContext *ctx, uint32_t block, uint32_t count, uint8_t* buf) __attribute__ ((section (".text.sddriver")));
/* prime */
OSErr cNuBusFPGASDCardPrime(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.sddriver")));
void waitSome(unsigned long bound) __attribute__ ((section (".text.sddriver")));
/* status */
OSErr cNuBusFPGASDCardStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce) __attribute__ ((section (".text.sddriver")));

uint32_t rledec(uint32_t* out, const uint32_t* in, const uint32_t len) __attribute__ ((section (".text.sddriver")));

#endif
