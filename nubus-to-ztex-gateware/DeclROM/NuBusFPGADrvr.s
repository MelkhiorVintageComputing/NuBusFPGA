NuBusFPGADrvr:	
    .word  	    0x4c00             /* 0x4c00: ctl, status, needsLock [Devices.a] */
    .word          0
    .word          0
    .word          0
	/* Entry point offset table */
	/* we can directly call the C version if it has the right calling convention */
    .word		cNuBusFPGAOpen-NuBusFPGADrvr   /* open routine */
	.word		NuBusFPGADrvr-NuBusFPGADrvr   /* no prime */
	.word		cNuBusFPGACtl-NuBusFPGADrvr    /* control */
	.word		cNuBusFPGAStatus-NuBusFPGADrvr /* status */
	.word		cNuBusFPGAClose-NuBusFPGADrvr  /* close */
	
_NuBusFPGATitle:
	.byte _NuBusFPGATitle_StringEnd-.-1  /* pascal string length */
	.ascii ".NuBusFPGA_Drvr"
_NuBusFPGATitle_StringEnd:	
    .word 0 /* version number */

	/* for entry points: */
    /* A0 pointer to driver parameter block */
	/* A1 pointer to driver device control entry */
	ALIGN 2

	.include "NuBusFPGADrvr_OpenClose.s"
	.text
	.include "NuBusFPGADrvr_Ctrl.s"
	.text
	.include "NuBusFPGADrvr_Status.s"
	.text
	
	ALIGN 2
