#include "NuBusFPGADrvr.h"

#include "ROMDefs.h"

typedef void(*vblproto)(short);

#pragma parameter __D0 fbIrq(__A1)
__attribute__ ((section (".text.fbdriver"))) short fbIrq(const long sqParameter){
	/* AuxDCEPtr dce = (AuxDCEPtr)sqParameter; */
	/* NuBusFPGADriverGlobalsHdl dStoreHdl = (NuBusFPGADriverGlobalsHdl)dce->dCtlStorage; */
	/* NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl; */
	vblproto myVbl = *(vblproto**)0x0d28;
	/* write_reg(dce, GOBOFB_INTR_CLEAR, 0); */
	*((volatile unsigned int*)(sqParameter+GOBOFB_BASE+GOBOFB_INTR_CLEAR)) = 0;
	myVbl((sqParameter>>24)&0xf); // cleaner to use dStore->slot ? but require more code...
	return 1;
}


#pragma parameter __D0 cNuBusFPGAOpen(__A0, __A1)
OSErr cNuBusFPGAOpen(IOParamPtr pb, /* DCtlPtr */ AuxDCEPtr dce)
{
	OSErr ret = noErr;
	write_reg(dce, GOBOFB_DEBUG, 0xBEEF0000);
	write_reg(dce, GOBOFB_DEBUG, (unsigned long)dce->dCtlDevBase);
	
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
			NuBusFPGADriverGlobalsPtr dStore = *dStoreHdl;
			/* (*dStore)->dce = dce; */
			
			/* for (i = 0 ; i < 256 ; i++) { */
			/* 	dStore->shadowClut[i*3+0] = i; */
			/* 	dStore->shadowClut[i*3+1] = i; */
			/* 	dStore->shadowClut[i*3+2] = i; */
			/* } */
			
			dStore->gray = 0;
			dStore->irqen = 0;
			dStore->slot = dce->dCtlSlot;

			/* Get the HW setting for native resolution */
			dStore->hres[0] = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_HRES)); // fixme: endianness
			dStore->vres[0] = __builtin_bswap32((unsigned int)read_reg(dce, GOBOFB_VRES)); // fixme: endianness
			
			SlotIntQElement *siqel = (SlotIntQElement *)NewPtrSysClear(sizeof(SlotIntQElement));
			if (siqel == NULL) {
				return openErr;
			}
			siqel->sqType = sIQType;
			siqel->sqPrio = 8;
			//siqel->sqAddr = interruptRoutine;
			/* not sure how to get the proper result in C... */
			/* SlotIntServiceProcPtr sqAddr; */
			/* asm("lea %%pc@(interruptRoutine),%0\n" : "=a"(sqAddr)); */
			/* siqel->sqAddr = sqAddr; */
			/* siqel->sqParm = (long)dce->dCtlDevBase; */
			
			/* not sure how to get the proper result in C... */
			/* ... from ~mac68k, you need option "-mpcrel", and it works */
			/* SlotIntServiceProcPtr sqAddr; */
			/* asm("lea %%pc@(fbIrq),%0\n" : "=a"(sqAddr)); */
			siqel->sqAddr = fbIrq;
			/* siqel->sqParm = (long)dce; */
			siqel->sqParm = (long)dce->dCtlDevBase;
			dStore->siqel = siqel;

			dStore->curPage = 0;
			dStore->curMode = nativeVidMode;
			dStore->curDepth = kDepthMode1;

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
				dStore->maxMode = max;
			}
	/* write_reg(dce, GOBOFB_DEBUG, 0xBEEF0000); */
	/* write_reg(dce, GOBOFB_DEBUG, dStore->maxMode); */
			{
				OSErr err = noErr;
				SpBlock spb;
				/* check for resolution */
				UInt8 id;
				for (id = nativeVidMode; id <= dStore->maxMode ; id ++) {
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
							dStore->hres[idx] = vpblock->vpBounds.right;
							dStore->vres[idx] = vpblock->vpBounds.bottom;
						}
					}
				}
				
			}
				
			linearGamma(dStore);

			/* now check the content of PRAM */
			if (0) {
				SpBlock spb;
				NuBusFPGAPramRecord pram;
				OSErr err;
				spb.spSlot = dce->dCtlSlot;
				spb.spResult = (UInt32)&pram;
				err = SReadPRAMRec(&spb);
				if (err == noErr) {
					err = reconfHW(dce, pram.mode, pram.depth, pram.page);
				}
			}
				
			write_reg(dce, GOBOFB_VIDEOCTRL, 1);
			
			ret = changeIRQ(dce, 1, openErr);
		}
	
   return noErr;
}

#pragma parameter __D0 cNuBusFPGAClose(__A0, __A1)
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

