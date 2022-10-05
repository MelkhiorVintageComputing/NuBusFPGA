NuBusFPGADrvr:	
    .word  	    0x4c00             /* 0x4c00: ctl, status, needsLock [Devices.a] */
    .word          0
    .word          0
    .word          0
  /* Entry point offset table */
    .word		_NuBusFPGAOpen-NuBusFPGADrvr   /* open routine */
	.word		NuBusFPGADrvr-NuBusFPGADrvr   /* no prime */
	.word		_NuBusFPGACtl-NuBusFPGADrvr    /* control */
	.word		_NuBusFPGAStatus-NuBusFPGADrvr /* status */
	.word		_NuBusFPGAClose-NuBusFPGADrvr  /* close */
	
_NuBusFPGATitle:
	.byte _NuBusFPGATitle_StringEnd-.-1  /* pascal string length */
	.ascii ".NuBusFPGA_Drvr"
_NuBusFPGATitle_StringEnd:	
    .word 0 /* version number */
	
        /* A0 pointer to driver parameter block */	
	/* A1 pointer to driver device control entry */
	ALIGN 2
_NuBusFPGAOpen:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	JSR			cNuBusFPGAOpen
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts
_NuBusFPGAOpenError:
	moveq #-23,%d0 /*  error flag */
	rts

_NuBusFPGACtl:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGACtl
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts

_NuBusFPGAStatus:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGAStatus
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts

_NuBusFPGAClose:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGAClose
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts

	.include "NuBusFPGADrvr_OpenClose.s"
	.text
	.include "NuBusFPGADrvr_Ctrl.s"
	.text
	.include "NuBusFPGADrvr_Status.s"
	.text
	
	ALIGN 2
