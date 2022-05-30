from migen import *
from migen.genlib.fifo import *

import litex
from litex.soc.interconnect import wishbone

class PingMaster(Module):
    def __init__(self, platform):
        self.bus_slv = bus_slv = wishbone.Interface()
        self.bus_mst = bus_mst = wishbone.Interface()

        led0 = platform.request("user_led", 0)
        led1 = platform.request("user_led", 1)

        valu_reg = Signal(32)
        addr_reg = Signal(32)
        writ_del = Signal(6)
        do_write = Signal()
        #addr_reg_rev = Signal(32)
        #self.comb += [ addr_reg_rev[ 0: 8].eq(addr_reg[24:32]),
        #               addr_reg_rev[ 8:16].eq(addr_reg[16:24]),
        #               addr_reg_rev[16:24].eq(addr_reg[ 8:16]),
        #               addr_reg_rev[24:32].eq(addr_reg[ 0: 8]), ]

        self.sync += [ If(writ_del != 0,
                          writ_del.eq(writ_del - 1),),
                       If(writ_del == 1,
                          do_write.eq(1),
                       )
        ]
        
        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus_slv.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus_slv.cyc & bus_slv.stb & bus_slv.we & ~bus_slv.ack, #write
                            # FIXME: should check for prefix?
                            Case(bus_slv.adr[0:1], {
                                0x0: [ NextValue(valu_reg, bus_slv.dat_w[0:32]), ],
                                0x1: [ NextValue(addr_reg, bus_slv.dat_w[0:32]),
                                       NextValue(writ_del, 63), ],
                            }),
                            NextValue(bus_slv.ack, 1),
                         ).Elif(bus_slv.cyc & bus_slv.stb & ~bus_slv.we & ~bus_slv.ack, #read
                                Case(bus_slv.adr[0:1], {
                                    0x0: [ NextValue(bus_slv.dat_r, valu_reg), ],
                                    0x1: [ NextValue(bus_slv.dat_r, addr_reg), ],
                                }),
                                NextValue(bus_slv.ack, 1),
                         ).Else(
                             NextValue(bus_slv.ack, 0),
                         )
        )
        
        self.submodules.writer_fsm = writer_fsm = FSM(reset_state = "Reset")
        writer_fsm.act("Reset",
                       NextState("Idle"),)
        writer_fsm.act("Idle",
                       If(do_write,
                          NextValue(do_write, 0),
                          NextState("Write"),),)
        writer_fsm.act("Write",
                       bus_mst.cyc.eq(1),
                       bus_mst.stb.eq(1),
                       bus_mst.we.eq(1),
                       bus_mst.dat_w.eq(valu_reg),
                       bus_mst.adr.eq(addr_reg[2:32]),
                       bus_mst.sel.eq(0xf),
                       If(bus_mst.ack,
                          NextState("Idle")),
        )
        
        self.comb += [ led0.eq(bus_mst.cyc),
                       led1.eq(writ_del != 0), ]
