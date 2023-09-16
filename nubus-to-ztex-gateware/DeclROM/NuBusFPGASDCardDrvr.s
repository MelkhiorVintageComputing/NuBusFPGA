NuBusFPGASDCardDrvr:	
    .word  	    0x4f00             /* 0x4f00: ctl, status, read, write, needsLock [Devices.a] */
    .word          0
    .word          0
    .word          0
  /* Entry point offset table */
	/* we can directly call the C version if it has the right calling convention */
    .word		cNuBusFPGASDCardOpen  - NuBusFPGASDCardDrvr  /* open routine */
	.word		cNuBusFPGASDCardPrime - NuBusFPGASDCardDrvr  /* prime */
	.word		cNuBusFPGASDCardCtl   - NuBusFPGASDCardDrvr  /* control */
	.word		cNuBusFPGASDCardStatus- NuBusFPGASDCardDrvr  /* status */
	.word		cNuBusFPGASDCardClose - NuBusFPGASDCardDrvr  /* close */
	
_NuBusFPGASDCardTitle:
	.byte _NuBusFPGASDCardTitle_StringEnd-.-1  /* pascal string length */
	.ascii ".NuBusFPGASDCard_Drvr"
_NuBusFPGASDCardTitle_StringEnd:	
    .word 0 /* version number */
	
	/* for entry points: */
    /* A0 pointer to driver parameter block */
	/* A1 pointer to driver device control entry */
	ALIGN 2
