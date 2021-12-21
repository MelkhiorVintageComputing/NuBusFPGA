from migen import *
from migen.genlib.fifo import *

import litex
from litex.soc.interconnect import wishbone

from migen.genlib.cdc import BusSynchronizer

class NuBus2Wishbone(Module):
    """Wishbone Clock Domain Crossing [Master]"""
    def __init__(self, nubus, wb):
        
        # memory
        # nubus.mem_valid
        # nubus.mem_addr
        # nubus.mem_wdata
        # nubus.mem_write
        # nubus.mem_ready
        # nubus.mem_rdata
        #nubus.mem_error
        #nubus.mem_tryagain

        self.comb += wb.cyc.eq(nubus.mem_valid)
        self.comb += wb.stb.eq(nubus.mem_valid)
        self.comb += If(nubus.mem_write == 0,
                        wb.sel.eq(0xF)).Else(
                            wb.sel.eq(nubus.mem_write))
        self.comb += wb.we.eq(nubus.mem_write != 0)
        self.comb += wb.adr.eq(Cat(nubus.mem_addr[2:24], Signal(8, reset = 0))) # 24 bits, a.k.a 22 bits of words
        self.comb += wb.dat_w.eq(nubus.mem_wdata)
        self.comb += nubus.mem_rdata.eq(wb.dat_r)
        self.comb += nubus.mem_ready.eq(wb.ack)
        self.comb += nubus.mem_error.eq(0)
        self.comb += nubus.mem_tryagain.eq(0)
