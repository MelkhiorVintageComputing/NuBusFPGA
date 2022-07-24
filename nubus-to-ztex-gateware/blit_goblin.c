/*
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -Os -S blit_goblin.c -march=rv32ib -mabi=ilp32 -mstrict-align -fno-builtin-memset -nostdlib -ffreestanding -nostartfiles
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -Os -o blit -march=rv32ib -mabi=ilp32 -T blit_goblin.lds  -nostartfiles blit_goblin.s
 ~/LITEX/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-objcopy  -O binary -j .text blit blit_goblin.raw
*/

#ifndef BASE_FB
#define BASE_FB  0x8F800000 // FIXME : should be generated ; 2+ MiB of SDRAM as framebuffer
#warning "Using default BASE_FB"
#endif

#if defined(GOBLIN_NUBUS)
#define BASE_ROM 0xF0910000 // FIXME : should be generated ; 4-64 KiB of Wishbone ROM ? ; also in the LDS file ; also in the Vex config
#define BASE_RAM 0xF0902000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start
#define BASE_RAM_SIZE 0x00001000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start
#define BASE_BT_REGS    0xF0900000
#define BASE_ACCEL_REGS 0xF0901000
#elif defined(GOBLIN_SBUS)
#define BASE_ROM 0x00410000 // FIXME : should be generated ; 4-64 KiB of Wishbone ROM ? ; also in the LDS file ; also in the Vex config
#define BASE_RAM 0x00420000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start
#define BASE_RAM_SIZE 0x00001000 // FIXME : should be generated : 4-64 KiB of Wishbone SRAM ? ; also in _start
#define BASE_BT_REGS    0x00200000
#define BASE_ACCEL_REGS 0x000c0000
#else
#error "Must define GOBLIN_NUBUS or GOBLIN_SBUS"
#endif

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
#define FUN_PATT_BIT            2 // hardwired in goblin_accel.py
#define FUN_TEST_BIT            3 // hardwired in goblin_accel.py
#define FUN_DONE_BIT           31

#define FUN_BLIT           (1<<FUN_BLIT_BIT)
#define FUN_FILL           (1<<FUN_FILL_BIT)
#define FUN_PATT           (1<<FUN_PATT_BIT)
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
	u_int32_t reg_src_stride; // 12
	u_int32_t reg_dst_stride; // 13
	u_int32_t reg_src_ptr; // 14
	u_int32_t reg_dst_ptr; // 15
};

//#include "./rvintrin.h"

#include "ldsdsupport.h"

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
					 unsigned char *dst_ptr,
					 const unsigned_param_type dst_stride
					 );
static void rectfill_pm(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned char pm,
						unsigned char *dst_ptr,
						const unsigned_param_type dst_stride
						);
static void xorrectfill(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						unsigned char *dst_ptr,
						const unsigned_param_type dst_stride
						);
static void xorrectfill_pm(const unsigned_param_type xd,
						   const unsigned_param_type yd,
						   const unsigned_param_type wi,
						   const unsigned_param_type re,
						   const unsigned_param_type color,
						   const unsigned char pm,
						   unsigned char *dst_ptr,
						   const unsigned_param_type dst_stride
						);
static void invert(const unsigned_param_type xd,
				   const unsigned_param_type yd,
				   const unsigned_param_type wi,
				   const unsigned_param_type re,
				   unsigned char *dst_ptr,
				   const unsigned_param_type dst_stride
				   );
static void bitblit(const unsigned_param_type xs,
					const unsigned_param_type ys,
					const unsigned_param_type wi,
					const unsigned_param_type re,
					const unsigned_param_type xd,
					const unsigned_param_type yd,
					const unsigned char pm,
					const unsigned char gxop,
					unsigned char *src_ptr,
					unsigned char *dst_ptr,
					const unsigned_param_type src_stride,
					const unsigned_param_type dst_stride
					);

