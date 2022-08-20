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

// X11 graphics functions
#define	GXclear			0x0		/* 0 */
#define GXand			0x1		/* src AND dst */
#define GXandReverse	0x2		/* src AND NOT dst */
#define GXcopy			0x3		/* src */
#define GXandInverted	0x4		/* NOT src AND dst */
#define	GXnoop			0x5		/* dst */
#define GXxor			0x6		/* src XOR dst */
#define GXor			0x7		/* src OR dst */
#define GXnor			0x8		/* NOT src AND NOT dst */
#define GXequiv			0x9		/* NOT src XOR dst */
#define GXinvert		0xa		/* NOT dst */
#define GXorReverse		0xb		/* src OR NOT dst */
#define GXcopyInverted	0xc		/* NOT src */
#define GXorInverted	0xd		/* NOT src OR dst */
#define GXnand			0xe		/* NOT src OR NOT dst */
#define GXset			0xf		/* 1 */

// Xrender op
#define PictOpClear           (0x80 | 0x0)
#define PictOpSrc             (0x80 | 0x1)
#define PictOpDst             (0x80 | 0x2)
#define PictOpOver            (0x80 | 0x3)
#define PictOpOverReverse     (0x80 | 0x4)
#define PictOpIn              (0x80 | 0x5)
#define PictOpInReverse       (0x80 | 0x6)
#define PictOpOut             (0x80 | 0x7)
#define PictOpOutReverse      (0x80 | 0x8)
#define PictOpAtop            (0x80 | 0x9)
#define PictOpAtopReverse     (0x80 | 0xa)
#define PictOpXor             (0x80 | 0xb)
#define PictOpAdd             (0x80 | 0xc)
#define PictOpSaturate        (0x80 | 0xd)
// custom, with 0x40 for 'flip src'
#define PictOpFlipClear           (0x80 | 0x40 | 0x0)
#define PictOpFlipSrc             (0x80 | 0x40 | 0x1)
#define PictOpFlipDst             (0x80 | 0x40 | 0x2)
#define PictOpFlipOver            (0x80 | 0x40 | 0x3)
#define PictOpFlipOverReverse     (0x80 | 0x40 | 0x4)
#define PictOpFlipIn              (0x80 | 0x40 | 0x5)
#define PictOpFlipInReverse       (0x80 | 0x40 | 0x6)
#define PictOpFlipOut             (0x80 | 0x40 | 0x7)
#define PictOpFlipOutReverse      (0x80 | 0x40 | 0x8)
#define PictOpFlipAtop            (0x80 | 0x40 | 0x9)
#define PictOpFlipAtopReverse     (0x80 | 0x40 | 0xa)
#define PictOpFlipXor             (0x80 | 0x40 | 0xb)
#define PictOpFlipAdd             (0x80 | 0x40 | 0xc)
#define PictOpFlipSaturate        (0x80 | 0x40 | 0xd)

#define FUN_BLIT_BIT             0 // hardwired in goblin_accel.py
#define FUN_FILL_BIT             1 // hardwired in goblin_accel.py
#define FUN_PATT_BIT             2 // hardwired in goblin_accel.py
#define FUN_RSMSK8DST32_BIT      3 // hardwired in goblin_accel.py
#define FUN_RSRC32MSK32DST32_BIT 4 // hardwired in goblin_accel.py
#define FUN_RSRC32DST32_BIT      5 // hardwired in goblin_accel.py
#define FUN_DONE_BIT             31

#define FUN_BLIT             (1<<FUN_BLIT_BIT)
#define FUN_FILL             (1<<FUN_FILL_BIT)
#define FUN_PATT             (1<<FUN_PATT_BIT)
#define FUN_RSMSK8DST32      (1<<FUN_RSMSK8DST32_BIT)
#define FUN_RSRC32MSK32DST32 (1<<FUN_RSRC32MSK32DST32_BIT)
#define FUN_RSRC32DST32      (1<<FUN_RSRC32DST32_BIT)
#define FUN_DONE             (1<<FUN_DONE_BIT)

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
	u_int32_t reg_op; // 3; X11 op or (0x80 | Render op)
	u_int32_t reg_width; // 4
	u_int32_t reg_height;
	u_int32_t reg_fgcolor;
	u_int32_t reg_depth; // 7; 0 is native
	u_int32_t reg_bitblt_src_x; // 8
	u_int32_t reg_bitblt_src_y;
	u_int32_t reg_bitblt_dst_x;
	u_int32_t reg_bitblt_dst_y;
	u_int32_t reg_src_stride; // 12
	u_int32_t reg_dst_stride; // 13
	u_int32_t reg_src_ptr; // 14
	u_int32_t reg_dst_ptr; // 15
	
	u_int32_t reg_bitblt_msk_x; // 16
	u_int32_t reg_bitblt_msk_y;
	u_int32_t reg_msk_stride; // 18
	u_int32_t reg_msk_ptr; // 19
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

