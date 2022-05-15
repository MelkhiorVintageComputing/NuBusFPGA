from migen import *
from migen.genlib.fifo import *

import litex
from litex.soc.interconnect import wishbone

from migen.genlib.cdc import BusSynchronizer

class Wishbone2NuBus(Module):
    def __init__(self, nubus, wb):

        # cpu
    # input         cpu_valid,
    # input [31:0]  cpu_addr,
    # input [31:0]  cpu_wdata,
    # input  [ 3:0] cpu_write,
    # output        cpu_ready,
    # output [31:0] cpu_rdata,
    #input         cpu_lock,
    #input         cpu_eclr,
    #output [3:0]  cpu_errors,

        #wb_adr_rev = Signal(32)
        #self.comb += [ wb_adr_rev[ 0: 8].eq(wb.adr[22:30]),
        #               wb_adr_rev[ 8:16].eq(wb.adr[14:22]),
        #               wb_adr_rev[16:24].eq(wb.adr[ 6:14]),
        #               wb_adr_rev[24:32].eq(Cat(Signal(2, reset = 0),wb.adr[ 0: 6])), ]

        self.comb += nubus.cpu_valid.eq(wb.cyc & wb.stb)
        self.comb += nubus.cpu_addr.eq(Cat(Signal(2, reset = 0), wb.adr))
        #self.comb += nubus.cpu_addr.eq(wb_adr_rev)
        self.comb += nubus.cpu_wdata.eq(wb.dat_w)
        self.comb += If(wb.we == 1,
                        nubus.cpu_write.eq(wb.sel)).Else(
                            nubus.cpu_write.eq(0))
        self.comb += wb.ack.eq(nubus.cpu_ready)
        self.comb += wb.dat_r.eq(nubus.cpu_rdata)
        self.comb += nubus.cpu_lock.eq(0) # FIXME: TODO: ???
        self.comb += nubus.cpu_eclr.eq(0) # FIXME: TODO: ???
        
        #pad_user_led_0 = platform.request("user_led", 0)
        #pad_user_led_1 = platform.request("user_led", 1)
        #self.comb += pad_user_led_0.eq(nubus.cpu_valid)
        #cpu_valid_ex = Signal(reset = 0)
        #self.sync += cpu_valid_ex.eq(nubus.cpu_valid | cpu_valid_ex)
        #self.comb += pad_user_led_1.eq(cpu_valid_ex)
        
