
	.byte	sExec2						/* Code revision (Primary init) */
	.byte	sCPU68020					/* CPU type is 68020 */
	.short	0							/* Reserved */
	.long	BeginPrimary-.						/* Offset to code. */
	
BeginPrimary:
	MOVE.L		%A0, -(%A7)
	BSR         Primary
	MOVE.L		(%A7)+, %a0
	rts

