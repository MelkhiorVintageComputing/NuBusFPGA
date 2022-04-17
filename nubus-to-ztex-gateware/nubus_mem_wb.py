from migen import *
from migen.genlib.fifo import *

import litex
from litex.soc.interconnect import wishbone

from migen.genlib.cdc import BusSynchronizer

class NuBus2Wishbone(Module):
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

        #nubus_mem_addr_revb = Signal(32)
        #self.comb += nubus_mem_addr_revb.eq(Cat(nubus.mem_addr[24:32], nubus.mem_addr[16:24], nubus.mem_addr[8:16], nubus.mem_addr[0:8]))

        self.comb += wb.cyc.eq(nubus.mem_valid)
        self.comb += wb.stb.eq(nubus.mem_valid)
        self.comb += If(nubus.mem_write == 0,
                        wb.sel.eq(0xF)).Else(
                            wb.sel.eq(nubus.mem_write))
        self.comb += wb.we.eq(nubus.mem_write != 0)
        
        self.comb += [
            If(~nubus.mem_addr[23], # first 8 MiB of slot space: remap to last 8 Mib of SDRAM
               wb.adr.eq(Cat(nubus.mem_addr[2:23], Signal(1, reset=1), Signal(8, reset = 0x8f))), # 0x8f8...
            ).Else( # second 8 MiB: direct access
                wb.adr.eq(Cat(nubus.mem_addr[2:24], Signal(8, reset = 0)))), # 24 bits, a.k.a 22 bits of words
            ]
        
        self.comb += [
            wb.dat_w.eq(nubus.mem_wdata),
            nubus.mem_rdata.eq(wb.dat_r),
            #wb.dat_w.eq(Cat(nubus.mem_wdata[24:32], nubus.mem_wdata[16:24], nubus.mem_wdata[8:16], nubus.mem_wdata[0:8])),
            #nubus.mem_rdata.eq(Cat(wb.dat_r[24:32], wb.dat_r[16:24], wb.dat_r[8:16], wb.dat_r[0:8])),
        ]
            
        self.comb += nubus.mem_ready.eq(wb.ack)
        self.comb += nubus.mem_error.eq(0) # FIXME: TODO: ???
        self.comb += nubus.mem_tryagain.eq(0) # FIXME: TODO: ???