static void patternrectfill(const unsigned_param_type xd,
							const unsigned_param_type yd,
							const unsigned_param_type wi,
							const unsigned_param_type re,
							unsigned char *pat_ptr,
							const unsigned_param_type pat_xmask,
							const unsigned_param_type pat_ymask,
							const unsigned_param_type pat_stride,
							unsigned char* dst_ptr,
							const unsigned_param_type dst_stride
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
#if defined(GOBLIN_NUBUS)
	"li sp, 0xF0902ffc\n" // SP at the end of the SRAM
#elif defined(GOBLIN_SBUS)
	"li sp, 0x00420ffc\n" // SP at the end of the SRAM
#else
#error "Must define GOBLIN_NUBUS or GOBLIN_SBUS"
#endif
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
	uint32_t srcx, wi, dstx;
	switch ((fbt->mode>>24) & 0xFF) { // mode is 8 bits wrong-endian (all fbt is wrong-endian)
	case mode_32bit:
		srcx = fbc->reg_bitblt_src_x << 2;
		wi   = fbc->reg_width        << 2;
		dstx = fbc->reg_bitblt_dst_x << 2;
		break;
	case mode_16bit:
		srcx = fbc->reg_bitblt_src_x << 1;
		wi   = fbc->reg_width        << 1;
		dstx = fbc->reg_bitblt_dst_x << 1;
		break;
	default:
	case mode_8bit:
		srcx = fbc->reg_bitblt_src_x;
		wi   = fbc->reg_width;
		dstx = fbc->reg_bitblt_dst_x;
		break;
	case mode_4bit:
		srcx = fbc->reg_bitblt_src_x >> 1;
		wi   = fbc->reg_width        >> 1;
		dstx = fbc->reg_bitblt_dst_x >> 1;
		break;
	case mode_2bit:
		srcx = fbc->reg_bitblt_src_x >> 2;
		wi   = fbc->reg_width        >> 2;
		dstx = fbc->reg_bitblt_dst_x >> 2;
		break;
	case mode_1bit:
		srcx = fbc->reg_bitblt_src_x >> 3;
		wi   = fbc->reg_width        >> 3;
		dstx = fbc->reg_bitblt_dst_x >> 3;
		break;
	}

	switch (cmd & 0xF) {
	case FUN_BLIT: {
		bitblit(srcx, fbc->reg_bitblt_src_y,
				wi  , fbc->reg_height,
				dstx, fbc->reg_bitblt_dst_y,
				0xFF, 0x3, // GXcopy
				fbc->reg_src_ptr ? (unsigned char*)fbc->reg_src_ptr : (unsigned char*)BASE_FB,
				fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
				fbc->reg_src_stride,
				fbc->reg_dst_stride); // assumed to be scaled already
	} break;
	case FUN_FILL: {
		rectfill(dstx, fbc->reg_bitblt_dst_y,
				 wi  , fbc->reg_height,
				 fbc->reg_fgcolor,
				 fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
				 fbc->reg_dst_stride); // assumed to be scaled already
	} break;
	case FUN_PATT: {
		patternrectfill(dstx, fbc->reg_bitblt_dst_y,
						wi  , fbc->reg_height,
						(unsigned char*)BASE_FB + (8*1024*1024) - (64*1024), // FIXME
						fbc->reg_bitblt_src_x, // unscaled
						fbc->reg_bitblt_src_y, // unscaled
						fbc->reg_src_stride,
						fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
						fbc->reg_dst_stride); // assumed to be scaled already
	} break;
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
								   unsigned char *src_ptr,				\
								   unsigned char *dst_ptr,				\
								   const unsigned_param_type src_stride	, \
								   const unsigned_param_type dst_stride	\
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
	if (pm == 0xFF) bb(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride); \
	else       bb##_pm(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride)

static void bitblit(const unsigned_param_type xs,
					const unsigned_param_type ys,
					const unsigned_param_type wi,
					const unsigned_param_type re,
					const unsigned_param_type xd,
					const unsigned_param_type yd,
					const unsigned char pm,
					const unsigned char gxop,
					unsigned char *src_ptr,
					unsigned char *dst_ptr,
					const unsigned_param_type src_stride,
					const unsigned_param_type dst_stride
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
				rectfill_pm(xd, yd, wi, re, 0, pm, dst_ptr, dst_stride);
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
					 unsigned char* dst_ptr,
					 const unsigned_param_type dst_stride
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
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
			if ((wi>15) && (((unsigned int)dptr_elt&0x7)==0)) {
				register unsigned int s8 asm("s8");
				register unsigned int s9 asm("s9");
				s8 = u32color;
				s9 = u32color;
				for ( ; i < (wi-15) ; i+=16) {
					sd(dptr_elt, 0, 0, s8, s9);
					sd(dptr_elt, 8, 0, s8, s9);
					dptr_elt += 16;
				}
			}
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = u32color;
				dptr_elt +=4;
			}
		}	
		for ( ; i < wi ; i++) {
			*dptr_elt = u8color;
			dptr_elt ++;
		}
		dptr_line += dst_stride;
	}
}

