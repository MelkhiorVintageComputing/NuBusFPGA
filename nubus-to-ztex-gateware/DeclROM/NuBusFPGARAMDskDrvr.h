#ifndef __NUBUSFPGARAMDSKDRVR_H__
#define __NUBUSFPGARAMDSKDRVR_H__

#include <Files.h>
#include <Devices.h>
#include <Slots.h>
#include <MacErrors.h>
#include <MacMemory.h>
#include <Disks.h>

#include "NuBusFPGADrvr.h"

struct RAMDrvContext {
	DrvSts2 drvsts;
};

#define DRIVE_SIZE_BYTES ((256ul-8ul)*1024ul*1024ul) // FIXME: mem size minus fb size

uint32_t rledec(uint32_t* out, const uint32_t* in, const uint32_t len);

#endif
