/*
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -Os -S blit.c -march=rv32ib -mabi=ilp32 -mstrict-align -fno-builtin-memset -nostdlib -ffreestanding -nostartfiles
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -Os -o blit -march=rv32ib -mabi=ilp32 -T blit.lds  -nostartfiles blit.s
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-objcopy  -O binary -j .text blit blit.raw
*/

#ifndef HRES
#define HRES 1920
#warning "Using default HRES"
#endif
#ifndef VRES
#define VRES 1080
#warning "Using default VRES"
#endif
#ifndef BASE_FB
#define BASE_FB  0x8F800000 // FIXME : should be generated ; 2+ MiB of SDRAM as framebuffer
#warning "Using default BASE_FB"
#endif

#define BASE_ROM 0xF0910000 // FIXME : should be generated ; 4-64 KiB of Wishbone ROM ? ; also in the LDS file ; also in the Vex config

#define BASE_RAM 0xF0902000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start
#define BASE_RAM_SIZE 0x00001000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start

#define BASE_BT_REGS    0xF0900000
#define BASE_ACCEL_REGS 0xF0901000

#define mul_sHRES(a) ((a) * sHRES)

//typedef void (*boot_t)(void);
//typedef void (*start_t)(unsigned short, unsigned short, unsigned short, unsigned short, unsigned short, unsigned short, unsigned short, unsigned short);

typedef unsigned int uint32_t;
typedef volatile unsigned int u_int32_t;

/*
struct control_blitter {
	volatile unsigned int fun;
	volatile unsigned int done;
	volatile unsigned short arg[8];
};
*/

#define FUN_BLIT_BIT            0 // hardwired in goblin_accel.py
#define FUN_FILL_BIT            1 // hardwired in goblin_accel.py
#define FUN_TEST_BIT            3 // hardwired in goblin_accel.py
#define FUN_DONE_BIT           31
#define FUN_BLIT           (1<<FUN_BLIT_BIT)
#define FUN_FILL           (1<<FUN_FILL_BIT)
#define FUN_TEST           (1<<FUN_TEST_BIT)
#define FUN_DONE           (1<<FUN_DONE_BIT)

struct goblin_bt_regs {
	u_int32_t mode;
	u_int32_t vbl_mask;
	u_int32_t videoctrl;
	u_int32_t intr_clear;
	u_int32_t reset;
	u_int32_t lut_addr;
	u_int32_t lut;
	u_int32_t debug;
};

enum goblin_bt_mode {
					 mode_1bit =  0x00,
					 mode_2bit =  0x01,
					 mode_4bit =  0x02,
					 mode_8bit =  0x03,
					 mode_32bit = 0x10,
					 mode_16bit = 0x11
};

struct goblin_accel_regs {
	u_int32_t reg_status; // 0
	u_int32_t reg_cmd;
	u_int32_t reg_r5_cmd;
	u_int32_t resv0;
	u_int32_t reg_width; // 4
	u_int32_t reg_height;
	u_int32_t reg_fgcolor;
	u_int32_t resv2;
	u_int32_t reg_bitblt_src_x; // 8
	u_int32_t reg_bitblt_src_y;
	u_int32_t reg_bitblt_dst_x;
	u_int32_t reg_bitblt_dst_y;
	u_int32_t reg_chk_adr; // 12
	u_int32_t reg_chk_val; // 13
};

//#include "./rvintrin.h"

void from_reset(void) __attribute__ ((noreturn)); // nothrow, 

static inline void flush_cache(void) {
	asm volatile(".word 0x0000500F\n"); // flush the Dcache so that we get updated data
}

typedef unsigned int unsigned_param_type;

static void rectfill(const unsigned_param_type xd,
					 const unsigned_param_type yd,
					 const unsigned_param_type wi,
					 const unsigned_param_type re,
					 const unsigned_param_type color,
					 const unsigned_param_type sHRES
					 );
static void rectfill_pm(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned char pm,
						const unsigned_param_type sHRES
						);
static void xorrectfill(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned_param_type sHRES
						);
static void xorrectfill_pm(const unsigned_param_type xd,
						   const unsigned_param_type yd,
						   const unsigned_param_type wi,
						   const unsigned_param_type re,
						   const unsigned_param_type color,
						   const unsigned char pm,
						   const unsigned_param_type sHRES
						);