static void bitblit_solid_msk8_dst32_fwd_fwd(const unsigned char op,
											  const unsigned_param_type xm,
											  const unsigned_param_type ym,
											  const unsigned_param_type wi,
											  const unsigned_param_type re,
											  const unsigned_param_type xd,
											  const unsigned_param_type yd,
											  const unsigned int fgcolor,
											  unsigned char* msk_ptr,
											  unsigned char* dst_ptr,
											  const unsigned_param_type msk_stride,
											  const unsigned_param_type dst_stride);

static void bitblit_src32_msk32_dst32_fwd_fwd(const unsigned char op,
											   const unsigned_param_type xs,
											   const unsigned_param_type ys,
											   const unsigned_param_type xm,
											   const unsigned_param_type ym,
											   const unsigned_param_type wi,
											   const unsigned_param_type re,
											   const unsigned_param_type xd,
											   const unsigned_param_type yd,
											   unsigned char* src_ptr,
											   unsigned char* msk_ptr,
											   unsigned char* dst_ptr,
											   const unsigned_param_type src_stride,
											   const unsigned_param_type msk_stride,
											   const unsigned_param_type dst_stride);

static void bitblit_src32_dst32_fwd_fwd(const unsigned char op,
										const unsigned_param_type xs,
										const unsigned_param_type ys,
										const unsigned_param_type wi,
										const unsigned_param_type re,
										const unsigned_param_type xd,
										const unsigned_param_type yd,
										unsigned char* src_ptr,
										unsigned char* dst_ptr,
										const unsigned_param_type src_stride,
										const unsigned_param_type dst_stride);

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
	unsigned char depth = fbc->reg_depth;
	unsigned char op = fbc->reg_op;
	uint32_t srcx, wi, dstx;
	if (depth == 0) {
#if defined(GOBLIN_NUBUS)
		switch ((fbt->mode>>24) & 0xFF)  // mode is 8 bits wrong-endian (all fbt is wrong-endian in NuBus version)
#elif defined(GOBLIN_SBUS)
		switch (fbt->mode & 0xFF)
#else
#error "Must define GOBLIN_NUBUS or GOBLIN_SBUS"
#endif
	{
	case mode_32bit:
		depth = 32;
		break;
	case mode_16bit:
		depth = 16;
		break;
	default:
	case mode_8bit:
		depth = 8;
		break;
	case mode_4bit:
		depth = 4;
		break;
	case mode_2bit:
		depth = 2;
		break;
	case mode_1bit:
		depth = 1;
		break;
	}
	}
	switch (depth)
		{
	case 32:
		srcx = fbc->reg_bitblt_src_x << 2;
		wi   = fbc->reg_width        << 2;
		dstx = fbc->reg_bitblt_dst_x << 2;
		break;
	case 16:
		srcx = fbc->reg_bitblt_src_x << 1;
		wi   = fbc->reg_width        << 1;
		dstx = fbc->reg_bitblt_dst_x << 1;
		break;
	default:
	case 8:
		srcx = fbc->reg_bitblt_src_x;
		wi   = fbc->reg_width;
		dstx = fbc->reg_bitblt_dst_x;
		break;
	case 4:
		srcx = fbc->reg_bitblt_src_x >> 1;
		wi   = fbc->reg_width        >> 1;
		dstx = fbc->reg_bitblt_dst_x >> 1;
		break;
	case 2:
		srcx = fbc->reg_bitblt_src_x >> 2;
		wi   = fbc->reg_width        >> 2;
		dstx = fbc->reg_bitblt_dst_x >> 2;
		break;
	case 1:
		srcx = fbc->reg_bitblt_src_x >> 3;
		wi   = fbc->reg_width        >> 3;
		dstx = fbc->reg_bitblt_dst_x >> 3;
		break;
	}

	switch (cmd & 0xFF) {
	case FUN_BLIT: {
		bitblit(srcx, fbc->reg_bitblt_src_y,
				wi  , fbc->reg_height,
				dstx, fbc->reg_bitblt_dst_y,
				0xFF, op, // FIXME: re-add planemask support for X11 ops
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
	case FUN_RSMSK8DST32: {
		bitblit_solid_msk8_dst32_fwd_fwd(op,
										  fbc->reg_bitblt_msk_x, // unscaled
										  fbc->reg_bitblt_msk_y,
										  fbc->reg_width, // NOT scaled here, we assume depth == 32 here
										  fbc->reg_height,
										  dstx, // still scaled for the PTR calculation ...
										  fbc->reg_bitblt_dst_y,
										  fbc->reg_fgcolor,
										  fbc->reg_msk_ptr ? (unsigned char*)fbc->reg_msk_ptr : (unsigned char*)BASE_FB,
										  fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
										  fbc->reg_msk_stride, // assumed to be scaled already
										  fbc->reg_dst_stride); // assumed to be scaled already
	} break;
	case FUN_RSRC32MSK32DST32: {
		bitblit_src32_msk32_dst32_fwd_fwd(op,
										   fbc->reg_bitblt_src_x, // unscaled
										   fbc->reg_bitblt_src_y,
										   fbc->reg_bitblt_msk_x, // unscaled
										   fbc->reg_bitblt_msk_y,
										   fbc->reg_width, // NOT scaled here, we assume depth == 32 here
										   fbc->reg_height,
										   dstx, // still scaled for the PTR calculation ...
										   fbc->reg_bitblt_dst_y,
										   fbc->reg_src_ptr ? (unsigned char*)fbc->reg_src_ptr : (unsigned char*)BASE_FB,
										   fbc->reg_msk_ptr ? (unsigned char*)fbc->reg_msk_ptr : (unsigned char*)BASE_FB,
										   fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
										   fbc->reg_src_stride, // assumed to be scaled already
										   fbc->reg_msk_stride, // assumed to be scaled already
										   fbc->reg_dst_stride); // assumed to be scaled already
	} break;
	case FUN_RSRC32DST32: {
		bitblit_src32_dst32_fwd_fwd(op,
									fbc->reg_bitblt_src_x, // unscaled
									fbc->reg_bitblt_src_y,
									fbc->reg_width, // NOT scaled here, we assume depth == 32 here
									fbc->reg_height,
									dstx, // still scaled for the PTR calculation ...
									fbc->reg_bitblt_dst_y,
									fbc->reg_src_ptr ? (unsigned char*)fbc->reg_src_ptr : (unsigned char*)BASE_FB,
									fbc->reg_dst_ptr ? (unsigned char*)fbc->reg_dst_ptr : (unsigned char*)BASE_FB,
									fbc->reg_src_stride, // assumed to be scaled already
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

bitblit_proto(_radd);


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
		case GXcopy:
			ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_copy);
			break;
		case GXxor:
			ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_xor);
			break;
		case PictOpAdd:
			bitblit_fwd_fwd_radd(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride);
			break;
		}
	} else if (ys < yd) {
		switch(gxop) {
		case GXcopy:
			ROUTE_BITBLIT_PM(pm, bitblit_bwd_fwd_copy);
			break;
		case GXxor:
			ROUTE_BITBLIT_PM(pm, bitblit_bwd_fwd_xor);
			break;
		case PictOpAdd:
			bitblit_bwd_fwd_radd(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride);
			break;
		}
	} else { // ys == yd
		if (xs > xd) {
			switch(gxop) {
			case GXcopy:
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_copy);
				break;
			case GXxor:
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_fwd_xor);
				break;
			case PictOpAdd:
				bitblit_fwd_fwd_radd(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride);
				break;
			}
		} else if (xs < xd) {
			switch(gxop) {
			case GXcopy:
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_bwd_copy);
				break;
			case GXxor:
				ROUTE_BITBLIT_PM(pm, bitblit_fwd_bwd_xor);
				break;
			case PictOpAdd:
				bitblit_fwd_bwd_radd(xs, ys, wi, re, xd, yd, pm, src_ptr, dst_ptr, src_stride, dst_stride);
				break;
			}
		} else { // xs == xd
			switch(gxop) {
			case GXcopy:
				/* don't bother */
				break;
			case GXxor:
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
			if ((wi>15) && (((unsigned int)dptr_elt&0x7)==0)) {
				register unsigned int s8 asm("s8");
				register unsigned int s9 asm("s9");
				s8 = color;
				s9 = color;
				for ( ; i < (wi-15) ; i+=16) {
					_custom_sd(dptr_elt, 0, 0, s8, s9);
					_custom_sd(dptr_elt, 8, 0, s8, s9);
					dptr_elt += 16;
				}
			}
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = color;
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
			unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt = (color & u32pm) | (*(unsigned int*)dptr_elt & ~u32pm);
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
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt ^= color;
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
			unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
			for ( ; i < (wi-3) ; i+=4) {
				*(unsigned int*)dptr_elt ^= (color & u32pm);
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

// X11
// NOT using npm enables the use of 'cmix' in more cases
#define COPY(d,s,pm,npm) (d) = (s)
//#define COPY_PM(d,s,pm,npm) (d) = (((s) & (pm)) | ((d) & (npm)))
#define COPY_PM(d,s,pm,npm) (d) = (((s) & (pm)) | ((d) & (~pm)))
#define XOR(d,s,pm,npm) (d) = ((s) ^ (d))
//#define XOR_PM(d,s,pm,npm) (d) = ((((s) ^ (d)) & (pm)) | ((d) & (npm)))
#define XOR_PM(d,s,pm,npm) (d) = ((((s) ^ (d)) & (pm)) | ((d) & (~pm)))
// Xrender
#define RADD(d,s,pm,npm) (d) = ukadd8((d), (s))

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
		
#define BLIT_NOTALLDIR(NAME, OP)			\
	BLIT_FWD_BWD(NAME, OP)					\
	BLIT_BWD_FWD(NAME, OP)					\
	
//BLIT_ALLDIR(copy, COPY)
BLIT_NOTALLDIR(copy, COPY)
BLIT_ALLDIR(xor, XOR)
BLIT_ALLDIR(copy_pm, COPY_PM)
BLIT_ALLDIR(xor_pm, XOR_PM)
	
BLIT_ALLDIR(radd, RADD)
	
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
			} else if ((xs & 0x7) != (xd & 0x7)) {
				/* off-hy-4, can't use 64 ld/sd directly (could pipeline the 32-bits data) but still can use 32-bits */
				const unsigned int u32pm = (unsigned int)pm | ((unsigned int)pm)<<8 | ((unsigned int)pm)<<16 | ((unsigned int)pm)<<24;
				const unsigned char* dptr_elt_end = dptr_elt + wi;
				/* align dest & src (they are aligned the same here up to 0x3) */
				for ( ; (dptr_elt < dptr_elt_last) && ((unsigned int)dptr_elt&0x3)!=0; ) {
					dptr_elt[0] = sptr_elt[0];
					dptr_elt ++;
					sptr_elt ++;
				}
				for ( ; (dptr_elt < (dptr_elt_last-3)) ; ) {
					((unsigned int*)dptr_elt)[0] = ((unsigned int*)sptr_elt)[0];
					dptr_elt += 4;
					sptr_elt += 4;
				}
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
					_custom_ld(sptr_elt, 0, s4, s5);
					_custom_ld(sptr_elt, 16, s8, s9);
					
					_custom_ld(sptr_elt, 8, s6, s7);
					_custom_sd(dptr_elt, 0, 0, s4, s5);
					_custom_sd(dptr_elt, 8, 0, s6, s7);
					
					_custom_ld(sptr_elt, 24, s10, s11);
					_custom_sd(dptr_elt, 16, 0, s8, s9);
					sptr_elt += 32;
					_custom_sd(dptr_elt, 24, 0, s10, s11);
					dptr_elt += 32;
					
				}
#endif
				for ( ; (dptr_elt < (dptr_elt_last-15)) ; ) {
					register unsigned int s8 asm("s8");
					register unsigned int s9 asm("s9");
					register unsigned int s10 asm("s10");
					register unsigned int s11 asm("s11");
					_custom_ld(sptr_elt, 0, s8, s9);
					_custom_ld(sptr_elt, 8, s10, s11);
					_custom_sd(dptr_elt, 0, 0, s8, s9);
					sptr_elt += 16;
					_custom_sd(dptr_elt, 8, 0, s10, s11);
					dptr_elt += 16;
				}
#if 0
				for ( ; (dptr_elt < (dptr_elt_last-7)) ; ) {
					register unsigned int s8 asm("s8");
					register unsigned int s9 asm("s9");
					_custom_ld(sptr_elt, 0, s8, s9);
					_custom_sd(dptr_elt, 0, 0, s8, s9);
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

#define bitblit_render_proto(a, b, suf) \
	static void bitblit_solid_msk8_dst32##a##b##suf(const unsigned_param_type xm, \
													const unsigned_param_type ym, \
													const unsigned_param_type wi, \
													const unsigned_param_type re, \
													const unsigned_param_type xd, \
													const unsigned_param_type yd, \
													const unsigned int fgcolor, \
													unsigned char* msk_ptr, \
													unsigned char* dst_ptr, \
													const unsigned_param_type msk_stride, \
													const unsigned_param_type dst_stride); \
	static void bitblit_src32_msk32_dst32##a##b##suf(const unsigned_param_type xs, \
													 const unsigned_param_type ys, \
													 const unsigned_param_type xm, \
													 const unsigned_param_type ym, \
													 const unsigned_param_type wi, \
													 const unsigned_param_type re, \
													 const unsigned_param_type xd, \
													 const unsigned_param_type yd, \
													 unsigned char* src_ptr, \
													 unsigned char* msk_ptr, \
													 unsigned char* dst_ptr, \
													 const unsigned_param_type src_stride, \
													 const unsigned_param_type msk_stride, \
													 const unsigned_param_type dst_stride);	\
	static void bitblit_src32_dst32##a##b##suf(const unsigned_param_type xs, \
											   const unsigned_param_type ys, \
											   const unsigned_param_type wi, \
											   const unsigned_param_type re, \
											   const unsigned_param_type xd, \
											   const unsigned_param_type yd, \
											   unsigned char* src_ptr,	\
											   unsigned char* dst_ptr,	\
											   const unsigned_param_type src_stride, \
											   const unsigned_param_type dst_stride);

