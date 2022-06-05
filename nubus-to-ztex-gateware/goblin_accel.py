from migen import *
from migen.genlib.fifo import *

from litex.soc.interconnect.csr import *

from litex.soc.interconnect import wishbone

from litedram.common import LiteDRAMNativePort
from litedram.frontend.wishbone import LiteDRAMWishbone2Native

class GoblinAccel(Module): # AutoCSR ?
    def __init__(self, soc):
        platform = soc.platform
        
        # reg access
        self.bus = bus = wishbone.Interface()
        
        self.COORD_BITS = COORD_BITS = 14 # need enough bytes for 32-bits depth and widest resolution ; should be <= 15 otherwise the INIT code will need to strip the upper bit from some parameters

        reg_status = Signal(32) # 0
        reg_cmd = Signal(32) # 1
        reg_r5_cmd = Signal(32) # 2, to communicate with Vex
        # 3 resv0
        reg_width = Signal(COORD_BITS) # 4
        reg_height = Signal(COORD_BITS) # 5
        reg_fgcolor = Signal(32) # 6
        # 7 resv2
        reg_bitblt_src_x = Signal(COORD_BITS) # 8
        reg_bitblt_src_y = Signal(COORD_BITS) # 9
        reg_bitblt_dst_x = Signal(COORD_BITS) # 10
        reg_bitblt_dst_y = Signal(COORD_BITS) # 11
        reg_src_stride = Signal(COORD_BITS) # 12
        reg_dst_stride = Signal(COORD_BITS) # 13
        reg_src_ptr = Signal(32) # 14
        reg_dst_ptr = Signal(32) # 15
        
        # do-some-work flags
        do_blit = Signal()
        do_fill = Signal()
        do_test = Signal()

        # cmd register reg_cmd
        DO_BLIT_BIT = 0
        DO_FILL_BIT = 1
        DO_TEST_BIT = 3
        
        # global status register reg_status
        WORK_IN_PROGRESS_BIT = 0

        # replicate all registers in both endianess
        # we want to avoid byte-reversal on either the host or the Vex
        bus_dat_w_endian = Signal(32)
        bus_dat_r_endian = Signal(32)
        self.comb += [
            If(bus.adr[9], # 9 on bus is 11 for host
               bus_dat_w_endian[24:32].eq(bus.dat_w[ 0: 8]),
               bus_dat_w_endian[16:24].eq(bus.dat_w[ 8:16]),
               bus_dat_w_endian[ 8:16].eq(bus.dat_w[16:24]),
               bus_dat_w_endian[ 0: 8].eq(bus.dat_w[24:32]),
               bus.dat_r[24:32].eq(bus_dat_r_endian[ 0: 8]),
               bus.dat_r[16:24].eq(bus_dat_r_endian[ 8:16]),
               bus.dat_r[ 8:16].eq(bus_dat_r_endian[16:24]),
               bus.dat_r[ 0: 8].eq(bus_dat_r_endian[24:32]),
            ).Else(
                bus_dat_w_endian.eq(bus.dat_w),
                bus.dat_r.eq(bus_dat_r_endian),
            )
        ]

        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus.cyc & bus.stb & bus.we & ~bus.ack, #write
                            Case(bus.adr[0:9], { # bit 9 is used for endianess, so not there
                                "default": [ ],
                                # 0: reg_status R/O
                                0:  [ NextValue(reg_status, bus_dat_w_endian) ], # debug, remove me
                                1:  [ NextValue(reg_cmd, bus_dat_w_endian),
                                      NextValue(do_blit, bus_dat_w_endian[DO_BLIT_BIT] & ~reg_status[WORK_IN_PROGRESS_BIT]),
                                      NextValue(do_fill, bus_dat_w_endian[DO_FILL_BIT] & ~reg_status[WORK_IN_PROGRESS_BIT]),
                                      NextValue(do_test, bus_dat_w_endian[DO_TEST_BIT] & ~reg_status[WORK_IN_PROGRESS_BIT]),
                                ],
                                2:  [ NextValue(reg_r5_cmd, bus_dat_w_endian) ],
                                # 3
                                4:  [ NextValue(reg_width, bus_dat_w_endian) ],
                                5:  [ NextValue(reg_height, bus_dat_w_endian) ],
                                6:  [ NextValue(reg_fgcolor, bus_dat_w_endian) ],
                                # 7
                                8:  [ NextValue(reg_bitblt_src_x, bus_dat_w_endian) ],
                                9:  [ NextValue(reg_bitblt_src_y, bus_dat_w_endian) ],
                                10: [ NextValue(reg_bitblt_dst_x, bus_dat_w_endian) ],
                                11: [ NextValue(reg_bitblt_dst_y, bus_dat_w_endian) ],
                                12: [ NextValue(reg_src_stride, bus_dat_w_endian) ],
                                13: [ NextValue(reg_dst_stride, bus_dat_w_endian) ],
                                14: [ NextValue(reg_src_ptr, bus_dat_w_endian) ],
                                15: [ NextValue(reg_dst_ptr, bus_dat_w_endian) ],
                            }),
                            NextValue(bus.ack, 1),
                            ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack, #read
                                   Case(bus.adr[0:9], { # bit 9 is used for endianess, so not there
                                       "default": [ NextValue(bus_dat_r_endian, 0xDEADBEEF) ],
                                       0:  [ NextValue(bus_dat_r_endian, reg_status) ],
                                       1:  [ NextValue(bus_dat_r_endian, reg_cmd) ],
                                       2:  [ NextValue(bus_dat_r_endian, reg_r5_cmd) ],
                                       # 3
                                       4:  [ NextValue(bus_dat_r_endian, reg_width) ],
                                       5:  [ NextValue(bus_dat_r_endian, reg_height) ],
                                       6:  [ NextValue(bus_dat_r_endian, reg_fgcolor) ],
                                       # 7
                                       8:  [ NextValue(bus_dat_r_endian, reg_bitblt_src_x) ],
                                       9:  [ NextValue(bus_dat_r_endian, reg_bitblt_src_y) ],
                                       10: [ NextValue(bus_dat_r_endian, reg_bitblt_dst_x) ],
                                       11: [ NextValue(bus_dat_r_endian, reg_bitblt_dst_y) ],
                                       12: [ NextValue(bus_dat_r_endian, reg_src_stride) ],
                                       13: [ NextValue(bus_dat_r_endian, reg_dst_stride) ],
                                       14: [ NextValue(bus_dat_r_endian, reg_src_ptr) ],
                                       15: [ NextValue(bus_dat_r_endian, reg_dst_ptr) ],
                                   }),
                                   NextValue(bus.ack, 1),
                            ).Else(
                                NextValue(bus.ack, 0),
                            )
        )
        
        # also in blit.c, for r5-cmd
        FUN_DONE_BIT = 31
        FUN_BLIT_BIT = 0
        FUN_FILL_BIT = 1
        FUN_TEST_BIT = 3
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
            ).Elif(do_fill & ~reg_status[WORK_IN_PROGRESS_BIT],
                   do_fill.eq(0),
                   reg_r5_cmd[FUN_FILL_BIT].eq(1),
                   reg_status[WORK_IN_PROGRESS_BIT].eq(1),
                   local_reset.eq(0),
                   #timeout.eq(timeout_rst),
            ).Elif(do_test & ~reg_status[WORK_IN_PROGRESS_BIT],
                   do_test.eq(0),
                   reg_r5_cmd[FUN_TEST_BIT].eq(1),
                   reg_status[WORK_IN_PROGRESS_BIT].eq(1),
                   local_reset.eq(0),
                   #timeout.eq(timeout_rst),
            )
        ]

        #led0 = platform.request("user_led", 0)
        #self.comb += led0.eq(~local_reset)        # Vex connection to the primary bus
        self.ibus = ibus = wishbone.Interface()
        #self.dbus = dbus = wishbone.Interface()
        vex_reset = Signal()

        dbus_raw = wishbone.Interface(data_width=128, adr_width=28) # wide interface from the Vex, master
        dbus_sys = wishbone.Interface(data_width=128, adr_width=28) # wide interface to system wishbone
        dbus_mem = wishbone.Interface(data_width=128, adr_width=28) # wide interface for direct memory access
        self.dbus = dbus_sys
        
        #masters = {}
        #masters["VexRiscv_AccelFB"] = dbus_raw

        ##slaves["VexSystemAccess"] = dbus
        ##regions["VexSystemAccess"] = SoCRegion(origin=soc.mem_map.get("goblin_bt", None), size=0x00100000, cached=False)
        ##slaves["VexMemoryAccess"] = dbus_mem
        ##regions["VexSystemAccess"] = SoCRegion(origin=soc.mem_map.get("main_ram", None), size=0x10000000, cached=True)

        #function_VexSystemAccess = lambda x: (x[24:28] != 0x8)
        #function_VexMemoryAccess = lambda x: (x[24:28] == 0x8)
        ##function_VexSystemAccess = lambda x: (True)
        ##function_VexMemoryAccess = lambda x: (False)
        
        #slaves = [
        #    (function_VexSystemAccess, dbus_sys),
        #    (function_VexMemoryAccess, dbus_mem),
        #]

        #self.submodules.crossbar = wishbone.Crossbar(
        #    masters = masters.values(),
        #    slaves = slaves,
        #    register = False,
        #    timeout_cycles = None
        #)
        #self.submodules.shared = wishbone.InterconnectShared(
        #    masters = masters.values(),
        #    slaves = slaves,
        #    register = False,
        #    timeout_cycles = None
        #)

        self.comb += [
            If((dbus_raw.adr[24:28] == 0x8),
               dbus_sys.cyc.eq(0),
               dbus_sys.stb.eq(0),
               dbus_mem.cyc.eq(dbus_raw.cyc),
               dbus_mem.stb.eq(dbus_raw.stb),
               
               dbus_raw.ack.eq(dbus_mem.ack),
               dbus_raw.err.eq(dbus_mem.err),
               dbus_raw.dat_r.eq(dbus_mem.dat_r),
            ).Else(
               dbus_sys.cyc.eq(dbus_raw.cyc),
               dbus_sys.stb.eq(dbus_raw.stb),
               dbus_mem.cyc.eq(0),
               dbus_mem.stb.eq(0),
               
               dbus_raw.ack.eq(dbus_sys.ack),
               dbus_raw.err.eq(dbus_sys.err),
               dbus_raw.dat_r.eq(dbus_sys.dat_r),
            ),
            dbus_sys.dat_w.eq(dbus_raw.dat_w),
            dbus_mem.dat_w.eq(dbus_raw.dat_w),
            dbus_sys.we.eq(dbus_raw.we),
            dbus_mem.we.eq(dbus_raw.we),
            dbus_sys.adr.eq(dbus_raw.adr),
            dbus_mem.adr.eq(dbus_raw.adr),
            dbus_sys.sel.eq(dbus_raw.sel),
            dbus_mem.sel.eq(dbus_raw.sel),
            dbus_sys.cti.eq(dbus_raw.cti),
            dbus_mem.cti.eq(dbus_raw.cti),
            dbus_sys.bte.eq(dbus_raw.bte),
            dbus_mem.bte.eq(dbus_raw.bte),
        ]

        # now connect the memory

        # memory port
        port = soc.sdram.crossbar.get_port()
        assert(port.data_width == 128)
        self.submodules.wb2native = LiteDRAMWishbone2Native(
            wishbone     = dbus_mem,
            port         = port,
            base_address = soc.bus.regions["main_ram"].origin
        )

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
                                  o_dBusWishbone_CYC = dbus_raw.cyc,
                                  o_dBusWishbone_STB = dbus_raw.stb,
                                  i_dBusWishbone_ACK = dbus_raw.ack,
                                  o_dBusWishbone_WE  = dbus_raw.we,
                                  o_dBusWishbone_ADR = dbus_raw.adr,
                                  i_dBusWishbone_DAT_MISO = dbus_raw.dat_r,
                                  o_dBusWishbone_DAT_MOSI = dbus_raw.dat_w,
                                  o_dBusWishbone_SEL = dbus_raw.sel,
                                  i_dBusWishbone_ERR = dbus_raw.err,
                                  o_dBusWishbone_CTI = dbus_raw.cti,
                                  o_dBusWishbone_BTE = dbus_raw.bte,)

        self.add_sources(platform)
                                     
    def get_netlist_name(self):
        return "VexRiscv"

    def add_sources(self, platform):
        platform.add_source("/home/dolbeau/NuBusFPGA/nubus-to-ztex-gateware/VexRiscv_FbAccel.v", "verilog")
