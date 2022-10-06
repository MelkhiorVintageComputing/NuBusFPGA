NuBusFPGARAMDskDrvr:	
    .word  	    0x4f00             /* 0x4f00: ctl, status, read, write, needsLock [Devices.a] */
    .word          0
    .word          0
    .word          0
  /* Entry point offset table */
	/* we can directly call the C version if it has the right calling convention */
    .word		cNuBusFPGARAMDskOpen  - NuBusFPGARAMDskDrvr  /* open routine */
	.word		cNuBusFPGARAMDskPrime - NuBusFPGARAMDskDrvr  /* prime */
	.word		cNuBusFPGARAMDskCtl   - NuBusFPGARAMDskDrvr  /* control */
	.word		cNuBusFPGARAMDskStatus- NuBusFPGARAMDskDrvr  /* status */
	.word		cNuBusFPGARAMDskClose - NuBusFPGARAMDskDrvr  /* close */
	
_NuBusFPGARAMDskTitle:
	.byte _NuBusFPGARAMDskTitle_StringEnd-.-1  /* pascal string length */
	.ascii ".NuBusFPGARAMDsk_Drvr"
_NuBusFPGARAMDskTitle_StringEnd:	
    .word 0 /* version number */
	
	/* for entry points: */
    /* A0 pointer to driver parameter block */
	/* A1 pointer to driver device control entry */
	ALIGN 2