bitblit_render_proto(_fwd, _fwd, _over)
bitblit_render_proto(_fwd, _fwd, _fover)
bitblit_render_proto(_fwd, _fwd, _outreverse)


static void bitblit_solid_msk8_dst32_fwd_fwd(const unsigned char op,
											  const unsigned_param_type xm,
											  const unsigned_param_type ym,
											  const unsigned_param_type wi,
											  const unsigned_param_type re,
											  const unsigned_param_type xd,
											  const unsigned_param_type yd,
											  const unsigned int fgcolor,
											  unsigned char* msk_ptr,
											  unsigned char* dst_ptr,
											  const unsigned_param_type msk_stride,
											  const unsigned_param_type dst_stride) {
	switch (op) {
	case PictOpOver:
		bitblit_solid_msk8_dst32_fwd_fwd_over(xm, ym, wi, re, xd, yd, fgcolor, msk_ptr, dst_ptr, msk_stride, dst_stride);
		break;
	/* case PictOpOutReverse: */
	/* 	bitblit_solid_msk8_dst32_fwd_fwd_outreverse(xm, ym, wi, re, xd, yd, fgcolor, msk_ptr, dst_ptr, msk_stride, dst_stride); */
	/* 	break; */
	default:
		break;
	}
}
static void bitblit_src32_msk32_dst32_fwd_fwd(const unsigned char op,
											  const unsigned_param_type xs,
											  const unsigned_param_type ys,
											  const unsigned_param_type xm,
											  const unsigned_param_type ym,
											  const unsigned_param_type wi,
											  const unsigned_param_type re,
											  const unsigned_param_type xd,
											  const unsigned_param_type yd,
											  unsigned char* src_ptr,
											  unsigned char* msk_ptr,
											  unsigned char* dst_ptr,
											  const unsigned_param_type src_stride,
											  const unsigned_param_type msk_stride,
											  const unsigned_param_type dst_stride)
{
	switch (op) {
	case PictOpOver:
		bitblit_src32_msk32_dst32_fwd_fwd_over(xs, ys, xm, ym, wi, re, xd, yd, src_ptr, msk_ptr, dst_ptr, src_stride, msk_stride, dst_stride);
		break;
	default:
		break;
	}
}
static void bitblit_src32_dst32_fwd_fwd(const unsigned char op,
										const unsigned_param_type xs,
										const unsigned_param_type ys,
										const unsigned_param_type wi,
										const unsigned_param_type re,
										const unsigned_param_type xd,
										const unsigned_param_type yd,
										unsigned char* src_ptr,
										unsigned char* dst_ptr,
										const unsigned_param_type src_stride,
										const unsigned_param_type dst_stride)
{
	switch (op) {
	case PictOpOver:
		bitblit_src32_dst32_fwd_fwd_over(xs, ys, wi, re, xd, yd, src_ptr, dst_ptr, src_stride, dst_stride);
		break;
	case PictOpFlipOver:
		bitblit_src32_dst32_fwd_fwd_fover(xs, ys, wi, re, xd, yd, src_ptr, dst_ptr, src_stride, dst_stride);
		break;
	default:
		break;
	}
}

