#ifndef __NUBUSFPGADRVR_H__
#define __NUBUSFPGADRVR_H__

#include <Files.h>
#include <Devices.h>
#include <Slots.h>
#include <MacErrors.h>
#include <MacMemory.h>
#include <Video.h>

#ifndef HRES
#define HRES 1152
#warning "Using default HRES"
#endif
#ifndef VRES
#define VRES 870
#warning "Using default VRES"
#endif

#define GOBOFB_BASE  0x00900000

#define GOBOFB_MODE           0x0
#define GOBOFB_VBL_MASK       0x4
//#define GOBOFB_VBL_DIS        0x8
#define GOBOFB_INTR_CLEAR     0xc
#define GOBOFB_RESET          0x10
#define GOBOFB_LUT_ADDR       0x14
#define GOBOFB_LUT            0x18
#define GOBOFB_DEBUG          0x20

#define GOBOFB_INTR_VBL       0x1

struct MyGammaTbl {
  short               gVersion;               /*gamma version number*/
  short               gType;                  /*gamma data type*/
  short               gFormulaSize;           /*Formula data size*/
  short               gChanCnt;               /*number of channels of data*/
  short               gDataCnt;               /*number of values/channel*/
  short               gDataWidth;             /*bits/corrected value (data packed to next larger byte size)*/
  char                gFormulaData[3][256];        /*data for formulas followed by gamma values*/
};

struct NuBusFPGADriverGlobals {
	AuxDCEPtr	dce; // unused
	SlotIntQElement *siqel;
	//unsigned char shadowClut[768];
	char gray;
	char irqen;
	struct MyGammaTbl gamma;
};
typedef struct NuBusFPGADriverGlobals NuBusFPGADriverGlobals;
typedef struct NuBusFPGADriverGlobals *NuBusFPGADriverGlobalsPtr;
typedef struct NuBusFPGADriverGlobals **NuBusFPGADriverGlobalsHdl;

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
/* status */
OSErr cNuBusFPGAStatus(CntrlParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);
/* open close */
OSErr cNuBusFPGAOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);
OSErr cNuBusFPGAClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce);

#endif