static void rectfill_pm(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						const unsigned char pm,
						unsigned char* dst_ptr,
						const unsigned_param_type dst_stride
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
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
		dptr_line += dst_stride;
	}
}


static void xorrectfill(const unsigned_param_type xd,
						const unsigned_param_type yd,
						const unsigned_param_type wi,
						const unsigned_param_type re,
						const unsigned_param_type color,
						unsigned char* dst_ptr,
						const unsigned_param_type dst_stride
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
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
		dptr_line += dst_stride;
	}
}
static void xorrectfill_pm(const unsigned_param_type xd,
						   const unsigned_param_type yd,
						   const unsigned_param_type wi,
						   const unsigned_param_type re,
						   const unsigned_param_type color,
						   const unsigned char pm,
						   unsigned char* dst_ptr,
						   const unsigned_param_type dst_stride
			  ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
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
		dptr_line += dst_stride;
	}
}

static void invert(const unsigned_param_type xd,
				   const unsigned_param_type yd,
				   const unsigned_param_type wi,
				   const unsigned_param_type re,
				   unsigned char* dst_ptr,
				   const unsigned_param_type dst_stride
				   ) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
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
		dptr_line += dst_stride;
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
									   unsigned char* src_ptr,			\
									   unsigned char* dst_ptr,			\
									   const unsigned_param_type src_stride, \
									   const unsigned_param_type dst_stride) { \
	unsigned int i, j;													\
	unsigned char *sptr = (src_ptr + (ys * src_stride) + xs);			\
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);			\
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
		sptr_line += src_stride;										\
		dptr_line += dst_stride;										\
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
									   unsigned char* src_ptr,			\
									   unsigned char* dst_ptr,			\
									   const unsigned_param_type src_stride, \
									   const unsigned_param_type dst_stride) { \
		unsigned int i, j;												\
		unsigned char *sptr = (src_ptr + (ys * src_stride) + xs); \
		unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd); \
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
			sptr_line += src_stride;									\
			dptr_line += dst_stride;									\
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
									   unsigned char* src_ptr,			\
									   unsigned char* dst_ptr,			\
									   const unsigned_param_type src_stride, \
									   const unsigned_param_type dst_stride) { \
	unsigned int i, j;													\
	unsigned char *sptr = (src_ptr + (ys * src_stride) + xs);			\
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);			\
	unsigned char *sptr_line = sptr + ((re-1) * src_stride);			\
	unsigned char *dptr_line = dptr + ((re-1) * dst_stride);			\
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
		sptr_line -= src_stride;										\
		dptr_line -= dst_stride;										\
	}																	\
	}


#define BLIT_ALLDIR(NAME, OP)				\
	BLIT_FWD_FWD(NAME, OP)					\
	BLIT_FWD_BWD(NAME, OP)					\
	BLIT_BWD_FWD(NAME, OP)					\
		
#define BLIT_NOTALLDIR(NAME, OP)				\
	BLIT_FWD_BWD(NAME, OP)					\
	BLIT_BWD_FWD(NAME, OP)					\
	