// Xrender
//#define TROVER(d,m,s) (d) = (m)*(s) + (d)*(0xff ^ (m)))
#define TROVERl(d,m,s) (d) = ufma8vlv((s), (m), ufma8vlv((d), (0xffffffff^(m)), 0))
#define TROVERl4(d0,d1,d2,d3,m0,m1,m2,m3,s0,s1,s2,s3)	\
	(d0) = ufma8vlv((d0), (0xffffffff^(m0)), 0);		\
	(d1) = ufma8vlv((d1), (0xffffffff^(m1)), 0);		\
	(d2) = ufma8vlv((d2), (0xffffffff^(m2)), 0);		\
	(d3) = ufma8vlv((d3), (0xffffffff^(m3)), 0);		\
	(d0) = ufma8vlv((s0), (m0), (d0));					\
	(d1) = ufma8vlv((s1), (m1), (d1));					\
	(d2) = ufma8vlv((s2), (m2), (d2));					\
	(d3) = ufma8vlv((s3), (m3), (d3))

#define TROVERh(d,m,s) (d) = ufma8vhv((s), (m), ufma8vhv((d), (0xffffffff^(m)), 0))
#define TROVERh4(d0,d1,d2,d3,m0,m1,m2,m3,s0,s1,s2,s3)	\
	(d0) = ufma8vhv((d0), (0xffffffff^(m0)), 0);		\
	(d1) = ufma8vhv((d1), (0xffffffff^(m1)), 0);		\
	(d2) = ufma8vhv((d2), (0xffffffff^(m2)), 0);		\
	(d3) = ufma8vhv((d3), (0xffffffff^(m3)), 0);		\
	(d0) = ufma8vhv((s0), (m0), (d0));					\
	(d1) = ufma8vhv((s1), (m1), (d1));					\
	(d2) = ufma8vhv((s2), (m2), (d2));					\
	(d3) = ufma8vhv((s3), (m3), (d3))

