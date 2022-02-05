from migen import *

from litedram.frontend.dma import LiteDRAMDMAReader;

# LiteDRAMDFBMAReader --------------------------------------------------------------------------------
# Hardwire the loop, uses control signals instead of CSRs

class LiteDRAMFBDMAReader(LiteDRAMDMAReader):
    def __init__(self, port, fifo_depth=16, default_base=0, default_length=0):
        LiteDRAMDMAReader.__init__(self = self, port = port, fifo_depth = fifo_depth, fifo_buffered = True, with_csr = False)
        
        enable = self.enable = Signal(reset = 0)
        base   = self.base   = Signal(self.port.address_width, reset = default_base)
        offset = self.offset = Signal(self.port.address_width, reset = 0)
        length = self.length = Signal(self.port.address_width, reset = default_length)
        
        fsm = FSM(reset_state="IDLE")
        fsm = ResetInserter()(fsm)
        self.submodules.fsm = fsm
        self.comb += fsm.reset.eq(~enable)
        fsm.act("IDLE",
                NextValue(offset, 0),
                NextState("RUN"),
        )
        fsm.act("RUN",
                self.sink.valid.eq(1),
                self.sink.last.eq(offset == (length - 1)),
                self.sink.address.eq(base + offset),
                If(self.sink.ready,
                   NextValue(offset, offset + 1),
                   If(self.sink.last,
                      NextValue(offset, 0)
                   )
                )
        )