//BLIT_ALLDIR(copy, COPY)
BLIT_NOTALLDIR(copy, COPY)
BLIT_ALLDIR(xor, XOR)
BLIT_ALLDIR(copy_pm, COPY_PM)
BLIT_ALLDIR(xor_pm, XOR_PM)
	
	
static void bitblit_fwd_fwd_copy(const unsigned_param_type xs,
								 const unsigned_param_type ys,
								 const unsigned_param_type wi,
								 const unsigned_param_type re,
								 const unsigned_param_type xd,
								 const unsigned_param_type yd,
								 const unsigned char pm,
								 unsigned char* src_ptr,
								 unsigned char* dst_ptr,
								 const unsigned_param_type src_stride,
								 const unsigned_param_type dst_stride) {
	unsigned int j;
	unsigned char *sptr = (src_ptr + (ys * src_stride) + xs);
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
	unsigned char *sptr_line = sptr;
	unsigned char *dptr_line = dptr;
	/*const unsigned char npm = ~pm;*/
	
	for (j = 0 ; j < re ; j++) {
	    register unsigned char *sptr_elt = sptr_line;
		unsigned char *dptr_elt = dptr_line;
		const unsigned char *dptr_elt_last = dptr_line + wi;
		if (wi>3) {
			if ((xs & 0x3) != (xd & 0x3)) {
				/* align dest, we'll deal with src via shift realignement using fsr */
				for ( ; (dptr_elt < dptr_elt_last) && ((unsigned int)dptr_elt&0x3)!=0; ) {
					dptr_elt[0] = sptr_elt[0];
					dptr_elt ++;
					sptr_elt ++;
				}
				unsigned char *sptr_elt_al = (unsigned char*)((unsigned int)sptr_elt & ~0x3);
				unsigned int fsr_cst = 8*((unsigned int)sptr_elt & 0x3);
				unsigned int src0 = ((unsigned int*)sptr_elt_al)[0];
				unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
				/* handle unaligned src */
				for ( ; (dptr_elt < (dptr_elt_last-3)) ; ) {
					unsigned int src1 = ((unsigned int*)sptr_elt_al)[1];
					unsigned int val;
					asm("fsr %0, %1, %2, %3\n" : "=r"(val) : "r"(src0), "r"(src1), "r"(fsr_cst));
					((unsigned int*)dptr_elt)[0] = val;
					src0 = src1;
					dptr_elt += 4;
					sptr_elt_al += 4;
				}
				sptr_elt = sptr_elt_al + ((unsigned int)sptr_elt & 0x3);
			} else {
				const unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
				const unsigned char* dptr_elt_end = dptr_elt + wi;
				/* align dest & src (they are aligned the same here) */
				for ( ; (dptr_elt < dptr_elt_last) && ((unsigned int)dptr_elt&0x3)!=0; ) {
					dptr_elt[0] = sptr_elt[0];
					dptr_elt ++;
					sptr_elt ++;
				}
				/* align to 8 for ls/sd */
				for ( ; (dptr_elt < (dptr_elt_last-3)) && ((unsigned int)dptr_elt&0x7)!=0;) {
					((unsigned int*)dptr_elt)[0] = ((unsigned int*)sptr_elt)[0];
					dptr_elt += 4;
					sptr_elt += 4;
				}
#if 0
				for ( ; (dptr_elt < (dptr_elt_last-31)) ; ) {
					register unsigned int s4 asm("s4");
					register unsigned int s5 asm("s5");
					register unsigned int s6 asm("s6");
					register unsigned int s7 asm("s7");
					register unsigned int s8 asm("s8");
					register unsigned int s9 asm("s9");
					register unsigned int s10 asm("s10");
					register unsigned int s11 asm("s11");
					ld(sptr_elt, 0, s4, s5);
					ld(sptr_elt, 16, s8, s9);
					
					ld(sptr_elt, 8, s6, s7);
					sd(dptr_elt, 0, 0, s4, s5);
					sd(dptr_elt, 8, 0, s6, s7);
					
					ld(sptr_elt, 24, s10, s11);
					sd(dptr_elt, 16, 0, s8, s9);
					sptr_elt += 32;
					sd(dptr_elt, 24, 0, s10, s11);
					dptr_elt += 32;
					
				}
#endif
				for ( ; (dptr_elt < (dptr_elt_last-15)) ; ) {
					register unsigned int s8 asm("s8");
					register unsigned int s9 asm("s9");
					register unsigned int s10 asm("s10");
					register unsigned int s11 asm("s11");
					ld(sptr_elt, 0, s8, s9);
					ld(sptr_elt, 8, s10, s11);
					sd(dptr_elt, 0, 0, s8, s9);
					sptr_elt += 16;
					sd(dptr_elt, 8, 0, s10, s11);
					dptr_elt += 16;
				}
#if 0
				for ( ; (dptr_elt < (dptr_elt_last-7)) ; ) {
					register unsigned int s8 asm("s8");
					register unsigned int s9 asm("s9");
					ld(sptr_elt, 0, s8, s9);
					sd(dptr_elt, 0, 0, s8, s9);
					sptr_elt += 8;
					dptr_elt += 8;
				}
#endif
				for ( ; (dptr_elt < (dptr_elt_last-3)) ; ) {
					((unsigned int*)dptr_elt)[0] = ((unsigned int*)sptr_elt)[0];
					dptr_elt += 4;
					sptr_elt += 4;
				}
			}
		}
		/* common tail loop */
		for ( ; dptr_elt < dptr_elt_last ; ) {
			dptr_elt[0] = sptr_elt[0];
			dptr_elt ++;
			sptr_elt ++;
		}
		sptr_line += src_stride;
		dptr_line += dst_stride;
	}
}