/* 
   3210
   0321 // fsr by 8 ; could be rot
   1230 // rev8
*/

static inline uint32_t pixelswap(const uint32_t p) {
	/* uint32_t r = __builtin_bswap32(p); */
	/* asm("fsr %0, %1, %2, %3\n" : "=r"(r) : "r"(r), "r"(r), "r"(8)); */
	uint32_t r;
	asm("fsr %0, %1, %2, %3\n" : "=r"(r) : "r"(p), "r"(p), "r"(8));
	return __builtin_bswap32(r);
}

#define TRFOVERh(d,m,s) (d) = (ufma8vlv(pixelswap(s), (m), ufma8vlv((d), (0xffffffff^(m)), 0)))
#define TRFOVERh4(d0,d1,d2,d3,m0,m1,m2,m3,s0,s1,s2,s3)	\
	(d0) = ufma8vlv((d0), (0xffffffff^(m0)), 0);		\
	(d1) = ufma8vlv((d1), (0xffffffff^(m1)), 0);		\
	(d2) = ufma8vlv((d2), (0xffffffff^(m2)), 0);		\
	(d3) = ufma8vlv((d3), (0xffffffff^(m3)), 0);		\
	(d0) = (ufma8vlv(pixelswap(s0), (m0), (d0)));	\
	(d1) = (ufma8vlv(pixelswap(s1), (m1), (d1)));	\
	(d2) = (ufma8vlv(pixelswap(s2), (m2), (d2)));	\
	(d3) = (ufma8vlv(pixelswap(s3), (m3), (d3)))