static void invert(const unsigned_param_type xd,
				   const unsigned_param_type yd,
				   const unsigned_param_type wi,
				   const unsigned_param_type re,
				   const unsigned_param_type sHRES
				   );
static void bitblit(const unsigned_param_type xs,
					const unsigned_param_type ys,
					const unsigned_param_type wi,
					const unsigned_param_type re,
					const unsigned_param_type xd,
					const unsigned_param_type yd,
					const unsigned char pm,
					const unsigned char gxop,
					const unsigned_param_type sHRES
					);

static void print_hexword(unsigned int v, unsigned int bx, unsigned int by);
static void show_status_on_screen(void);

asm(".global _start\n"
	"_start:\n"
	// ".word 0x0000500F\n" // flush cache ; should not be needed after reset
	//"addi sp,zero,66\n" // 0x0042
	//"slli sp,sp,16\n" // 0x00420000, BASE_RAM
	//"addi a0,zero,1\n" // 0x0001
	//"slli a0,a0,12\n" // 0x00001000, BASE_RAM_SIZE
	//"add sp,sp,a0\n" // SP at the end of the SRAM
	"nop\n"
	"li sp, 0xF0902ffc\n" // SP at the end of the SRAM
	//"li a0, 0x00700968\n" // @ of r5_cmd
	//"li a1, 0x00C0FFEE\n"
	//"sw a1, 0(a0)\n"
	"call from_reset\n"
	".size	_start, .-_start\n"
	".align	4\n"
	".globl	_start\n"
	".type	_start, @function\n"
	);

#define imax(a,b) (((a)>(b))?(a):(b))
#define imin(a,b) (((a)<(b))?(a):(b))

#define DEBUG
#ifdef DEBUG
#define SHOW_FUN(a) /* fbc->fbc_r5_status[0] = a */
#define SHOW_PC() /* SHOW_FUN(cmd); do { u_int32_t rd; asm volatile("auipc %[rd], 0" : [rd]"=r"(rd) ) ; fbc->fbc_r5_status[1] = rd; } while (0) */
#define SHOW_PC_2VAL(a, b) /* SHOW_PC(); fbc->fbc_r5_status[2] = a; fbc->fbc_r5_status[3] = b */
#else
#define SHOW_FUN(a)
#define SHOW_PC()
#define SHOW_PC_2VAL(a, b)
#endif

/* need some way to have identifiable proc# and multiple struct control_blitter for //ism */
/* First need  to set up essential C stuff like the stack */
/* maybe pass core-id as the first parameter (in a0) to everyone */
/* also need to figure out the non-coherent caches ... */
void from_reset(void) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	struct goblin_bt_regs* fbt = (struct goblin_bt_regs*)BASE_BT_REGS;
	unsigned int cmd = fbc->reg_r5_cmd;
	unsigned_param_type sHRES;
	switch ((fbt->mode>>24) & 0xFF) { // mode is 8 bits wrong-endian (all fbt is wrong-endian)
	case mode_32bit:
		sHRES = HRES * 4;
		break;
	case mode_16bit:
		sHRES = HRES * 2;
		break;
	default:
		sHRES = HRES;
		break;
	}

	switch (cmd & 0xF) {
	case FUN_BLIT: {
		bitblit(fbc->reg_bitblt_src_x, fbc->reg_bitblt_src_y,
				fbc->reg_width, fbc->reg_height,
				fbc->reg_bitblt_dst_x, fbc->reg_bitblt_dst_y,
				0xFF, 0x3, sHRES); // GXcopy
	} break;
	case FUN_FILL: {
		rectfill(fbc->reg_bitblt_dst_x, fbc->reg_bitblt_dst_y,
				 fbc->reg_width, fbc->reg_height,
				 fbc->reg_fgcolor, sHRES);
	} break;
#if 1
	case FUN_TEST: {
		u_int32_t val = fbc->reg_chk_val;
		u_int32_t* ptr = (u_int32_t*)fbc->reg_chk_adr;
		u_int32_t pval = (*ptr);
		fbc->reg_chk_val = (val ^ pval);
		if (pval == 0x01234567)
			fbc->reg_chk_adr = 1;
		else if (pval == 0x67452301)
			fbc->reg_chk_adr = 0;
		else
			fbc->reg_chk_adr = -1;
	} break;
#endif
	default:
		break;
	}

 finish:
	
	// make sure we have nothing left in the cache
	flush_cache();

	fbc->reg_r5_cmd = FUN_DONE;

 done:
	/* wait for reset */
	goto done;
}

