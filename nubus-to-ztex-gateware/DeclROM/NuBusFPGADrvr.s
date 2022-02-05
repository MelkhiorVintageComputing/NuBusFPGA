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
	BTST		#9,%a0@(ioTrap) /* noQueueBit is 9 */   	
	BEQ.S		_GoIODone
	rts

_NuBusFPGAStatus:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGAStatus
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	BTST		#9,%a0@(ioTrap) /* noQueueBit is 9 */   	
	BEQ.S		_GoIODone
	rts

_NuBusFPGAClose:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGAClose
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts
	
_GoIODone:	
	/*  MOVEA.L    JIODone,%A0 */
	/*	JMP        (%A0) */
	movel JIODone,%sp@-
	rts

	.include "NuBusFPGADrvr_OpenClose.s"
	.text
	.include "NuBusFPGADrvr_Ctrl.s"
	.text
	.include "NuBusFPGADrvr_Status.s"
	.text
	
    ALIGN  2
interruptRoutine:
	moveal %a1,%a0
	addal #0x0090000c,%a0 /* FIXME */
	MOVEQ		#1,%D0
	_SwapMMUMode         
	clrb %a0@ /*  we only need to write */
	_SwapMMUMode
	movel %a1,%d0
	roll #8,%d0
	andiw #15,%d0
	moveal #0xd28,%a0 /*  JVBLTask */
	/* other codes don't need the intermediate moveal, what's the proper syntax ? */
	moveal (%a0),%a0
	jsr (%a0)
	moveq #1,%d0
	rts


    ALIGN  2