#define TROUTREVl(d,m,s) (d) = ufma8vlv((d), (0xffffffff^(m)), 0)
#define TROUTREVl4(d0,d1,d2,d3,m0,m1,m2,m3,s0,s1,s2,s3)	\
	(d0) = ufma8vlv((d0), (0xffffffff^(m0)), 0);		\
	(d1) = ufma8vlv((d1), (0xffffffff^(m1)), 0);		\
	(d2) = ufma8vlv((d2), (0xffffffff^(m2)), 0);		\
	(d3) = ufma8vlv((d3), (0xffffffff^(m3)), 0)

#define BLITSM8D32_FWD_FWD(NAME, TOP, TOP4)								\
	static void bitblit_solid_msk8_dst32_fwd_fwd_##NAME(const unsigned_param_type xm, \
														 const unsigned_param_type ym, \
														 const unsigned_param_type wi, \
														 const unsigned_param_type re, \
														 const unsigned_param_type xd, \
														 const unsigned_param_type yd, \
														 const unsigned int fgcolor, \
														 unsigned char* msk_ptr, \
														 unsigned char* dst_ptr, \
														 const unsigned_param_type msk_stride, \
														 const unsigned_param_type dst_stride) { \
		unsigned int i, j;												\
		unsigned char *mptr = (msk_ptr + (ym * msk_stride) + xm);		\
		unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);		\
		unsigned char *mptr_line = mptr;								\
		unsigned char *dptr_line = dptr;								\
		for (j = 0 ; j < re ; j++) {									\
			unsigned char *mptr_elt = mptr_line;						\
			unsigned int *dptr_elt = (unsigned int*)dptr_line;			\
			i = 0;														\
			if (wi > 3) for ( ; i < (wi-3) ; i+= 4) {					\
				unsigned char m0 = *(mptr_elt+0);						\
				unsigned char m1 = *(mptr_elt+1);						\
				unsigned char m2 = *(mptr_elt+2);						\
				unsigned char m3 = *(mptr_elt+3);						\
				unsigned int d0 = *(dptr_elt+0);						\
				unsigned int d1 = *(dptr_elt+1);						\
				unsigned int d2 = *(dptr_elt+2);						\
				unsigned int d3 = *(dptr_elt+3);						\
				TOP4(d0,d1,d2,d3,m0,m1,m2,m3,fgcolor,fgcolor,fgcolor,fgcolor); \
				*(dptr_elt+0) = d0;										\
				*(dptr_elt+1) = d1;										\
				*(dptr_elt+2) = d2;										\
				*(dptr_elt+3) = d3;										\
				dptr_elt += 4;											\
				mptr_elt += 4;											\
			}															\
			for ( ; i < wi ; i++) {										\
				TOP(*dptr_elt, *mptr_elt, fgcolor);						\
				dptr_elt ++;											\
				mptr_elt ++;											\
			}															\
			mptr_line += msk_stride;									\
			dptr_line += dst_stride;									\
		}																\
	}
	