#define bitblit_proto_int(a, b, suf)									\
	static void bitblit##a##b##suf(const unsigned_param_type xs,		\
								   const unsigned_param_type ys,		\
								   const unsigned_param_type wi,		\
								   const unsigned_param_type re,		\
								   const unsigned_param_type xd,		\
								   const unsigned_param_type yd,		\
								   const unsigned char pm,				\
								   const unsigned_param_type sHRES			\
							)
#define bitblit_proto(suf)						\
	bitblit_proto_int(_fwd, _fwd, suf);			\
	bitblit_proto_int(_bwd, _fwd, suf);			\
	bitblit_proto_int(_fwd, _bwd, suf)
//	bitblit_proto_int(_bwd, _bwd, suf);

bitblit_proto(_copy);
bitblit_proto(_xor);
bitblit_proto(_copy_pm);
bitblit_proto(_xor_pm);


#define ROUTE_BITBLIT_PM(pm, bb)							\
	if (pm == 0xFF) bb(xs, ys, wi, re, xd, yd, pm, sHRES);	\
	else bb##_pm(xs, ys, wi, re, xd, yd, pm, sHRES)

static void bitblit(const unsigned_param_type xs,
					const unsigned_param_type ys,
					const unsigned_param_type wi,
					const unsigned_param_type re,
					const unsigned_param_type xd,
					const unsigned_param_type yd,
					const unsigned char pm,
					const unsigned char gxop,
					const unsigned_param_type sHRES
			 ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	
	if (ys > yd) {
		switch(gxop) {
		case 0x3: // GXcopy
			ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_copy);
			break;
		case 0x6: // GXxor
			ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_xor);
			break;
		}
	} else if (ys < yd) {
		switch(gxop) {
		case 0x3: // GXcopy
			ROUTE_BITBLIT_PM(pm, bitblit_bwd_fwd_copy);
			break;
		case 0x6: // GXxor
			ROUTE_BITBLIT_PM(pm, bitblit_bwd_fwd_xor);
			break;
		}
	} else { // ys == yd
		if (xs > xd) {
			switch(gxop) {
			case 0x3: // GXcopy
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_copy);
				break;
			case 0x6: // GXxor
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_xor);
				break;
			}
		} else if (xs < xd) {
			switch(gxop) {
			case 0x3: // GXcopy
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_bwd_copy);
				break;
			case 0x6: // GXxor
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_bwd_xor);
				break;
			}
		} else { // xs == xd
			switch(gxop) {
			case 0x3: // GXcopy
				/* don't bother */
				break;
			case 0x6:  // GXxor
				rectfill_pm(xd, yd, wi, re, 0, pm, sHRES);
				break;
			}
		}
	}
 }


static void rectfill(const unsigned_param_type xd,
					 const unsigned_param_type yd,
					 const unsigned_param_type wi,
					 const unsigned_param_type re,
					 const unsigned_param_type color,
					 const unsigned_param_type sHRES
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd);
	unsigned char *dptr_line = dptr;
	unsigned char u8color = color & 0xFF;

	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			*dptr_elt = u8color;
			dptr_elt ++;
		}
		if (wi > 3) {
			unsigned int u32color = (unsigned int)u8color | ((unsigned int)u8color)<<8 | ((unsigned int)u8color)<<16 | ((unsigned int)u8color)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = u32color;
				dptr_elt +=4;
			}
		}	
		for ( ; i < wi ; i++) {
			*dptr_elt = u8color;
			dptr_elt ++;
		}
		dptr_line += sHRES;
	}
}

static void rectfill_pm(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned char pm,
						const unsigned_param_type sHRES
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd);
	unsigned char *dptr_line = dptr;
	unsigned char u8color = color;

	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			*dptr_elt = (u8color & pm) | (*dptr_elt & ~pm);
			dptr_elt ++;
		}
		if (wi > 3) {
			unsigned int u32color = (unsigned int)u8color | ((unsigned int)u8color)<<8 | ((unsigned int)u8color)<<16 | ((unsigned int)u8color)<<24;
			unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = (u32color & u32pm) | (*(unsigned int*)dptr_elt & ~u32pm);
				dptr_elt +=4;
			}
		}
		for ( ; i < wi ; i++) {
			*dptr_elt = (u8color & pm) | (*dptr_elt & ~pm);
			dptr_elt ++;
		}
		dptr_line += sHRES;
	}
}


