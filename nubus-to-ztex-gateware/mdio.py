from migen import *
from migen.genlib.fifo import *
from migen.fhdl.specials import Tristate

from litex.soc.interconnect.csr import *

import litex

class MDIOCtrl(Module, AutoCSR):
    def __init__(self, platform):
        
        div_clk_begin = 39
        div_clk_half = 20
        
        sig_mdc = platform.request("sep_mdc");
        sig_mdio = platform.request("sep_mdio");
        mdio_o = Signal()
        mdio_oe = Signal()
        mdio_i = Signal()

        clk_div = Signal(log2_int(div_clk_begin, False))
        int_cnt = Signal(log2_int(32))
        rdata = Signal(32) # DEBUG, should be 16, FIXME
        cmd_recv = Signal()
        
        self.specials += Tristate(sig_mdio, mdio_o, mdio_oe, mdio_i)

        self.reg_addr = reg_addr = CSRStorage(fields = [CSRField("reg_addr",  5, description = "Reg Addr"),
                                                        CSRField("reserved", 27, description = "Reserved"),])
        self.phy_addr = phy_addr = CSRStorage(fields = [CSRField("phy_addr",  5, description = "Phy Addr"),
                                                        CSRField("reserved", 27, description = "Reserved"),])
        self.mdio_command = mdio_command = CSRStorage(fields = [CSRField("read",  1, description = "Read"),
                                                                CSRField("write", 1, description = "write"),
                                                                CSRField("reserved", 30, description = "Reserved"),])
        self.mdio_status = mdio_status = CSRStatus(fields = [CSRField("access_complete",  1, description = "Phy Addr"),
                                                             CSRField("busy", 1, description = "busy"),
                                                             CSRField("reserved", 30, description = "Reserved"),])
        self.mdio_write = mdio_write = CSRStorage(fields = [CSRField("val",  16, description = "writeval"),
                                                            CSRField("reserved", 16, description = "Reserved"),])
        #self.mdio_read = mdio_read = CSRStatus(fields = [CSRField("val",  16, description = "readval"),
        #                                                 CSRField("reserved", 16, description = "Reserved"),])
        self.mdio_read = mdio_read = CSRStatus(fields = [CSRField("val",  32, description = "readval"),]) # DEBUG, should be 16, FIXME
        
        self.submodules.wishbone_fsm = mdio_fsm = FSM(reset_state = "Reset")

        self.comb += [
            mdio_status.fields.access_complete.eq(mdio_fsm.ongoing("Idle")),
            mdio_status.fields.busy.eq(cmd_recv),
            mdio_read.fields.val.eq(rdata),
        ]

        output_data = Signal(32)
        in_preamble = Signal()
        shift_od = Signal()
        self.sync += [
            If(shift_od,
               output_data.eq(Cat(Signal(1, reset = 0), output_data[0:31])),
            ),
        ]
        self.comb += [
            #If(in_preamble,
            #   mdio_o.eq(1),
            #).Else(
            #    mdio_o.eq(output_data[31]),
            #),
            mdio_o.eq(in_preamble | output_data[31]),
        ]
        shift_rd = Signal()
        shift_rd2 = Signal()
        self.sync += [
            shift_rd2.eq(shift_rd), # delay by one cycle
            If(shift_rd2,
               output_data.eq(Cat(rdata[1:32], Signal(1, reset = 0))), # DEBUG, should be 16, FIXME
            ),
        ]

        mdc = Signal()
        self.comb += [ sig_mdc.eq(mdc), ]
        self.sync += [
            If(clk_div == 0,
               clk_div.eq(div_clk_begin),
               mdc.eq(1),
            ).Else(
                If(clk_div == div_clk_half,
                   mdc.eq(0),
                ),
                clk_div.eq(clk_div - 1),
            ),
            If(mdio_command.re,
               cmd_recv.eq(1),
            ),
        ]

        write = Signal()
        
        mdio_fsm.act("Reset",
                     NextState("Idle")
        )
        mdio_fsm.act("Idle",
                     in_preamble.eq(0),
                     mdio_oe.eq(0), # don't drive
                     #mdio_oe.eq(1), # drive 0 at idle ?
                     If(cmd_recv & (clk_div == 2), # CHECKME
                        NextValue(cmd_recv, 0),
                        NextValue(write, mdio_command.fields.write),
                        
                        NextValue(output_data[0:16], mdio_write.fields.val),
                        NextValue(output_data[16:18], 0x2), # TA
                        NextValue(output_data[18:23], reg_addr.fields.reg_addr),
                        NextValue(output_data[23:28], phy_addr.fields.phy_addr),
                        If(mdio_command.fields.write,
                           NextValue(output_data[28:30], 0x1), # write
                        ).Else(
                            NextValue(output_data[28:30], 0x2), # read
                            NextValue(rdata, 0xFFFFFFFF),
                        ),
                        NextValue(output_data[30:32], 0x1), # start
                        in_preamble.eq(1),
                        mdio_oe.eq(1),
                        NextValue(int_cnt, 31),
                        NextState("Preamble"),
                     )
        )
        
        mdio_fsm.act("Preamble",
                     in_preamble.eq(1),
                     mdio_oe.eq(1),
                     If(clk_div == 2, # CHECKME
                        If(int_cnt == 0,
                           NextValue(int_cnt, 31),
                           in_preamble.eq(0), # switch mdio_o to MSb of output_data
                           If(write,
                              NextState("WData"),
                           ).Else(
                               NextState("RData"),
                           ),
                        ).Else(
                            NextValue(int_cnt, int_cnt - 1),
                            NextState("Preamble"),
                        )
                     ),
        )
                       
        mdio_fsm.act("WData",
                     in_preamble.eq(0),
                     mdio_oe.eq(1),
                     If(clk_div == 2,
                        shift_od.eq(1), # so during clk_div == 1, output will move to the next bit
                        NextValue(int_cnt, int_cnt - 1),
                        If(int_cnt == 0,
                           mdio_o.eq(1), # help pull-ups
                           mdio_oe.eq(0), # stop driving
                           NextValue(output_data, 0), # make sure it's zero
                           NextState("Idle"), ## fixme: delay to idle by one MDC clok cycle?
                        )
                     ),
        )
                       
        mdio_fsm.act("RData",
                     in_preamble.eq(0),
                     mdio_oe.eq(1),
                     If(clk_div == 2,
                        shift_od.eq(1), # so during clk_div == 2, output will move to the next bit
                        NextValue(int_cnt, int_cnt - 1),
                        If(int_cnt == 18,
                           #mdio_o.eq(1), # help pull-ups
                           #mdio_oe.eq(0), # stop driving during TA
                           NextState("TA"),
                        )
                     ),
        )
                       
        mdio_fsm.act("TA",
                     mdio_oe.eq(0),
                     If(clk_div == 2,
                        NextValue(rdata[15], mdio_i), # DEBUG, will capture on 17 and 16, will be flushed by shifting
                        shift_rd.eq(1), # DEBUG, shift in 2 cycles to make room
                        NextValue(int_cnt, int_cnt - 1),
                        If(int_cnt == 16,
                           NextValue(output_data, 0), # make sure it's zero
                           NextState("Capture"),
                        )
                     ),
        )
                       
        mdio_fsm.act("Capture",
                     mdio_oe.eq(0),
                     If(clk_div == 2,
                        NextValue(rdata[15], mdio_i),
                        NextValue(int_cnt, int_cnt - 1),
                        If(int_cnt == 0,
                           NextState("Idle"),
                        ).Else(
                            shift_rd.eq(1), # shift in 2 cycles to make room
                        )
                     ),
        )
        
        led0 = platform.request("user_led", 0)
        led1 = platform.request("user_led", 1)

        self.comb += [
            led0.eq(~mdio_fsm.ongoing("Idle")),
            #led1.eq(clk_div != 0),
        ]
