
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	BeginSecondary-.						/* Offset to code. */
	
BeginSecondary:	
	movew		#1,%A0@(seStatus)				/* VendorStatus <- 1 {Code was executed} */
	movel		%A0,%A3						/* save param block */
    /* Set up a slot parameter block in %A0 */
	SUBA		#smParamBlockSize,%SP				/* make an SDM parameter block on stack */
	movel		%SP,%A0						/* get pointer to parm block now */
	MOVE.B		seSlot(%A3),spSlot(%A0)		/* put slot in pBlock */
	CLR.B		spExtDev(%A0)				/* external device = 0 */
	
	moveq        #8,%D0	 /* _sVersion ; find the Slot Manager version */
	.word        0xA06E /* _sVersion ; find the Slot Manager version */
	
	MOVEL	     spResult(%A0),%D1 /* recover result */
	ADDA #smParamBlockSize,%SP /* drop the slot Parameter block */
	
	moveq		#0,%D0						/* D0 <- 00000000 */
	MOVEB 		%A3@(seSlot),%D0			/* D0 <- 0000000s */
	LSLW		#4,%D0						/* D0 <- 000000s0 */
	/* OR.B %A3@(seSlot),%D0			    /* D0 <- 000000ss */
	OR.W		#0xF00,%D0					/* D0 <- 00000Fs0 */
	SWAP		%D0							/* D0 <- 0Fs00000 */
	LSLL		#4,%D0						/* D0 <- Fs000000 */
    MOVEAL      %D0,%A1
	
	/* param block in %A3, our HW (32-bits mode) in %A1 */
	addl #0x00900000, %A1
	movel #0x0f0f0f0f,%A1@(0x1c) /* marker to qemu */
	movel %D1,%A1@(0x1c)  /*_sVersion spResult to Qemu */
	
ExitSecondary:
	RTS									/* Return */

