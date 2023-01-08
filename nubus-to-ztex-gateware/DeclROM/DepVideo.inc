.include "res.inc"

NuBusFPGAID = 0xC0

defMinorBase = 0 /*  beginning */
defMinorLength = 0x800000 /* 8192 KiB */

Pages8s = 1
Pages4s = 1
Pages2s = 1
Pages1s = 1
Pages15s = 1
Pages24s = 1

defmBounds_Ls = 0
defmBounds_Ts = 0
defmBounds_Rs = HRES
defmBounds_Bs = VRES

defScrnRow = HRES

/* row bytes */
RB8s = HRES
RB4s = HRES/2
RB2s = HRES/4
RB1s = HRES/8
RB15s = HRES*2
RB24s = HRES*4

DrHwNuBusFPGA = 0xBEEF /*  placeholder for GoboFB */
DrHwNuBusFPGADsk = 0xBEEE /*  placeholder for RAM Dsk */
DrHwNuBusFPGAAudio = 0xBEED /*  placeholder for Audio */

typeDrive = 0x1000 /* placeholder for RAM Dsk*/
typeAudio = 0x1001 /* placeholder for Audio*/

defmBaseOffset = 0 /*  beginning, placeholder */

devVersion = 0 /*  placeholder */

defmHRes = 0x480000 /* Horizontal Pixels/inch */
defmVRes = 0x480000 /* Vertical pixels/inch */

clutType = 0
directType = 2

defmPlaneBytes	= 0 /* Offset from one plane to the next. */

SGammaResID = 0


ChunkyIndexed = 0
ChunkyDirect = 16

defVersion		=		0			/* Version = 0 */
