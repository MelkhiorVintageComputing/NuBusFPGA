
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	Begin-.						/* Offset to code. */
	
Begin:	
	movew #1,%A0@(seStatus)				/* VendorStatus <- 1 {Code was executed} */
	movel	%A0,%A3						/* save param block {A0 is destroyed} */

/*   Turn the slot number into a base address. */
				moveq	#0,%D0						/* D0 <- 00000000 */
				MOVE.B %A0@(seSlot),%D0				/* D0 <- 0000000s */
				LSL.W	#4,%D0						/* D0 <- 000000s0 */
				/* OR.B %A0@(seSlot),%D0			    /* D0 <- 000000ss */
				OR.W	#0xF00,%D0					/* D0 <- 00000Fss */
				SWAP	%D0							/* D0 <- 0Fss0000 */
				LSL.L	#4,%D0						/* D0 <- Fss00000 */
				movel	%D0,%A2						/* A2 <- Base address to the slot. */


/*   Reset the hardware. */
/*   DO YOUR RESET STUFF HERE */

/*   Set mode to one bit per pixel.					; */
/*   DO YOUR MODE SETTING HERE				 */
				
/*   Disable interrupts.								; */
				movel	%A2,%A0						/* get slot base */
				ADD.L	#0x00900004,%A0				/* Adjust the base */ /* FIXME */
				CLR.B	(%A0)						/* Disable interrupt from card */

/*  set the color table to black and white */
/*  SET THE TABLE HERE */


/*  The Apple Video card configuration ROM has two video sResources conforming to the */
/*  two possible different memory configurations.  Now we want to figure out which */
/*  of the configurations we have, and delete the incorrect video sResource from */
/*  the slot resource table. */
/*  */
/*   size the RAM on the video card.  To do this, we look for a nice longword in the second */
/* 	half of the frame buffer array that doesn't show up on the screen.  I've selected the */
/* 	last longword of the first scanline that is a multiple of 8 in the second RAM bank (line 264).   */
/* 	This alignment guarantees that this memory is off the right edge in all pixel depths */
/* 	when the frame buffer base addr is on a normal page boundary. */
/*  */
/*  */
/*  */
TestPos			=		(265*1024)-4				/* 	 */
TestPat			=		0x4d434132						/* test bit pattern */
				
				SUBA	#smParamBlockSize,%SP				/* make an SDM parameter block on stack */
				movel	%SP,%A0						/* get pointer to parm block now */
				MOVE.B	seSlot(%A3),spSlot(%A0)		/* put slot in pBlock */
				CLR.B	spExtDev(%A0)				/* external device = 0 */
				
/*				movel	#TestPos,%D1					/* get offset in %D1 */
/*				movel	#TestPat,(%A2,%D1.L)			/* write to alleged RAM */
/*				movel	#-1,-(%SP)					/* write out some garbage to clear data lines */
/*				ADDQ	#4,%SP						/* and pitch it */
/*				movel	(%A2,%D1.L),%D0				/* read pattern back */
/*				CMP.L	#TestPat,%D0					/* did it stick? */
/*				BEQ.S	ram							/* if equal, we have ram */
/*				MOVE.B	#sRsrc_Video8,spID(%A0)		/* if not, remove 8-bit table */
/*				BRA.S	noram
/*ram:	
/*				MOVE.B	#sRsrc_Video4,spID(%A0)		/* remove 4-bit table if we have ram */
/*noram:	
	/*				_sDeleteSRTRec		*/				/* remove the invalid entry */
/*	movel #SDeleteSRTRec,%d0
/*	_SlotManager
/*				BNE.S	done							/*  */
				MOVE	#2,seStatus(%A3)				/* mark the change */
done:	ADDA	#smParamBlockSize,%SP				/* clean up */

/*   Clear video RAM to a nice gray */
				movel	#0xAAAAAAAA,%D0				/* graypat1 := $AAAAAAAA */
				movel	%D0,%D1
				NOT.L	%D1

				MOVE.W	#defScrnRow,%D4				/* sRow := defScrnRow		{Bytes per pixel line} */
				MOVE.W	#defmBounds_Bs-1,%D3				/* sHei := defScrnHeight	{Screen Height in pixels} */
                
				movel	%A2,%A1						/* init row pointer         															/* REPEAT */
NxtRow:			movel	%A1,%A0						/* get next row */
				MOVE.W	#defScrnRow/4-1,%D2			/*   rowlongs := defScrnRow/4 - 1 {How many Longs there are} */
NxtLong:		movel	%D0,(%A0)+					/*     (%A0) := graypat(1/2) */
				DBF		%D2,NxtLong					/*   UNTIL rowlongs < 0 */
				EXG		%D0,%D1						/*   graypat1 <-> graypat2 */
				ADD.W	%D4,%A1						/*   %A1 := %A1 + sRow */
				DBF		%D3,NxtRow					/* UNTIL sHei < 0 */

/*   Exit */
Exit:	RTS									/* Return */


/* <PUT YOUR VALUES FOR INIT TABLE, OTHER TABLES, ETC. HERE IF NEEDED> */

/* END PrimaryInit */