static void patternrectfill(const unsigned_param_type xd,
							const unsigned_param_type yd,
							const unsigned_param_type wi,
							const unsigned_param_type re,
							unsigned char *pat_ptr,
							const unsigned_param_type pat_xmask,
							const unsigned_param_type pat_ymask,
							const unsigned_param_type pat_stride,
							unsigned char* dst_ptr,
							const unsigned_param_type dst_stride
							) {
	struct goblin_accel_regs* fbc = (struct goblin_accel_regs*)BASE_ACCEL_REGS;
	unsigned int i, j;
	unsigned int io, jo;
	unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);
	unsigned char *dptr_line = dptr;
	unsigned char *pat_ptr_line;

	io = xd & pat_xmask;
	jo = yd & pat_ymask;

	pat_ptr_line = pat_ptr + (jo & pat_ymask) * pat_stride;
	
	for (j = 0 ; j < re ; j++) {
		unsigned char *dptr_elt = dptr_line;
		i = 0;
		for ( ; i < wi && ((unsigned int)dptr_elt&0x3)!=0; i++) {
			dptr_elt[0] = pat_ptr_line[(i+io) & pat_xmask];
			dptr_elt ++;
		}
		if (wi > 3) {
			unsigned int fsr_cst = 8*((i+io) & 0x3);
			unsigned int src0 = ((unsigned int*)pat_ptr_line)[((i+io) & pat_xmask) >> 2];
			for ( ; i < (wi-3) ; i+=4) {
				unsigned int src1 = ((unsigned int*)pat_ptr_line)[((i+io+4) & pat_xmask) >> 2];
				unsigned int val;
				asm("fsr %0, %1, %2, %3\n" : "=r"(val) : "r"(src0), "r"(src1), "r"(fsr_cst));
				((unsigned int*)dptr_elt)[0] = val;
				src0 = src1;
				dptr_elt += 4;
			}
		}
		for ( ; i < wi ; i++) {
			dptr_elt[0] = pat_ptr_line[(i+io) & pat_xmask];
			dptr_elt ++;
		}
		dptr_line += dst_stride;
		pat_ptr_line = pat_ptr + ((j+jo) & pat_ymask) * pat_stride;
	}
}
