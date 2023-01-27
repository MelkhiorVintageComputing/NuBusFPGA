#include "NuBusFPGADrvr.h"

#define CONFIG_CSR_DATA_WIDTH 32

#include "../nubusfpga_csr_ddrphy.h"
#include "../nubusfpga_csr_sdram.h"

/* auto-generated sdram_phy.h + sc */
#define DFII_CONTROL_SEL        0x01
#define DFII_CONTROL_CKE        0x02
#define DFII_CONTROL_ODT        0x04
#define DFII_CONTROL_RESET_N    0x08

#define DFII_COMMAND_CS         0x01
#define DFII_COMMAND_WE         0x02
#define DFII_COMMAND_CAS        0x04
#define DFII_COMMAND_RAS        0x08
#define DFII_COMMAND_WRDATA     0x10
#define DFII_COMMAND_RDDATA     0x20

#define SDRAM_PHY_A7DDRPHY
#define SDRAM_PHY_XDR 2
#define SDRAM_PHY_DATABITS 16
#define SDRAM_PHY_PHASES 4
#define SDRAM_PHY_CL 6
#define SDRAM_PHY_CWL 5
#define SDRAM_PHY_CMD_LATENCY 0
#define SDRAM_PHY_RDPHASE 2
#define SDRAM_PHY_WRPHASE 3
#define SDRAM_PHY_WRITE_LATENCY_CALIBRATION_CAPABLE
#define SDRAM_PHY_READ_LEVELING_CAPABLE
#define SDRAM_PHY_MODULES SDRAM_PHY_DATABITS/8
#define SDRAM_PHY_DELAYS 32
#define SDRAM_PHY_BITSLIPS 8

__attribute__ ((section (".text.primary"))) static void cdelay(int i);

__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_rst_delay (uint32_t a32, int module);
__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_inc_delay (uint32_t a32, int module);

__attribute__ ((section (".text.primary"))) static inline void command_p0(uint32_t a32, int cmd)
{
    sdram_dfii_pi0_command_write(a32, cmd);
    sdram_dfii_pi0_command_issue_write(a32, 1);
}
__attribute__ ((section (".text.primary"))) static inline void command_p1(uint32_t a32, int cmd)
{
    sdram_dfii_pi1_command_write(a32, cmd);
    sdram_dfii_pi1_command_issue_write(a32, 1);
}
__attribute__ ((section (".text.primary"))) static inline void command_p2(uint32_t a32, int cmd)
{
    sdram_dfii_pi2_command_write(a32, cmd);
    sdram_dfii_pi2_command_issue_write(a32, 1);
}
__attribute__ ((section (".text.primary"))) static inline void command_p3(uint32_t a32, int cmd)
{
    sdram_dfii_pi3_command_write(a32, cmd);
    sdram_dfii_pi3_command_issue_write(a32, 1);
}

#define DFII_PIX_DATA_SIZE CSR_SDRAM_DFII_PI0_WRDATA_SIZE

__attribute__ ((section (".text.primary"))) static inline unsigned long sdram_dfii_pix_wrdata_addr(int phase)
{
    switch (phase) {
        case 0: return CSR_SDRAM_DFII_PI0_WRDATA_ADDR;
		case 1: return CSR_SDRAM_DFII_PI1_WRDATA_ADDR;
		case 2: return CSR_SDRAM_DFII_PI2_WRDATA_ADDR;
		case 3: return CSR_SDRAM_DFII_PI3_WRDATA_ADDR;
        default: return 0;
        }
}
    
__attribute__ ((section (".text.primary"))) static inline unsigned long sdram_dfii_pix_rddata_addr(int phase)
{
    switch (phase) {
        case 0: return CSR_SDRAM_DFII_PI0_RDDATA_ADDR;
		case 1: return CSR_SDRAM_DFII_PI1_RDDATA_ADDR;
		case 2: return CSR_SDRAM_DFII_PI2_RDDATA_ADDR;
		case 3: return CSR_SDRAM_DFII_PI3_RDDATA_ADDR;
        default: return 0;
        }
}
    
