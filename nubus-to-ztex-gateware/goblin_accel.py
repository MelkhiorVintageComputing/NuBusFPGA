from migen import *
from migen.genlib.fifo import *

from litex.soc.interconnect.csr import *

from litex.soc.interconnect import wishbone

class GoblinAccel(Module): # AutoCSR ?
    def __init__(self, soc):
        platform = soc.platform
        
        # reg access
        self.bus = bus = wishbone.Interface()
        
        self.COORD_BITS = COORD_BITS = 12 #

        reg_status = Signal(32) # 0
        reg_cmd = Signal(32) # 1
        reg_r5_cmd = Signal(32) # 2, to communicate with Vex
        # 3 resv0
        reg_width = Signal(COORD_BITS)
        reg_height = Signal(COORD_BITS)
        # 6 resv1
        # 7 resv2
        reg_bitblt_src_x = Signal(COORD_BITS) # 8
        reg_bitblt_src_y = Signal(COORD_BITS) # 9
        reg_bitblt_dst_x = Signal(COORD_BITS) # 10
        reg_bitblt_dst_y = Signal(COORD_BITS) # 11
        
        # do-some-work flags
        do_blit = Signal()

        # cmd register reg_cmd
        DO_BLIT_BIT = 0
        
        # global status register reg_status
        WORK_IN_PROGRESS_BIT = 0

        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus.cyc & bus.stb & bus.we & ~bus.ack, #write
                            Case(bus.adr[0:10], { #
                                "default": [ ],
                                # 0: reg_status R/O
                                0: [ NextValue(reg_status, bus.dat_w) ], # debug, remove me
                                1: [ NextValue(reg_cmd, bus.dat_w),
                                     NextValue(do_blit, bus.dat_w[DO_BLIT_BIT] & ~reg_status[WORK_IN_PROGRESS_BIT]),
                                ],
                                2: [ NextValue(reg_r5_cmd, bus.dat_w) ],
                                # 3
                                4: [ NextValue(reg_width, bus.dat_w) ],
                                5: [ NextValue(reg_height, bus.dat_w) ],
                                # 6,7
                                8: [ NextValue(reg_bitblt_src_x, bus.dat_w) ],
                                9: [ NextValue(reg_bitblt_src_y, bus.dat_w) ],
                                10: [ NextValue(reg_bitblt_dst_x, bus.dat_w) ],
                                11: [ NextValue(reg_bitblt_dst_y, bus.dat_w) ],
                            }),
                            NextValue(bus.ack, 1),
                            ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack, #read
                                   Case(bus.adr[0:10], {
                                       "default": [ NextValue(bus.dat_r, 0xDEADBEEF) ],
                                       0: [ NextValue(bus.dat_r, reg_status) ],
                                       1: [ NextValue(bus.dat_r, reg_cmd) ],
                                       2: [ NextValue(bus.dat_r, reg_r5_cmd) ],
                                       # 3
                                       4: [ NextValue(bus.dat_r, reg_width) ],
                                       5: [ NextValue(bus.dat_r, reg_height) ],
                                       # 6, 7
                                       8: [ NextValue(bus.dat_r, reg_bitblt_src_x) ],
                                       9: [ NextValue(bus.dat_r, reg_bitblt_src_y) ],
                                       10: [ NextValue(bus.dat_r, reg_bitblt_dst_x) ],
                                       11: [ NextValue(bus.dat_r, reg_bitblt_dst_y) ],
                                   }),
                                   NextValue(bus.ack, 1),
                            ).Else(
                                NextValue(bus.ack, 0),
                            )
        )
        
        # also in blit.c, for r5-cmd
        FUN_DONE_BIT = 31
        FUN_BLIT_BIT = 0
        # to hold the Vex in reset
        local_reset = Signal(reset = 1)

        self.sync += [
            If(reg_r5_cmd[FUN_DONE_BIT],
               reg_r5_cmd.eq(0),
               reg_status[WORK_IN_PROGRESS_BIT].eq(0),
               local_reset.eq(1),
               #timeout.eq(timeout_rst),
            ).Elif(do_blit & ~reg_status[WORK_IN_PROGRESS_BIT],
                   do_blit.eq(0),
                   reg_r5_cmd[FUN_BLIT_BIT].eq(1),
                   reg_status[WORK_IN_PROGRESS_BIT].eq(1),
                   local_reset.eq(0),
                   #timeout.eq(timeout_rst),
            )
        ]

        led0 = platform.request("user_led", 0)
        self.comb += led0.eq(~local_reset)
        
        self.ibus = ibus = wishbone.Interface()
        self.dbus = dbus = wishbone.Interface()
        vex_reset = Signal()

        self.comb += vex_reset.eq(ResetSignal("sys") | local_reset)
        self.specials += Instance(self.get_netlist_name(),
                                  i_clk = ClockSignal("sys"),
                                  i_reset = vex_reset,
                                  o_iBusWishbone_CYC = ibus.cyc,
                                  o_iBusWishbone_STB = ibus.stb,
                                  i_iBusWishbone_ACK = ibus.ack,
                                  o_iBusWishbone_WE  = ibus.we,
                                  o_iBusWishbone_ADR = ibus.adr,
                                  i_iBusWishbone_DAT_MISO = ibus.dat_r,
                                  o_iBusWishbone_DAT_MOSI = ibus.dat_w,
                                  o_iBusWishbone_SEL = ibus.sel,
                                  i_iBusWishbone_ERR = ibus.err,
                                  o_iBusWishbone_CTI = ibus.cti,
                                  o_iBusWishbone_BTE = ibus.bte,
                                  o_dBusWishbone_CYC = dbus.cyc,
                                  o_dBusWishbone_STB = dbus.stb,
                                  i_dBusWishbone_ACK = dbus.ack,
                                  o_dBusWishbone_WE  = dbus.we,
                                  o_dBusWishbone_ADR = dbus.adr,
                                  i_dBusWishbone_DAT_MISO = dbus.dat_r,
                                  o_dBusWishbone_DAT_MOSI = dbus.dat_w,
                                  o_dBusWishbone_SEL = dbus.sel,
                                  i_dBusWishbone_ERR = dbus.err,
                                  o_dBusWishbone_CTI = dbus.cti,
                                  o_dBusWishbone_BTE = dbus.bte,)

        self.add_sources(platform)
                                     
    def get_netlist_name(self):
        return "VexRiscv"

    def add_sources(self, platform):
        platform.add_source("/home/dolbeau/NuBusFPGA/nubus-to-ztex-gateware/VexRiscv_FbAccel.v", "verilog")