static void xorrectfill(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned_param_type sHRES
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd);
	unsigned char *dptr_line = dptr;
	unsigned char u8color = color & 0xFF;

	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			*dptr_elt ^= u8color;
			dptr_elt ++;
		}
		if (wi > 3) {
			unsigned int u32color = (unsigned int)u8color | ((unsigned int)u8color)<<8 | ((unsigned int)u8color)<<16 | ((unsigned int)u8color)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt ^= u32color;
				dptr_elt +=4;
			}
		}	
		for ( ; i < wi ; i++) {
			*dptr_elt ^= u8color;
			dptr_elt ++;
		}
		dptr_line += sHRES;
	}
}
static void xorrectfill_pm(const unsigned_param_type xd,
						   const unsigned_param_type yd,
						   const unsigned_param_type wi,
						   const unsigned_param_type re,
						   const unsigned_param_type color,
						   const unsigned char pm,
						   const unsigned_param_type sHRES
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd);
	unsigned char *dptr_line = dptr;
	unsigned char u8color = color;

	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			*dptr_elt ^= (u8color & pm);
			dptr_elt ++;
		}
		if (wi > 3) {
			unsigned int u32color = (unsigned int)u8color | ((unsigned int)u8color)<<8 | ((unsigned int)u8color)<<16 | ((unsigned int)u8color)<<24;
			unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt ^= (u32color & u32pm);
				dptr_elt +=4;
			}
		}
		for ( ; i < wi ; i++) {
			*dptr_elt ^= (u8color & pm);
			dptr_elt ++;
		}
		dptr_line += sHRES;
	}
}

static void invert(const unsigned_param_type xd,
				   const unsigned_param_type yd,
				   const unsigned_param_type wi,
				   const unsigned_param_type re,
				   const unsigned_param_type sHRES
				   ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd);
	unsigned char *dptr_line = dptr;
	
	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			*dptr_elt = ~(*dptr_elt);
			dptr_elt ++;
		}
		if (wi > 3) {
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = ~(*(unsigned int*)dptr_elt);
				dptr_elt +=4;
			}
		}
		for ( ; i < wi ; i++) {
			*dptr_elt = ~(*dptr_elt);
			dptr_elt ++;
		}
		dptr_line += sHRES;
	}
}


// NOT using npm enables the use of 'cmix' in more cases
#define COPY(d,s,pm,npm) (d) = (s)
//#define COPY_PM(d,s,pm,npm) (d) = (((s) & (pm)) | ((d) & (npm)))
#define COPY_PM(d,s,pm,npm) (d) = (((s) & (pm)) | ((d) & (~pm)))
#define XOR(d,s,pm,npm) (d) = ((s) ^ (d))
//#define XOR_PM(d,s,pm,npm) (d) = ((((s) ^ (d)) & (pm)) | ((d) & (npm)))
#define XOR_PM(d,s,pm,npm) (d) = ((((s) ^ (d)) & (pm)) | ((d) & (~pm)))

