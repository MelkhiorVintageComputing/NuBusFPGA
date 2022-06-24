#pragma once

asm(".set regnum_x0  ,  0");
asm(".set regnum_x1  ,  1");
asm(".set regnum_x2  ,  2");
asm(".set regnum_x3  ,  3");
asm(".set regnum_x4  ,  4");
asm(".set regnum_x5  ,  5");
asm(".set regnum_x6  ,  6");
asm(".set regnum_x7  ,  7");
asm(".set regnum_x8  ,  8");
asm(".set regnum_x9  ,  9");
asm(".set regnum_x10 , 10");
asm(".set regnum_x11 , 11");
asm(".set regnum_x12 , 12");
asm(".set regnum_x13 , 13");
asm(".set regnum_x14 , 14");
asm(".set regnum_x15 , 15");
asm(".set regnum_x16 , 16");
asm(".set regnum_x17 , 17");
asm(".set regnum_x18 , 18");
asm(".set regnum_x19 , 19");
asm(".set regnum_x20 , 20");
asm(".set regnum_x21 , 21");
asm(".set regnum_x22 , 22");
asm(".set regnum_x23 , 23");
asm(".set regnum_x24 , 24");
asm(".set regnum_x25 , 25");
asm(".set regnum_x26 , 26");
asm(".set regnum_x27 , 27");
asm(".set regnum_x28 , 28");
asm(".set regnum_x29 , 29");
asm(".set regnum_x30 , 30");
asm(".set regnum_x31 , 31");

asm(".set regnum_zero,  0");
asm(".set regnum_ra  ,  1");
asm(".set regnum_sp  ,  2");
asm(".set regnum_gp  ,  3");
asm(".set regnum_tp  ,  4");
asm(".set regnum_t0  ,  5");
asm(".set regnum_t1  ,  6");
asm(".set regnum_t2  ,  7");
asm(".set regnum_s0  ,  8");
asm(".set regnum_s1  ,  9");
asm(".set regnum_a0  , 10");
asm(".set regnum_a1  , 11");
asm(".set regnum_a2  , 12");
asm(".set regnum_a3  , 13");
asm(".set regnum_a4  , 14");
asm(".set regnum_a5  , 15");
asm(".set regnum_a6  , 16");
asm(".set regnum_a7  , 17");
asm(".set regnum_s2  , 18");
asm(".set regnum_s3  , 19");
asm(".set regnum_s4  , 20");
asm(".set regnum_s5  , 21");
asm(".set regnum_s6  , 22");
asm(".set regnum_s7  , 23");
asm(".set regnum_s8  , 24");
asm(".set regnum_s9  , 25");
asm(".set regnum_s10 , 26");
asm(".set regnum_s11 , 27");
asm(".set regnum_t3  , 28");
asm(".set regnum_t4  , 29");
asm(".set regnum_t5  , 30");
asm(".set regnum_t6  , 31");

#define opcode_ld(opcode, func3, base, imm12, o1, o2)					\
	asm volatile(".word ((" #opcode ") | (regnum_%0 << 7) | (regnum_%2 << 15) | (" #imm12 " << 20) | ((" #func3 ") << 12));" \
				 : "=&r" (o1), "=&r" (o2)								\
				 : "r" (base)											\
				 );														\
	
#define ld(base, imm12, o1, o2) opcode_ld(0x03, 0x03, base, imm12, o1, o2)
#define ldu(base, imm12, o1, o2) opcode_ld(0x03, 0x07, base, imm12, o1, o2)

#define opcode_sd(opcode, func3, base, imm04, imm511, i1, i2)			\
	asm volatile(".word ((" #opcode ") | (" #imm04 " << 7) | (regnum_%0 << 15) | (regnum_%1 << 20) | (" #imm511 " << 25) | ((" #func3 ") << 12));" \
				 :														\
				 : "r" (base), "r" (i1), "r" (i2)						\
				 );														\
 
#define sd(base, imm04, imm511, i1, i2) opcode_sd(0x23, 0x03, base, imm04, imm511, i1, i2)
