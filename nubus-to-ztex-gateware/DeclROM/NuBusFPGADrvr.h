#ifndef __NUBUSFPGADRVR_H__
#define __NUBUSFPGADRVR_H__

#include <Files.h>
#include <Devices.h>
#include <Slots.h>
#include <MacErrors.h>
#include <MacMemory.h>
#include <Video.h>

#define GOBOFB_BASE     0x00900000
#define GOBOFB_ACCEL    0x00901000
#define GOBOFB_ACCEL_LE 0x00901800

//#define GOBOFB_REG_BASE       0x00900000
//#define GOBOFB_MEM_BASE       0x00000000 /* remapped to 0x8f800000 by HW */

#define GOBOFB_MODE           0x0
#define GOBOFB_VBL_MASK       0x4
#define GOBOFB_VIDEOCTRL      0x8
#define GOBOFB_INTR_CLEAR     0xc
#define GOBOFB_RESET          0x10
#define GOBOFB_LUT_ADDR       0x14
#define GOBOFB_LUT            0x18
#define GOBOFB_DEBUG          0x1c
//#define GOBOFB_CURSOR_LUT     0x20
//#define GOBOFB_CURSOR_XY      0x24
#define GOBOFB_HRES           0x40
#define GOBOFB_VRES           0x44
#define GOBOFB_HRES_START     0x48
#define GOBOFB_VRES_START     0x4C
#define GOBOFB_HRES_END       0x50
#define GOBOFB_VRES_END       0x54
//#define GOBOFB_MASK_BASE      0x80
//#define GOBOFB_BITS_BASE      0x100

#define GOBOFB_INTR_VBL       0x1

// for GOBOFB_MODE
#define GOBOFB_MODE_1BIT  0x0
#define GOBOFB_MODE_2BIT  0x1
#define GOBOFB_MODE_4BIT  0x2
#define GOBOFB_MODE_8BIT  0x3
#define GOBOFB_MODE_24BIT 0x10
#define GOBOFB_MODE_15BIT 0x11

#define u_int32_t volatile unsigned long
struct goblin_accel_regs {
	u_int32_t reg_status; // 0
	u_int32_t reg_cmd;
	u_int32_t reg_r5_cmd;
	u_int32_t resv0;
	u_int32_t reg_width; // 4
	u_int32_t reg_height;
	u_int32_t reg_fgcolor;
	u_int32_t resv2;
	u_int32_t reg_bitblt_src_x; // 8
	u_int32_t reg_bitblt_src_y;
	u_int32_t reg_bitblt_dst_x;
	u_int32_t reg_bitblt_dst_y;
	u_int32_t reg_src_stride; // 12
	u_int32_t reg_dst_stride;
	u_int32_t reg_src_ptr; // 14
	u_int32_t reg_dst_ptr;
};

// status
#define WORK_IN_PROGRESS_BIT 0

// cmd
#define DO_BLIT_BIT            0 // hardwired in goblin_accel.py
#define DO_FILL_BIT            1 // hardwired in goblin_accel.py
#define DO_TEST_BIT            3 // hardwired in goblin_accel.py

struct MyGammaTbl {
  short               gVersion;               /*gamma version number*/
  short               gType;                  /*gamma data type*/
  short               gFormulaSize;           /*Formula data size*/
  short               gChanCnt;               /*number of channels of data*/
  short               gDataCnt;               /*number of values/channel*/
  short               gDataWidth;             /*bits/corrected value (data packed to next larger byte size)*/
  char                gFormulaData[3][256];        /*data for formulas followed by gamma values*/
};

#define nativeVidMode ((unsigned char)0x80)
/* alternate resolution in 0x81...0x8f */
#define diskResource ((unsigned char)0x90)

struct NuBusFPGADriverGlobals {
	AuxDCEPtr	dce; // unused
	SlotIntQElement *siqel;
	//unsigned char shadowClut[768];
	unsigned short hres[16]; /* HW max in 0 */
	unsigned short vres[16]; /* HW max in 0 */
	unsigned short curPage;
	unsigned char maxMode;
	unsigned char curMode; /* mode ; this is resolution (which can't be changed in 7.1 except via reboot ?) */
	unsigned char curDepth; /* depth */
	char gray;
	char irqen;
	char slot;
	struct MyGammaTbl gamma;
};
typedef struct NuBusFPGADriverGlobals NuBusFPGADriverGlobals;
typedef struct NuBusFPGADriverGlobals *NuBusFPGADriverGlobalsPtr;
typedef struct NuBusFPGADriverGlobals **NuBusFPGADriverGlobalsHdl;

typedef struct NuBusFPGAPramRecord { /* slot parameter RAM record, derived from  SPRAMRecord  */
	short    boardID;         /* Apple-defined card ID */
	char     vendorUse1;      /* reserved for vendor use */ /* DCDMF3 p210 says reserved for system ... */
	unsigned char     mode;      /* vendorUse2 */
	unsigned char     depth;      /* vendorUse3 */
	unsigned char     page;      /* vendorUse4 */
	char     vendorUse5;      /* reserved for vendor use */
	char     vendorUse6;      /* reserved for vendor use */
} NuBusFPGAPramRecord;
typedef struct NuBusFPGAPramRecord *NuBusFPGAPramRecordPtr;

static inline void write_reg(AuxDCEPtr dce, unsigned int reg, unsigned int val) {
	*((volatile unsigned int*)(dce->dCtlDevBase+GOBOFB_BASE+reg)) = val;
}
static inline unsigned int read_reg(AuxDCEPtr dce, unsigned int reg) {
	return *((volatile unsigned int*)(dce->dCtlDevBase+GOBOFB_BASE+reg));;
}

/* ASM */
extern SlotIntServiceProcPtr interruptRoutine;
/* ctrl */
void linearGamma(NuBusFPGADriverGlobalsPtr dStore);
OSErr changeIRQ(AuxDCEPtr dce, char en, OSErr err);
OSErr cNuBusFPGACtl(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);
OSErr reconfHW(AuxDCEPtr dce, unsigned char mode, unsigned char depth, unsigned short page);
OSErr updatePRAM(AuxDCEPtr dce, unsigned char mode, unsigned char depth, unsigned short page);
/* status */
OSErr cNuBusFPGAStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);
/* open close */
OSErr cNuBusFPGAOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);
OSErr cNuBusFPGAClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);

/* primary init */
UInt32 Primary(SEBlock* block);

#define         Check32QDTrap               0xAB03

static inline UInt32 revb(UInt32 d) {
	return ((d&0xFFul)<<24) | ((d&0xFF00ul)<<8) | ((d&0xFF0000ul)>>8) | ((d&0xFF000000ul)>>24);
}

#endif