#define DDRX_MR_WRLVL_ADDRESS 1
#define DDRX_MR_WRLVL_RESET 6
#define DDRX_MR_WRLVL_BIT 7

__attribute__ ((section (".text.primary"))) static inline void init_sequence(uint32_t a32)
{
	/* Release reset */
	sdram_dfii_pi0_address_write(a32, 0x0);
	sdram_dfii_pi0_baddress_write(a32, 0);
	sdram_dfii_control_write(a32, DFII_CONTROL_ODT|DFII_CONTROL_RESET_N);
	cdelay(50000);

	/* Bring CKE high */
	sdram_dfii_pi0_address_write(a32, 0x0);
	sdram_dfii_pi0_baddress_write(a32, 0);
	sdram_dfii_control_write(a32, DFII_CONTROL_CKE|DFII_CONTROL_ODT|DFII_CONTROL_RESET_N);
	cdelay(10000);

	/* Load Mode Register 2, CWL=5 */
	sdram_dfii_pi0_address_write(a32, 0x200);
	sdram_dfii_pi0_baddress_write(a32, 2);
	command_p0(a32, DFII_COMMAND_RAS|DFII_COMMAND_CAS|DFII_COMMAND_WE|DFII_COMMAND_CS);

	/* Load Mode Register 3 */
	sdram_dfii_pi0_address_write(a32, 0x0);
	sdram_dfii_pi0_baddress_write(a32, 3);
	command_p0(a32, DFII_COMMAND_RAS|DFII_COMMAND_CAS|DFII_COMMAND_WE|DFII_COMMAND_CS);

	/* Load Mode Register 1 */
	sdram_dfii_pi0_address_write(a32, 0x6);
	sdram_dfii_pi0_baddress_write(a32, 1);
	command_p0(a32, DFII_COMMAND_RAS|DFII_COMMAND_CAS|DFII_COMMAND_WE|DFII_COMMAND_CS);

	/* Load Mode Register 0, CL=6, BL=8 */
	sdram_dfii_pi0_address_write(a32, 0x920);
	sdram_dfii_pi0_baddress_write(a32, 0);
	command_p0(a32, DFII_COMMAND_RAS|DFII_COMMAND_CAS|DFII_COMMAND_WE|DFII_COMMAND_CS);
	cdelay(200);

	/* ZQ Calibration */
	sdram_dfii_pi0_address_write(a32, 0x400);
	sdram_dfii_pi0_baddress_write(a32, 0);
	command_p0(a32, DFII_COMMAND_WE|DFII_COMMAND_CS);
	cdelay(200);
}

#include "nubusfpga_csr_common.h"

/* sdram.c from liblitedram, preprocessed for our case, + sc */

__attribute__ ((section (".text.primary"))) static inline unsigned long 
lfsr (unsigned long  bits, unsigned long  prev)
{
  /*static*/ const unsigned long long lfsr_taps[] = {
    0x0L,
    0x0L,
    0x3L,
    0x6L,
    0xcL,
    0x14L,
    0x30L,
    0x60L,
    0xb8L,
    0x110L,
    0x240L,
    0x500L,
    0x829L,
    0x100dL,
    0x2015L,
    0x6000L,
    0xd008L,
    0x12000L,
    0x20400L,
    0x40023L,
    0x90000L,
    0x140000L,
    0x300000L,
    0x420000L,
    0xe10000L,
    0x1200000L,
    0x2000023L,
    0x4000013L,
    0x9000000L,
    0x14000000L,
    0x20000029L,
    0x48000000L,
    0x80200003L,
    0x100080000L,
    0x204000003L,
    0x500000000L,
    0x801000000L,
    0x100000001fL,
    0x2000000031L,
    0x4400000000L,
    0xa000140000L,
    0x12000000000L,
    0x300000c0000L,
    0x63000000000L,
    0xc0000030000L,
    0x1b0000000000L,
    0x300003000000L,
    0x420000000000L,
    0xc00000180000L,
    0x1008000000000L,
    0x3000000c00000L,
    0x6000c00000000L,
    0x9000000000000L,
    0x18003000000000L,
    0x30000000030000L,
    0x40000040000000L,
    0xc0000600000000L,
    0x102000000000000L,
    0x200004000000000L,
    0x600003000000000L,
    0xc00000000000000L,
    0x1800300000000000L,
    0x3000000000000030L,
    0x6000000000000000L,
    0x800000000000000dL
  };
  unsigned long lsb = prev & 1;
  prev >>= 1;
  prev ^= (-lsb) & lfsr_taps[bits];
  return prev;
}