#define BLIT_FWD_FWD(NAME, OP)											\
	static void bitblit_fwd_fwd_##NAME(const unsigned_param_type xs,	\
									   const unsigned_param_type ys,	\
									   const unsigned_param_type wi,	\
									   const unsigned_param_type re,	\
									   const unsigned_param_type xd,	\
									   const unsigned_param_type yd,	\
									   const unsigned char pm,			\
									   const unsigned_param_type sHRES) {		\
	unsigned int i, j;													\
	unsigned char *sptr = (((unsigned char *)BASE_FB) + mul_sHRES(ys) + xs); \
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd); \
	unsigned char *sptr_line = sptr;									\
	unsigned char *dptr_line = dptr;									\
	/*const unsigned char npm = ~pm;*/									\
																		\
	for (j = 0 ; j < re ; j++) {										\
		unsigned char *sptr_elt = sptr_line;							\
		unsigned char *dptr_elt = dptr_line;							\
		i = 0;															\
		if (wi>3) {														\
			if ((xs & 0x3) || (xd & 0x3)) {								\
				for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) { \
					OP(*dptr_elt, *sptr_elt, pm, npm);					\
					dptr_elt ++;										\
					sptr_elt ++;										\
				}														\
				unsigned char *sptr_elt_al = (unsigned char*)((unsigned int)sptr_elt & ~0x3); \
				unsigned int fsr_cst = 8*((unsigned int)sptr_elt & 0x3); \
				unsigned int src0 = ((unsigned int*)sptr_elt_al)[0];	\
				unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24; \
				for ( ; i < (wi-3) ; i+=4) {							\
					unsigned int src1 = ((unsigned int*)sptr_elt_al)[1]; \
					unsigned int val;									\
					asm("fsr %0, %1, %2, %3\n" : "=r"(val) : "r"(src0), "r"(src1), "r"(fsr_cst)); \
					OP(*(unsigned int*)dptr_elt, val, u32pm, u32npm);	\
					src0 = src1;										\
					dptr_elt += 4;										\
					sptr_elt_al += 4;									\
				}														\
				sptr_elt = sptr_elt_al + ((unsigned int)sptr_elt & 0x3); \
			} else {													\
				const unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24; \
				/*const unsigned int u32npm = (unsigned int)npm | ((unsigned int)npm)<<8 | ((unsigned int)npm)<<16 | ((unsigned int)npm)<<24;*/ \
				if (((xs & 0xf) == 0) && ((xd & 0xf) == 0)) {			\
					for ( ; i < (wi&(~0xf)) ; i+= 16) {					\
						OP(((unsigned int*)dptr_elt)[0], ((unsigned int*)sptr_elt)[0], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[1], ((unsigned int*)sptr_elt)[1], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[2], ((unsigned int*)sptr_elt)[2], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[3], ((unsigned int*)sptr_elt)[3], u32pm, u32npm); \
						dptr_elt += 16;									\
						sptr_elt += 16;									\
					}													\
				}														\
				for ( ; i < (wi&(~3)) ; i+= 4) {						\
					OP(((unsigned int*)dptr_elt)[0], ((unsigned int*)sptr_elt)[0], u32pm, u32npm); \
					dptr_elt += 4;										\
					sptr_elt += 4;										\
				}														\
			}															\
		}																\
		for ( ; i < wi ; i++) {											\
			OP(*dptr_elt, *sptr_elt, pm, npm);							\
			dptr_elt ++;												\
			sptr_elt ++;												\
		}																\
		sptr_line += sHRES;												\
		dptr_line += sHRES;												\
	}																	\
	}

#define BLIT_FWD_BWD(NAME, OP) \
	static void bitblit_fwd_bwd_##NAME(const unsigned_param_type xs,	\
									   const unsigned_param_type ys,	\
									   const unsigned_param_type wi,	\
									   const unsigned_param_type re,	\
									   const unsigned_param_type xd,	\
									   const unsigned_param_type yd,	\
									   const unsigned char pm,			\
									   const unsigned_param_type sHRES) {		\
		unsigned int i, j;												\
		unsigned char *sptr = (((unsigned char *)BASE_FB) + mul_sHRES(ys) + xs); \
		unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd); \
		unsigned char *sptr_line = sptr + wi - 1;						\
		unsigned char *dptr_line = dptr + wi - 1;						\
		const unsigned char npm = ~pm;									\
																		\
		for (j = 0 ; j < re ; j++) {									\
			unsigned char *sptr_elt = sptr_line;						\
			unsigned char *dptr_elt = dptr_line;						\
			for (i = 0 ; i < wi ; i++) {								\
				OP(*dptr_elt, *sptr_elt, pm, npm);						\
				dptr_elt --;											\
				sptr_elt --;											\
			}															\
			sptr_line += sHRES;											\
			dptr_line += sHRES;											\
		}																\
	}