BLITSM8D32_FWD_FWD(over, TROVERl, TROVERl4)
//BLITSM8D32_FWD_FWD(outreverse, TROUTREVl, TROUTREVl4)

	
#define BLITS32M32D32_FWD_FWD(NAME, TOP, TOP4)								\
	static void bitblit_src32_msk32_dst32_fwd_fwd_##NAME(const unsigned_param_type xs, \
														  const unsigned_param_type ys, \
														  const unsigned_param_type xm, \
														  const unsigned_param_type ym, \
														  const unsigned_param_type wi, \
														  const unsigned_param_type re, \
														  const unsigned_param_type xd, \
														  const unsigned_param_type yd, \
														  unsigned char* src_ptr, \
														  unsigned char* msk_ptr, \
														  unsigned char* dst_ptr, \
														  const unsigned_param_type src_stride, \
														  const unsigned_param_type msk_stride, \
														  const unsigned_param_type dst_stride) { \
		unsigned int i, j;												\
		unsigned char *sptr = (src_ptr + (ys * src_stride) + xs);		\
		unsigned char *mptr = (msk_ptr + (ym * msk_stride) + xm);		\
		unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);		\
		unsigned char *sptr_line = sptr;								\
		unsigned char *mptr_line = mptr;								\
		unsigned char *dptr_line = dptr;								\
		for (j = 0 ; j < re ; j++) {									\
			unsigned int *sptr_elt = (unsigned int*)sptr_line;			\
			unsigned int *mptr_elt = (unsigned int*)mptr_line;			\
			unsigned int *dptr_elt = (unsigned int*)dptr_line;			\
			i = 0;														\
			if (wi > 3) for ( ; i < (wi-3) ; i+= 4) {					\
				unsigned int s0 = *(sptr_elt+0);						\
				unsigned int s1 = *(sptr_elt+1);						\
				unsigned int s2 = *(sptr_elt+2);						\
				unsigned int s3 = *(sptr_elt+3);						\
				unsigned int m0 = *(mptr_elt+0);						\
				unsigned int m1 = *(mptr_elt+1);						\
				unsigned int m2 = *(mptr_elt+2);						\
				unsigned int m3 = *(mptr_elt+3);						\
				unsigned int d0 = *(dptr_elt+0);						\
				unsigned int d1 = *(dptr_elt+1);						\
				unsigned int d2 = *(dptr_elt+2);						\
				unsigned int d3 = *(dptr_elt+3);						\
				TOP4(d0,d1,d2,d3,m0,m1,m2,m3,s0,s1,s2,s3);				\
				*(dptr_elt+0) = d0;										\
				*(dptr_elt+1) = d1;										\
				*(dptr_elt+2) = d2;										\
				*(dptr_elt+3) = d3;										\
				sptr_elt += 4;											\
				dptr_elt += 4;											\
				mptr_elt += 4;											\
			}															\
			for ( ; i < wi ; i++) {										\
				TOP(*dptr_elt, *mptr_elt, *sptr_elt);					\
				sptr_elt ++;											\
				dptr_elt ++;											\
				mptr_elt ++;											\
			}															\
			sptr_line += dst_stride;									\
			mptr_line += msk_stride;									\
			dptr_line += dst_stride;									\
		}																\
	}
	

