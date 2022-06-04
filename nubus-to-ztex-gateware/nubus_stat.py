from migen import *
from migen.genlib.fifo import *
from migen.genlib.cdc import BusSynchronizer

import litex
from litex.soc.interconnect import wishbone

class NuBusStat(Module):
    def __init__(self, nubus, platform):
        self.bus_slv = bus_slv = wishbone.Interface()

        read_ctr = Signal(32)
        writ_ctr = Signal(32)

        self.submodules.sync_read_ctr = BusSynchronizer(width = 32, idomain="nubus", odomain="sys")
        self.submodules.sync_writ_ctr = BusSynchronizer(width = 32, idomain="nubus", odomain="sys")
        self.comb += [
            self.sync_read_ctr.i.eq(nubus.read_ctr),
            read_ctr.eq(self.sync_read_ctr.o),
            self.sync_writ_ctr.i.eq(nubus.writ_ctr),
            writ_ctr.eq(self.sync_writ_ctr.o),
        ]
        
        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus_slv.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus_slv.cyc & bus_slv.stb & bus_slv.we & ~bus_slv.ack, #write
                            # FIXME: should check for prefix?
                            #Case(bus_slv.adr[0:10], {
                            #    0x0: [ NextValue(read_ctr, bus_slv.dat_w[0:32]), ],
                            #    0x1: [ NextValue(write_ctr, bus_slv.dat_w[0:32]), ],
                            #}),
                            NextValue(bus_slv.ack, 1),
                         ).Elif(bus_slv.cyc & bus_slv.stb & ~bus_slv.we & ~bus_slv.ack, #read
                                Case(bus_slv.adr[0:10], {
                                    0x0: [ NextValue(bus_slv.dat_r, Cat(read_ctr[24:32], read_ctr[16:24], read_ctr[ 8:16], read_ctr[ 0: 8])), ],
                                    0x1: [ NextValue(bus_slv.dat_r, Cat(writ_ctr[24:32], writ_ctr[16:24], writ_ctr[ 8:16], writ_ctr[ 0: 8])), ],
                                }),
                                NextValue(bus_slv.ack, 1),
                         ).Else(
                             NextValue(bus_slv.ack, 0),
                         )
        )
