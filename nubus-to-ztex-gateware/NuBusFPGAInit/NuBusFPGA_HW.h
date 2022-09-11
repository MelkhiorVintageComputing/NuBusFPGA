#ifndef __NUBUSFPGA_HW_H__
#define __NUBUSFPGA_HW_H__

//#define GOBLIN_FB_BASE 0xFC000000 // FIXME !!!!

#define GOBLIN_BT_OFFSET       0x00900000
#define GOBLIN_ACCEL_OFFSET    0x00901000
#define GOBLIN_ACCEL_OFFSET_LE 0x00901800


#define GOBLIN_FB_OFFSET       0x00000000
#define GOBLIN_PATTERN_OFFSET  0x007F0000 // 8 MiB - 64 KiB

#define u_int32_t volatile unsigned long 

// status
#define WORK_IN_PROGRESS_BIT 0

// cmd
#define DO_BLIT_BIT             0 // all hardwired in goblin_accel.py
#define DO_FILL_BIT             1
#define DO_PATT_BIT             2
#define DO_RSMSK8DST32_BIT      3
#define DO_RSRC32MSK32DST32_BIT 4
#define DO_RSRC32DST32_BIT      5

#define FUN_DONE_BIT           31

struct goblin_bt_regs {
	u_int32_t mode;
	u_int32_t vblmask;
	u_int32_t videoctrl;
	u_int32_t intrclear;
	u_int32_t reset;
	u_int32_t lutaddr;
	u_int32_t lut;
	u_int32_t debug;
};

struct goblin_accel_regs {
	u_int32_t reg_status; // 0
	u_int32_t reg_cmd;
	u_int32_t reg_r5_cmd;
	u_int32_t reg_op;
	u_int32_t reg_width; // 4
	u_int32_t reg_height;
	u_int32_t reg_fgcolor;
	u_int32_t reg_depth;
	u_int32_t reg_bitblt_src_x; // 8
	u_int32_t reg_bitblt_src_y;
	u_int32_t reg_bitblt_dst_x;
	u_int32_t reg_bitblt_dst_y;
	u_int32_t reg_src_stride; // 12
	u_int32_t reg_dst_stride;
	u_int32_t reg_src_ptr; // 14
	u_int32_t reg_dst_ptr;
	u_int32_t reg_msk_x; // 16
	u_int32_t reg_msk_y;
	u_int32_t reg_msk_stride; // 18
	u_int32_t reg_msk_ptr;
};


#endif //  __NUBUSFPGA_HW_H__
