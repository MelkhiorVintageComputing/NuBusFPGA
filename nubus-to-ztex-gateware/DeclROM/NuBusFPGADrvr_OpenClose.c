#include "NuBusFPGADrvr.h"

OSErr cNuBusFPGAOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	/* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0000); */
	/* write_reg(dce, GOBOFB_DEBUG, (unsigned long)dce->dCtlDevBase); */
	
	if (dce->dCtlStorage == nil)
		{
			int i;
			/* set up flags in the device control entry */
			/* dce->dCtlFlags |= (dCtlEnableMask | dStatEnableMask | dWritEnableMask |
			   dReadEnableMask | dNeedLockMask | dRAMBasedMask ); */
			
			/* initialize dCtlStorage */
			ReserveMemSys(sizeof(NuBusFPGADriverGlobals));
			dce->dCtlStorage = NewHandleSysClear(sizeof(NuBusFPGADriverGlobals));
			if (dce->dCtlStorage == nil)
				return(openErr);
			HLock(dce->dCtlStorage);
			NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage;
			/* (*dStore)->dce = dce; */
			
			/* for (i = 0 ; i < 256 ; i++) { */
			/* 	(*dStoreHdl)->shadowClut[i*3+0] = i; */
			/* 	(*dStoreHdl)->shadowClut[i*3+1] = i; */
			/* 	(*dStoreHdl)->shadowClut[i*3+2] = i; */
			/* } */
			
			(*dStoreHdl)->gray = 0;
			(*dStoreHdl)->irqen = 0;
			(*dStoreHdl)->slot = dce->dCtlSlot;

			/* Get the HW setting for native resolution */
			(*dStoreHdl)->hres = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_HRES)); // fixme: endianness
			(*dStoreHdl)->vres = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_VRES)); // fixme: endianness
			
			SlotIntQElement *siqel = (SlotIntQElement *)NewPtrSysClear(sizeof(SlotIntQElement));
			if (siqel == NULL) {
				return openErr;
			}
			siqel->sqType = sIQType;
			siqel->sqPrio = 8;
			//siqel->sqAddr = interruptRoutine;
			/* not sure how to get the proper result in C... */
			SlotIntServiceProcPtr sqAddr;
			asm("lea %%pc@(interruptRoutine),%0\n" : "=a"(sqAddr));
			siqel->sqAddr = sqAddr;
			siqel->sqParm = (long)dce->dCtlDevBase;
			(*dStoreHdl)->siqel = siqel;

			(*dStoreHdl)->curMode = firstVidMode;
			(*dStoreHdl)->curDepth = kDepthMode1;
			
			linearGamma(*dStoreHdl);
			
			write_reg(dce, GOBOFB_MODE, GOBOFB_MODE_8BIT);

			write_reg(dce, GOBOFB_VIDEOCTRL, 1);
			
			ret = changeIRQ(dce, 1, openErr);
		}
	
   return noErr;
}

OSErr cNuBusFPGAClose(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	/* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0003); */
	/* write_reg(dce, GOBOFB_DEBUG, 0x0000DEAD); */
	asm(".word 0xfe16\n");
   if (dce->dCtlStorage != nil)
   {
	   ret = changeIRQ(dce, 0, openErr);
	   write_reg(dce, GOBOFB_VIDEOCTRL, 0);
	   DisposePtr((Ptr)(*(NuBusFPGADriverGlobalsHdl)dce->dCtlStorage)->siqel);
	   DisposeHandle(dce->dCtlStorage);
	   dce->dCtlStorage = nil;
   }
   return ret;
}

