#include "NuBusFPGADrvr.h"

#include "ROMDefs.h"

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
			(*dStoreHdl)->hres[0] = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_HRES)); // fixme: endianness
			(*dStoreHdl)->vres[0] = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_VRES)); // fixme: endianness
			
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

			(*dStoreHdl)->curMode = nativeVidMode;
			(*dStoreHdl)->curDepth = kDepthMode1;

			{
				OSErr err = noErr;
				SpBlock spb;
				UInt8 max = nativeVidMode;
				
				spb.spParamData = 1<<fall|1<<foneslot;
				spb.spCategory = catDisplay;
				spb.spCType = typeVideo;
				spb.spDrvrSW = drSwApple;
				spb.spDrvrHW = 0xBEEF;
				spb.spTBMask = 0; /* match everything above */
				spb.spSlot = dce->dCtlSlot;
				spb.spID = nativeVidMode;
				spb.spExtDev = 0;
				err = SGetTypeSRsrc(&spb);
				while ((err == noErr) &&
					   (spb.spSlot == dce->dCtlSlot) &&
					   (((UInt8)spb.spID) > (UInt8)0x80) &&
					   (((UInt8)spb.spID) < (UInt8)0x90)) {
					/* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0020); */
					/* write_reg(dce, GOBOFB_DEBUG, spb.spID); */
					/* write_reg(dce, GOBOFB_DEBUG, err); */

					if (((UInt8)spb.spID) == max) // should not happen
						err = smNoMoresRsrcs;
					if (((UInt8)spb.spID) > max)
						max = spb.spID;
					err = SGetTypeSRsrc(&spb);
				}
				(*dStoreHdl)->maxMode = max;
			}
	/* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0000); */
	/* write_reg(dce, GOBOFB_DEBUG, (*dStoreHdl)->maxMode); */
			{
				OSErr err = noErr;
				SpBlock spb;
				/* check for resolution */
				UInt8 id;
				for (id = nativeVidMode; id <= (*dStoreHdl)->maxMode ; id ++) {
					/* try every resource, enabled or not */
					spb.spParamData = 1<<fall; /* wants disabled */
					spb.spCategory = catDisplay;
					spb.spCType = typeVideo;
					spb.spDrvrSW = drSwApple;
					spb.spDrvrHW = 0xBEEF;
					spb.spTBMask = 0;
					spb.spSlot = dce->dCtlSlot;
					spb.spID = id;
					spb.spExtDev = 0;
					err = SGetSRsrc(&spb);
						
					if (err == noErr) {
						spb.spID = kDepthMode1;
						err = SFindStruct(&spb); /* that will give us the Parms block ... */
						
						if (err == noErr) {
							/* take the Parms pointer, add the offset to the Modes block and then skip the block size at the beginning to get the structure pointer ... */
							const unsigned long offset = *(unsigned long*)spb.spsPointer & 0x00FFFFFF;
							VPBlockPtr vpblock = (VPBlockPtr)(spb.spsPointer + offset + sizeof(long));
							UInt8 idx = id - nativeVidMode;
							(*dStoreHdl)->hres[idx] = vpblock->vpBounds.right;
							(*dStoreHdl)->vres[idx] = vpblock->vpBounds.bottom;
						}
					}
				}
				
			}
				
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