__attribute__ ((section (".text.primary")))
static void cdelay (int i)
{
  //i >>= 2;
  while (i > 0) {
    __asm__ volatile ("");
    i--;
  }
}

__attribute__ ((section (".text.primary"))) static unsigned char
sdram_dfii_get_rdphase(uint32_t a32)
{
  return ddrphy_rdphase_read(a32);
}
__attribute__ ((section (".text.primary"))) static unsigned char
sdram_dfii_get_wrphase(uint32_t a32)
{
  return ddrphy_wrphase_read(a32);
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_pix_address_write(uint32_t a32, unsigned char phase, unsigned int value)
{
  switch (phase) {
  case 3:
    sdram_dfii_pi3_address_write(a32, value);
    break;
  case 2:
    sdram_dfii_pi2_address_write(a32, value);
    break;
  case 1:
    sdram_dfii_pi1_address_write(a32, value);
    break;
  default:
    sdram_dfii_pi0_address_write(a32, value);
  }
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_pird_address_write(uint32_t a32, unsigned int value)
{
  unsigned char rdphase = sdram_dfii_get_rdphase(a32);
  sdram_dfii_pix_address_write(a32, rdphase, value);
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_piwr_address_write(uint32_t a32, unsigned int value)
{
  unsigned char wrphase = sdram_dfii_get_wrphase(a32);
  sdram_dfii_pix_address_write(a32, wrphase, value);
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_pix_baddress_write(uint32_t a32, unsigned char phase, unsigned int value)
{
  switch (phase) {
  case 3:
    sdram_dfii_pi3_baddress_write(a32, value);
    break;
  case 2:
    sdram_dfii_pi2_baddress_write(a32, value);
    break;
  case 1:
    sdram_dfii_pi1_baddress_write(a32, value);
    break;
  default:
    sdram_dfii_pi0_baddress_write(a32, value);
  }
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_pird_baddress_write(uint32_t a32, unsigned int value)
{
  unsigned char rdphase = sdram_dfii_get_rdphase(a32);
  sdram_dfii_pix_baddress_write(a32, rdphase, value);
}
__attribute__ ((section (".text.primary"))) static void
sdram_dfii_piwr_baddress_write(uint32_t a32, unsigned int value)
{
  unsigned char wrphase = sdram_dfii_get_wrphase(a32);
  sdram_dfii_pix_baddress_write(a32, wrphase, value);
}
__attribute__ ((section (".text.primary"))) static void
command_px(uint32_t a32, unsigned char phase, unsigned int value)
{
  switch (phase) {
  case 3:
	  command_p3(a32, value);
    break;
  case 2:
	  command_p2(a32, value);
    break;
  case 1:
	  command_p1(a32, value);
    break;
  default:
	  command_p0(a32, value);
  }
}
__attribute__ ((section (".text.primary"))) static void
command_prd(uint32_t a32, unsigned int value)
{
  unsigned char rdphase = sdram_dfii_get_rdphase(a32);
  command_px(a32, rdphase, value);
}
__attribute__ ((section (".text.primary"))) static void
command_pwr (uint32_t a32, unsigned int value)
{
  unsigned char wrphase = sdram_dfii_get_wrphase(a32);
  command_px(a32, wrphase, value);
}
__attribute__ ((section (".text.primary"))) static void
sdram_software_control_on(uint32_t a32)
{
  unsigned int previous;
  previous = sdram_dfii_control_read(a32);
  if (previous != (0x02 | 0x04 | 0x08)) {
    sdram_dfii_control_write(a32, (0x02 | 0x04 | 0x08));
  }
}
__attribute__ ((section (".text.primary"))) static void
sdram_software_control_off(uint32_t a32)
{
  unsigned int previous;
  previous = sdram_dfii_control_read(a32);
  if (previous != (0x01)) {
    sdram_dfii_control_write(a32, (0x01));
  }
}
__attribute__ ((section (".text.primary"))) static void
sdram_mode_register_write(uint32_t a32, char reg, int value)
{
  sdram_dfii_pi0_address_write(a32, value);
  sdram_dfii_pi0_baddress_write(a32, reg);
  command_p0(a32, 0x08 | 0x04 | 0x02 | 0x01);
}

//typedef void (*delay_callback) (uint32_t a32, int module);

__attribute__ ((section (".text.primary"))) static void
sdram_activate_test_row(uint32_t a32)
{
  sdram_dfii_pi0_address_write(a32, 0);
  sdram_dfii_pi0_baddress_write(a32, 0);
  command_p0(a32, 0x08 | 0x01);
  cdelay (15);
}
__attribute__ ((section (".text.primary"))) static void
sdram_precharge_test_row(uint32_t a32)
{
  sdram_dfii_pi0_address_write(a32, 0);
  sdram_dfii_pi0_baddress_write(a32, 0);
  command_p0(a32, 0x08 | 0x02 | 0x01);
  cdelay (15);
}

__attribute__ ((section (".text.primary"))) static unsigned int
popcount (unsigned int x)
{
  x -= ((x >> 1) & 0x55555555);
  x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
  x = (x + (x >> 4)) & 0x0F0F0F0F;
  x += (x >> 8);
  x += (x >> 16);
  return x & 0x0000003F;
}

__attribute__ ((section (".text.primary"))) static unsigned int
sdram_write_read_check_test_pattern (uint32_t a32, int module, unsigned int seed)
{
  int p, i;
  unsigned int errors;
  unsigned int prv;
  unsigned char tst[1 * 32 / 8];
  unsigned char prs[4][1 * 32 / 8];
  prv = seed;
  for (p = 0; p < 4; p++) {
    for (i = 0; i < 1 * 32 / 8; i++) {
      prv = lfsr (32, prv);
      prs[p][i] = prv;
    }
  }
  sdram_activate_test_row(a32);
  for (p = 0; p < 4; p++)
    csr_wr_buf_uint8(a32, (sdram_dfii_pix_wrdata_addr (p)/* - CSR_SDRAM_BASE*/), prs[p], 1 * 32 / 8); /* cleanme */
  sdram_dfii_piwr_address_write(a32, 0);
  sdram_dfii_piwr_baddress_write(a32, 0);
  command_pwr(a32, 0x04 | 0x02 | 0x01 | 0x10);
  cdelay (15);
  sdram_dfii_pird_address_write(a32, 0);
  sdram_dfii_pird_baddress_write(a32, 0);
  command_prd(a32, 0x04 | 0x01 | 0x20);
  cdelay (15);
  sdram_precharge_test_row(a32);
  errors = 0;
  for (p = 0; p < 4; p++) {
    csr_rd_buf_uint8(a32, (sdram_dfii_pix_rddata_addr (p)/* - CSR_SDRAM_BASE*/), tst, 1 * 32 / 8); /* cleanme */
    errors +=
      popcount (prs[p][16 / 8 - 1 - module] ^ tst[16 / 8 - 1 - module]);
    errors +=
      popcount (prs[p][2 * 16 / 8 - 1 - module] ^
		tst[2 * 16 / 8 - 1 - module]);
  }
  return errors;
}
__attribute__ ((section (".text.primary"))) static void
sdram_leveling_center_module (uint32_t a32, int module, int show_short, int show_long)
/* ,
			      delay_callback rst_delay,
			      delay_callback inc_delay) */
{
  int i;
  int show;
  int working;
  unsigned int errors;
  int delay, delay_mid, delay_range;
  int delay_min = -1, delay_max = -1;
  
  delay = 0;
  //rst_delay(a32, module);
  sdram_read_leveling_rst_delay(a32, module);
  while (1) {
    errors = sdram_write_read_check_test_pattern(a32, module, 42);
    errors += sdram_write_read_check_test_pattern(a32, module, 84);
    working = errors == 0;
    show = show_long;
    
    if (working && delay_min < 0) {
      delay_min = delay;
      break;
    }
    delay++;
    if (delay >= 32)
      break;
    //inc_delay(a32, module);
    sdram_read_leveling_inc_delay(a32, module);
  }
  delay++;
  //inc_delay(a32, module);
  sdram_read_leveling_inc_delay(a32, module);
  while (1) {
    errors = sdram_write_read_check_test_pattern(a32, module, 42);
    errors += sdram_write_read_check_test_pattern(a32, module, 84);
    working = errors == 0;
    show = show_long;
    
    if (!working && delay_max < 0) {
      delay_max = delay;
    }
    delay++;
    if (delay >= 32)
      break;
    //inc_delay(a32, module);
    sdram_read_leveling_inc_delay(a32, module);
  }
  if (delay_max < 0) {
    delay_max = delay;
  }
  
  delay_mid = (delay_min + delay_max) / 2 % 32;
  delay_range = (delay_max - delay_min) / 2;

//delay_mid = 25;
  
  //rst_delay(a32, module);
  sdram_read_leveling_rst_delay(a32, module);
  cdelay (100);
  for (i = 0; i < delay_mid; i++) {
    //inc_delay(a32, module);
    sdram_read_leveling_inc_delay(a32, module);
    cdelay (100);
  }
}

//__attribute__ ((section (".data.primary"))) int _sdram_write_leveling_bitslips[16];

__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_rst_delay (uint32_t a32, int module)
{
  ddrphy_dly_sel_write(a32, 1 << module);
  ddrphy_rdly_dq_rst_write(a32, 1);
  ddrphy_dly_sel_write(a32, 0);
}
__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_inc_delay (uint32_t a32, int module)
{
  ddrphy_dly_sel_write(a32, 1 << module);
  ddrphy_rdly_dq_inc_write(a32, 1);
  ddrphy_dly_sel_write(a32, 0);
}
__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_rst_bitslip (uint32_t a32, char m)
{
  ddrphy_dly_sel_write(a32, 1 << m);
  ddrphy_rdly_dq_bitslip_rst_write(a32, 1);
  ddrphy_dly_sel_write(a32, 0);
}
__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling_inc_bitslip (uint32_t a32, char m)
{
  ddrphy_dly_sel_write(a32, 1 << m);
  ddrphy_rdly_dq_bitslip_write(a32, 1);
  ddrphy_dly_sel_write(a32, 0);
}
__attribute__ ((section (".text.primary"))) static unsigned int
sdram_read_leveling_scan_module (uint32_t a32, int module, int bitslip, int show)
{
  const unsigned int max_errors = 2 * (4 * 2 * 32);
  int i;
  unsigned int score;
  unsigned int errors;
  score = 0;
  
  sdram_read_leveling_rst_delay(a32, module);
  for (i = 0; i < 32; i++) {
    int working;
    int _show = show;
    errors = sdram_write_read_check_test_pattern(a32, module, 42);
    errors += sdram_write_read_check_test_pattern(a32, module, 84);
    working = (errors == 0) ? 1 : 0;
    score += (working * max_errors * 32) + (max_errors - errors);
    
    sdram_read_leveling_inc_delay(a32, module);
  }
  return score;
}
__attribute__ ((section (".text.primary"))) static void
sdram_read_leveling(uint32_t a32)
{
  int module;
  int bitslip;
  unsigned int score;
  unsigned int best_score;
  int best_bitslip;
  for (module = 0; module < 16 / 8; module++) {
    best_score = 0;
    best_bitslip = 0;
    sdram_read_leveling_rst_bitslip(a32, module);
    for (bitslip = 0; bitslip < 8; bitslip++) {
      score = sdram_read_leveling_scan_module(a32, module, bitslip, 1);
      sdram_leveling_center_module(a32, module, 1, 0);
	/*,
				    sdram_read_leveling_rst_delay,
				    sdram_read_leveling_inc_delay);*/
      if (score > best_score) {
	best_bitslip = bitslip;
	best_score = score;
      }
      if (bitslip == 8 - 1)
	break;
      sdram_read_leveling_inc_bitslip(a32, module);
    }
    
//best_bitslip = 1;
 
    sdram_read_leveling_rst_bitslip(a32, module);
    for (bitslip = 0; bitslip < best_bitslip; bitslip++)
      sdram_read_leveling_inc_bitslip(a32, module);
    sdram_leveling_center_module(a32, module, 1, 0);
      /*,
				  sdram_read_leveling_rst_delay,
				  sdram_read_leveling_inc_delay);*/
  }
}
__attribute__ ((section (".text.primary"))) static void
sdram_write_latency_calibration(uint32_t a32)
{
  int i;
  int module;
  int bitslip;
  unsigned int score;
  unsigned int subscore;
  unsigned int best_score;
  int best_bitslip;
  int _sdram_write_leveling_bitslips[16] = {0, 0, 0, 0, 0, 0, 0, 0,
					    0, 0, 0, 0, 0, 0, 0, 0 };
  for (module = 0; module < 16 / 8; module++) {
    best_score = 0;
    best_bitslip = -1;
    for (bitslip = 0; bitslip < 8; bitslip += 2) {
      score = 0;
      ddrphy_dly_sel_write(a32, 1 << module);
      ddrphy_wdly_dq_bitslip_rst_write(a32, 1);
      for (i = 0; i < bitslip; i++) {
	ddrphy_wdly_dq_bitslip_write(a32, 1);
      }
      ddrphy_dly_sel_write(a32, 0);
      score = 0;
      sdram_read_leveling_rst_bitslip(a32, module);
      for (i = 0; i < 8; i++) {
	subscore = sdram_read_leveling_scan_module(a32, module, i, 0);
	score = subscore > score ? subscore : score;
	sdram_read_leveling_inc_bitslip(a32, module);
      }
      if (score > best_score) {
	best_bitslip = bitslip;
	best_score = score;
      }
    }
    if (_sdram_write_leveling_bitslips[module] < 0)
      bitslip = best_bitslip;
    else
      bitslip = _sdram_write_leveling_bitslips[module];
//bitslip = 0;
    ddrphy_dly_sel_write(a32, 1 << module);
    ddrphy_wdly_dq_bitslip_rst_write(a32, 1);
    for (i = 0; i < bitslip; i++) {
      ddrphy_wdly_dq_bitslip_write(a32, 1);
    }
    ddrphy_dly_sel_write(a32, 0);
  }
}
__attribute__ ((section (".text.primary"))) static int
sdram_leveling(uint32_t a32)
{
  int module;
  sdram_software_control_on(a32);
  for (module = 0; module < 16 / 8; module++) {
    sdram_read_leveling_rst_delay(a32, module);
    sdram_read_leveling_rst_bitslip(a32, module);
  }
  sdram_write_latency_calibration(a32);
  sdram_read_leveling(a32);
  sdram_software_control_off(a32);
  return 1;
}
int
sdram_init(uint32_t a32) // // attribute in header file
{
  ddrphy_rdphase_write(a32, 2);
  ddrphy_wrphase_write(a32, 3);
  sdram_software_control_on(a32);
  ddrphy_rst_write(a32, 1);
  cdelay (1000);
  ddrphy_rst_write(a32, 0);
  cdelay (1000);
  init_sequence(a32);
  sdram_leveling(a32);
  sdram_software_control_off(a32);
  return 1;
}