BLITS32M32D32_FWD_FWD(over, TROVERh, TROVERh4)
	

	
#define BLITS32D32_FWD_FWD(NAME, TOP, TOP4)								\
	static void bitblit_src32_dst32_fwd_fwd_##NAME(const unsigned_param_type xs, \
												   const unsigned_param_type ys, \
												   const unsigned_param_type wi, \
												   const unsigned_param_type re, \
												   const unsigned_param_type xd, \
												   const unsigned_param_type yd, \
												   unsigned char* src_ptr, \
												   unsigned char* dst_ptr, \
												   const unsigned_param_type src_stride, \
												   const unsigned_param_type dst_stride) { \
		unsigned int i, j;												\
		unsigned char *sptr = (src_ptr + (ys * src_stride) + xs);		\
		unsigned char *dptr = (dst_ptr + (yd * dst_stride) + xd);		\
		unsigned char *sptr_line = sptr;								\
		unsigned char *dptr_line = dptr;								\
		for (j = 0 ; j < re ; j++) {									\
			unsigned int *sptr_elt = (unsigned int*)sptr_line;			\
			unsigned int *dptr_elt = (unsigned int*)dptr_line;			\
			i = 0;														\
			if (wi > 3) for ( ; i < (wi-3) ; i+= 4) {					\
				unsigned int s0 = *(sptr_elt+0);						\
				unsigned int s1 = *(sptr_elt+1);						\
				unsigned int s2 = *(sptr_elt+2);						\
				unsigned int s3 = *(sptr_elt+3);						\
				unsigned int d0 = *(dptr_elt+0);						\
				unsigned int d1 = *(dptr_elt+1);						\
				unsigned int d2 = *(dptr_elt+2);						\
				unsigned int d3 = *(dptr_elt+3);						\
				TOP4(d0,d1,d2,d3,s0,s1,s2,s3,s0,s1,s2,s3);				\
				*(dptr_elt+0) = d0;										\
				*(dptr_elt+1) = d1;										\
				*(dptr_elt+2) = d2;										\
				*(dptr_elt+3) = d3;										\
				sptr_elt += 4;											\
				dptr_elt += 4;											\
			}															\
			for ( ; i < wi ; i++) {										\
				TOP(*dptr_elt, *sptr_elt, *sptr_elt);					\
				sptr_elt ++;											\
				dptr_elt ++;											\
			}															\
			sptr_line += dst_stride;									\
			dptr_line += dst_stride;									\
		}																\
	}
	
BLITS32D32_FWD_FWD(over, TROVERh, TROVERh4)
BLITS32D32_FWD_FWD(fover, TRFOVERh, TRFOVERh4)

