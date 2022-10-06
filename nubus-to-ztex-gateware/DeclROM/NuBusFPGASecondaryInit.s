
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	BeginSecondary-.						/* Offset to code. */
	
BeginSecondary:
	MOVE.L		%A0, -(%A7)
	movea.l #0xfc90001c, %a0
	move.l  #0xcccccccc, (%a0)
	BSR			Secondary
	movea.l #0xfc90001c, %a0
	move.l  #0xdddddddd, (%a0)
	MOVE.L		(%A7)+, %a0
	rts