#define BLIT_BWD_FWD(NAME, OP)											\
	static void bitblit_bwd_fwd_##NAME(const unsigned_param_type xs,	\
									   const unsigned_param_type ys,	\
									   const unsigned_param_type wi,	\
									   const unsigned_param_type re,	\
									   const unsigned_param_type xd,	\
									   const unsigned_param_type yd,	\
									   const unsigned char pm,			\
									   const unsigned_param_type sHRES) {		\
	unsigned int i, j;													\
	unsigned char *sptr = (((unsigned char *)BASE_FB) + mul_sHRES(ys) + xs); \
	unsigned char *dptr = (((unsigned char *)BASE_FB) + mul_sHRES(yd) + xd); \
	unsigned char *sptr_line = sptr + mul_sHRES(re-1);					\
	unsigned char *dptr_line = dptr + mul_sHRES(re-1);					\
	const unsigned char npm = ~pm;										\
																		\
	for (j = 0 ; j < re ; j++) {										\
		unsigned char *sptr_elt = sptr_line;							\
		unsigned char *dptr_elt = dptr_line;							\
		i = 0;															\
		if (wi>3) {														\
			if ((xs & 0x3) || (xd & 0x3)) {								\
				for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) { \
					OP(*dptr_elt, *sptr_elt, pm, npm);					\
					dptr_elt ++;										\
					sptr_elt ++;										\
				}														\
				unsigned char *sptr_elt_al = (unsigned char*)((unsigned int)sptr_elt & ~0x3); \
				unsigned int fsr_cst = 8*((unsigned int)sptr_elt & 0x3); \
				unsigned int src0 = ((unsigned int*)sptr_elt_al)[0];	\
				unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24; \
				for ( ; i < (wi-3) ; i+=4) {							\
					unsigned int src1 = ((unsigned int*)sptr_elt_al)[1]; \
					unsigned int val;									\
					asm("fsr %0, %1, %2, %3\n" : "=r"(val) : "r"(src0), "r"(src1), "r"(fsr_cst)); \
					OP(*(unsigned int*)dptr_elt, val, u32pm, u32npm);	\
					src0 = src1;										\
					dptr_elt += 4;										\
					sptr_elt_al += 4;									\
				}														\
				sptr_elt = sptr_elt_al + ((unsigned int)sptr_elt & 0x3); \
			} else {													\
				if (((xs & 0xf) == 0) && ((xd & 0xf) == 0)) {			\
					for ( ; i < (wi&(~0xf)) ; i+= 16) {					\
						const unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24; \
						/*const unsigned int u32npm = (unsigned int)npm | ((unsigned int)npm)<<8 | ((unsigned int)npm)<<16 | ((unsigned int)npm)<<24;*/ \
						OP(((unsigned int*)dptr_elt)[0], ((unsigned int*)sptr_elt)[0], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[1], ((unsigned int*)sptr_elt)[1], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[2], ((unsigned int*)sptr_elt)[2], u32pm, u32npm); \
						OP(((unsigned int*)dptr_elt)[3], ((unsigned int*)sptr_elt)[3], u32pm, u32npm); \
						dptr_elt += 16;									\
						sptr_elt += 16;									\
					}													\
				}														\
				if (((xs & 0x3) == 0) && ((xd & 0x3) == 0)) {			\
					for ( ; i < (wi&(~3)) ; i+= 4) {					\
						const unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24; \
						/*const unsigned int u32npm = (unsigned int)npm | ((unsigned int)npm)<<8 | ((unsigned int)npm)<<16 | ((unsigned int)npm)<<24;*/ \
						OP(((unsigned int*)dptr_elt)[0], ((unsigned int*)sptr_elt)[0], u32pm, u32npm); \
						dptr_elt += 4;									\
						sptr_elt += 4;									\
					}													\
				}														\
			}															\
		}																\
		for ( ; i < wi ; i++) {											\
			OP(*dptr_elt, *sptr_elt, pm, npm);							\
			dptr_elt ++;												\
			sptr_elt ++;												\
		}																\
		sptr_line -= sHRES;												\
		dptr_line -= sHRES;												\
	}																	\
	}


#define BLIT_ALLDIR(NAME, OP)				\
	BLIT_FWD_FWD(NAME, OP)					\
	BLIT_FWD_BWD(NAME, OP)					\
	BLIT_BWD_FWD(NAME, OP)					\
	

BLIT_ALLDIR(copy, COPY)
BLIT_ALLDIR(xor, XOR)
BLIT_ALLDIR(copy_pm, COPY_PM)
BLIT_ALLDIR(xor_pm, XOR_PM)
	
