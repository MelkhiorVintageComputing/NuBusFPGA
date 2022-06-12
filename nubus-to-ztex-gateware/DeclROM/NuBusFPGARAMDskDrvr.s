NuBusFPGARAMDskDrvr:	
    .word  	    0x4f00             /* 0x4f00: ctl, status, read, write, needsLock [Devices.a] */
    .word          0
    .word          0
    .word          0
  /* Entry point offset table */
    .word		_NuBusFPGARAMDskOpen  - NuBusFPGARAMDskDrvr  /* open routine */
	.word		_NuBusFPGARAMDskPrime - NuBusFPGARAMDskDrvr  /* prime */
	.word		_NuBusFPGARAMDskCtl   - NuBusFPGARAMDskDrvr  /* control */
	.word		_NuBusFPGARAMDskStatus- NuBusFPGARAMDskDrvr  /* status */
	.word		_NuBusFPGARAMDskClose - NuBusFPGARAMDskDrvr  /* close */
	
_NuBusFPGARAMDskTitle:
	.byte _NuBusFPGARAMDskTitle_StringEnd-.-1  /* pascal string length */
	.ascii ".NuBusFPGARAMDsk_Drvr"
_NuBusFPGARAMDskTitle_StringEnd:	
    .word 0 /* version number */
	
        /* A0 pointer to driver parameter block */	
	/* A1 pointer to driver device control entry */
	ALIGN 2
_NuBusFPGARAMDskOpen:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	JSR			cNuBusFPGARAMDskOpen
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	rts
_NuBusFPGARAMDskOpenError:
	moveq #-23,%d0 /*  error flag */
	rts

_NuBusFPGARAMDskPrime:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGARAMDskPrime
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	BTST		#9,%a0@(ioTrap) /* noQueueBit is 9 */   	
	BEQ.S		_RAMDskGoIODone
	rts

_NuBusFPGARAMDskCtl:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGARAMDskCtl
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	BTST		#9,%a0@(ioTrap) /* noQueueBit is 9 */   	
	BEQ.S		_RAMDskGoIODone
	rts

_NuBusFPGARAMDskStatus:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGARAMDskStatus
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1
	BTST		#9,%a0@(ioTrap) /* noQueueBit is 9 */   	
	BEQ.S		_RAMDskGoIODone
	rts

_NuBusFPGARAMDskClose:
	MOVE.L		%A1, -(%A7)
	MOVE.L		%A0, -(%A7)
	jsr			cNuBusFPGARAMDskClose
	MOVE.L		(%A7)+, %a0
	MOVE.L		(%A7)+, %a1

MyAddDrive:
	LINK      %A6,#0
	CLR.L     %D0
	MOVE.W    10(%A6),%D0
	SWAP      %D0
	MOVE.W    8(%A6),%D0
	MOVEA.L   12(%A6),%A0
	DC.W      0xA04E  /* _AddDrive */
	UNLK      %A6
	RTS
	
_RAMDskGoIODone:	
	/*  MOVEA.L    JIODone,%A0 */
	/*	JMP        (%A0) */
	movel JIODone,%sp@-
	rts

	.include "NuBusFPGARAMDskDrvr_OpenClose.s"
	.text
	.include "NuBusFPGARAMDskDrvr_Prime.s"
	.text
	.include "NuBusFPGARAMDskDrvr_Ctrl.s"
	.text
	.include "NuBusFPGARAMDskDrvr_Status.s"
	.text
	.include "myrle.s"
	.text
	
	ALIGN 2
