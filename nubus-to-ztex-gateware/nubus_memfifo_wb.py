from migen import *
from migen.genlib.fifo import *

import litex
from litex.soc.interconnect import wishbone

from migen.genlib.cdc import BusSynchronizer

class NuBus2WishboneFIFO(Module):
    def __init__(self, platform, nubus, wb_read, wb_write):
        
        # memory
        # nubus.mem_valid
        # nubus.mem_addr
        # nubus.mem_wdata
        # nubus.mem_write
        # nubus.mem_ready
        # nubus.mem_rdata
        #nubus.mem_error
        #nubus.mem_tryagain

        assert(len(wb_read.dat_r) == 32)
        assert(len(nubus.mem_wdata) == 32)
        assert(len(nubus.mem_write) == 4)
        
        write_fifo_layout = [
            ("adr", 32),
            ("data", 32),
            ("sel", 4),
        ]
        self.submodules.write_fifo = write_fifo = ClockDomainsRenamer({"read": "sys", "write": "nubus"})(AsyncFIFOBuffered(width=layout_len(write_fifo_layout), depth=8))
        write_fifo_dout = Record(write_fifo_layout)
        self.comb += write_fifo_dout.raw_bits().eq(write_fifo.dout)
        write_fifo_din = Record(write_fifo_layout)
        self.comb += write_fifo.din.eq(write_fifo_din.raw_bits())

        self.comb += wb_read.cyc.eq(nubus.mem_valid & (nubus.mem_write == 0)) # only handle reads
        self.comb += wb_read.stb.eq(nubus.mem_valid & (nubus.mem_write == 0)) # only handle reads
        self.comb += wb_read.we.eq(0) #(nubus.mem_write != 0)
        
        self.comb += [
            If(~nubus.mem_addr[23], # first 8 MiB of slot space: remap to last 8 Mib of SDRAM
               wb_read.adr.eq(Cat(nubus.mem_addr[2:23], Signal(1, reset=1), Signal(8, reset = 0x8f))), # 0x8f8...
            ).Else( # second 8 MiB: direct access
                wb_read.adr.eq(Cat(nubus.mem_addr[2:24], Signal(8, reset = 0xf0)))), # 24 bits, a.k.a 22 bits of words
            ]
        
        #self.comb += If(nubus.mem_write == 0,
        #                wb_read.sel.eq(0xF)).Else(
        #                    wb_read.sel.eq(nubus.mem_write))
        self.comb += [
            #wb_read.dat_w.eq(nubus.mem_wdata),
            wb_read.sel.eq(0xF),
            nubus.mem_rdata.eq(wb_read.dat_r),
        ]

        write_ack = Signal()
        self.comb += nubus.mem_ready.eq(wb_read.ack | write_ack)
        self.comb += nubus.mem_error.eq(0) # FIXME: TODO: ???
        self.comb += nubus.mem_tryagain.eq(0) # FIXME: TODO: ???

        #led0 = platform.request("user_led", 0)
        #led1 = platform.request("user_led", 1)
        #self.comb += [ led0.eq(wb_read.ack),
        #               led1.eq(write_ack), ]

        #self.submodules.write_fsm = write_fsm = FSM(reset_state = "Reset")
        #write_fsm.act("Reset",
        #              NextState("Idle"))
        #write_fsm.act("Idle",)

        # in NuBus
        #self.comb += [ write_fifo.we.eq(write_fifo.writable & nubus.mem_valid & (nubus.mem_write != 0)),
        #               write_ack.eq(write_fifo.writable & nubus.mem_valid & (nubus.mem_write != 0))
        #]
        #self.comb += [ write_fifo_din.adr.eq(nubus.mem_addr),
        #               write_fifo_din.data.eq(nubus.mem_wdata),
        #               write_fifo_din.sel.eq(nubus.mem_write),
        #]

        self.submodules.write_fsm = write_fsm = ClockDomainsRenamer("nubus")(FSM(reset_state = "Reset"))
        write_fsm.act("Reset",
                      NextState("Idle"))
        write_fsm.act("Idle",
                      If(nubus.mem_valid & (nubus.mem_write != 0), # & write_fifo.writable),
                         NextState("WriteFifo"),
                      )
        )
        write_fsm.act("WriteFifo",
                      write_fifo.we.eq(1),
                      write_ack.eq(1), # the one cycle delay is needed for the tmO -> nubus.mem_write -> ack dependency chain
                      NextState("WaitForNuBus"),
        )
        write_fsm.act("WaitForNuBus",
                      If(~nubus.mem_valid,
                         NextState("Idle"),
                      )
        )
        self.comb += [ write_fifo_din.adr.eq(nubus.mem_addr),
                       write_fifo_din.data.eq(nubus.mem_wdata),
                       write_fifo_din.sel.eq(nubus.mem_write),
        ]
                       
        self.comb += [ wb_write.cyc.eq(write_fifo.readable),
                       wb_write.stb.eq(write_fifo.readable),
                       wb_write.we.eq(1),
                       If(~write_fifo_dout.adr[23], # first 8 MiB of slot space: remap to last 8 Mib of SDRAM
                          wb_write.adr.eq(Cat(write_fifo_dout.adr[2:23], Signal(1, reset=1), Signal(8, reset = 0x8f))), # 0x8f8...
                       ).Else( # second 8 MiB: direct access
                           wb_write.adr.eq(Cat(write_fifo_dout.adr[2:24], Signal(8, reset = 0xf0)))), # 24 bits, a.k.a 22 bits of words
                       wb_write.dat_w.eq(write_fifo_dout.data),
                       wb_write.sel.eq(write_fifo_dout.sel),
                       write_fifo.re.eq(wb_write.ack),
        ]
