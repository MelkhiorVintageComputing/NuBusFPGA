from migen import *
from migen.genlib.fifo import *
from migen.genlib.cdc import *
from migen.fhdl.specials import Tristate

import litex
from litex.soc.interconnect import wishbone

class NuBus(Module):
    def __init__(self, platform, wb_read, wb_write, wb_dma, cd_nubus="nubus", cd_nubus90="nubus90"):

        self.add_sources(platform)

        #led0 = platform.request("user_led", 0)
        #led1 = platform.request("user_led", 1)

        # Signals for tri-stated nubus access
        # slave
        tmo_oe = Signal() # output enable
        tm0_i_n = Signal()
        tm0_o_n = Signal()
        tm1_i_n = Signal()
        tm1_o_n = Signal()
        ack_i_n = Signal()
        ack_o_n = Signal()

        ad_oe = Signal()
        ad_i_n = Signal(32)
        ad_o_n = Signal(32)

        id_i_n = Signal(4)

        start_i_n = Signal()
        start_o_n = Signal() # master via master_oe

        # master
        rqst_oe = Signal()
        rqst_i_n = Signal()
        rqst_o_n = Signal()

        # sampled signals, exposing the value of the register acquired on the falling edge
        # they can change every cycle *on falling edge*
        # slave
        sampled_tm0 = Signal() # high is byte (which byte is in ad0/ad1); low is halfword/word/block depending on ad0/ad1
        sampled_tm1 = Signal() # high is write
        sampled_start = Signal()
        sampled_ack = Signal()
        sampled_ad = Signal(32)

        # master
        sampled_rqst = Signal()

        # address rewriting
        # can change every cycle *on falling edge*
        processed_ad = Signal(32)
        self.comb += [
            processed_ad[0:23].eq(sampled_ad[0:23]),
            If(~sampled_ad[23], # first 8 MiB of slot space: remap to last 8 Mib of SDRAM
               processed_ad[23:32].eq(Cat(Signal(1, reset=1), Signal(8, reset = 0x8f))), # 0x8f8...
            ).Else( # second 8 MiB: direct access
                processed_ad[23:32].eq(Cat(sampled_ad[23], Signal(8, reset = 0xf0)))), # 24 bits, a.k.a 22 bits of words
        ]

        # decoded signals, exposing decoded results from the sampled signals
        # they can change every cycle *on falling edge*
        # from sampling (fixme?)
        decoded_sel = Signal(4)
        decoded_block = Signal()
        decoded_busy = Signal()
        # locally evaluated
        decoded_myslot = Signal()
        self.comb += [
            decoded_myslot.eq(
                (sampled_ad[28:32] == 0xF) &
                (sampled_ad[27] == ~id_i_n[3]) &
                (sampled_ad[26] == ~id_i_n[2]) &
                (sampled_ad[25] == ~id_i_n[1]) &
                (sampled_ad[24] == ~id_i_n[0])),
            #led0.eq(decoded_block),
        ]

        # current value, registered from the sampled/processed/decoded signals
        # change is controlled by the FSM
        current_adr = Signal(32)
        current_tm0 = Signal()
        current_tm1 = Signal()
        current_sel = Signal(4)
        current_block = Signal()
        current_data = Signal(32)

        # write FIFO to speed up bus turnaround on NuBus side
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
        
        self.specials += Instance("nubus_sampling",
                                  i_nub_clkn = ClockSignal(cd_nubus),
                                  i_nub_resetn = ~ResetSignal(cd_nubus),
                                  i_nub_tm0n = tm0_i_n,
                                  i_nub_tm1n = tm1_i_n,
                                  i_nub_startn = start_i_n,
                                  i_nub_rqstn = rqst_i_n,
                                  i_nub_ackn = ack_i_n,
                                  i_nub_adn = ad_i_n,

                                  o_tm0 = sampled_tm0,
                                  o_tm1 = sampled_tm1,
                                  o_start = sampled_start,
                                  o_rqst = sampled_rqst,
                                  o_ack = sampled_ack,
                                  o_ad = sampled_ad,

                                  o_sel = decoded_sel,
                                  o_block = decoded_block,
                                  o_busy = decoded_busy,
        )

        self.submodules.slave_fsm = slave_fsm = ClockDomainsRenamer(cd_nubus)(FSM(reset_state="Reset"))
        slave_fsm.act("Reset",
                      NextState("Idle")
        )
        slave_fsm.act("Idle",
                      If(decoded_myslot & sampled_start & ~sampled_ack & ~sampled_tm1,# & ~decoded_block, # regular read (we always send back 32 bits, so don't worry about byte/word)
                         NextValue(current_adr, processed_ad),
                         #NextValue(current_tm0, sampled_tm0),
                         #NextValue(current_tm1, sampled_tm1),
                         #NextValue(current_sel, decoded_sel),
                         #NextValue(current_block, decoded_block),
                         #If(decoded_block,
                         #   NextValue(decoded_block_memory, 1),),
                         NextState("WaitWBRead"),
                      ).Elif(decoded_myslot & sampled_start & ~sampled_ack & sampled_tm1,# & ~decoded_block, # regular write
                             NextValue(current_adr, processed_ad),
                             #NextValue(current_tm0, sampled_tm0),
                             #NextValue(current_tm1, sampled_tm1),
                             NextValue(current_sel, decoded_sel),
                             #NextValue(current_block, decoded_block),
                             #If(decoded_block,
                             #   NextValue(decoded_block_memory, 1),),
                             #NextState("GetNubusWriteData"),
                             NextState("NubusWriteDataToFIFO"),
                      )
        )
        slave_fsm.act("WaitWBRead",
                      wb_read.cyc.eq(1),
                      wb_read.stb.eq(1),
                      wb_read.we.eq(0),
                      wb_read.sel.eq(0xf),
                      wb_read.adr.eq(current_adr[2:32]),
                      tmo_oe.eq(1),
                      tm0_o_n.eq(1),
                      tm1_o_n.eq(1),
                      ack_o_n.eq(1),
                      If(wb_read.ack,
                      ad_oe.eq(1),
                         ad_o_n.eq(~wb_read.dat_r),
                         tm0_o_n.eq(0),
                         tm1_o_n.eq(0),
                         ack_o_n.eq(0),
                         NextState("Idle"),
                      )
        )
        #slave_fsm.act("GetNubusWriteData",
        #              NextValue(current_data, sampled_ad),
        #              wb_read.cyc.eq(1),
        #              wb_read.stb.eq(1),
        #              wb_read.we.eq(1),
        #              wb_read.sel.eq(current_sel),
        #              wb_read.adr.eq(current_adr[2:32]),
        #              wb_read.dat_w.eq(sampled_ad),
        #              If(wb_read.ack,
        #                 tmo_oe.eq(1),
        #                 tm0_o_n.eq(0),
        #                 tm1_o_n.eq(0),
        #                 ack_o_n.eq(0),
        #                 NextState("Idle"),
        #              ).Else(
        #                  NextState("WaitWBWrite"),
        #              )
        #)
        #slave_fsm.act("WaitWBWrite",
        #              wb_read.cyc.eq(1),
        #              wb_read.stb.eq(1),
        #              wb_read.we.eq(1),
        #              wb_read.sel.eq(current_sel),
        #              wb_read.adr.eq(current_adr[2:32]),
        #              wb_read.dat_w.eq(current_data),
        #              If(wb_read.ack,
        #                 tmo_oe.eq(1),
        #                 tm0_o_n.eq(0),
        #                 tm1_o_n.eq(0),
        #                 ack_o_n.eq(0),
        #                 NextState("Idle"),
        #              )
        #)
        slave_fsm.act("NubusWriteDataToFIFO",
                      write_fifo.we.eq(1),
                      tmo_oe.eq(1),
                      tm0_o_n.eq(0),
                      tm1_o_n.eq(0),
                      ack_o_n.eq(0),
                      NextState("Idle"),
        )

        # connect the write FIFO inputs
        self.comb += [ write_fifo_din.adr.eq(current_adr), # recorded
                       write_fifo_din.data.eq(sampled_ad), # we do it live
                       write_fifo_din.sel.eq(current_sel), # recorded
        ]
        # deal with emptying the Write FIFO to the write WB
        self.comb += [ wb_write.cyc.eq(write_fifo.readable),
                       wb_write.stb.eq(write_fifo.readable),
                       wb_write.we.eq(1),
                       wb_write.adr.eq(write_fifo_dout.adr[2:32]),
                       wb_write.dat_w.eq(write_fifo_dout.data),
                       wb_write.sel.eq(write_fifo_dout.sel),
                       write_fifo.re.eq(wb_write.ack),
        ]

        owning_bus = Signal(reset = 0) # fixme ; theoretically one can bypass arbitration when owning the bus

        start_arbitration = Signal()
        grant = Signal()
        master_oe = Signal()

        nubus_sync = getattr(self.sync, cd_nubus)
        nubus_sync += [
            If(sampled_rqst & ~start_arbitration,
               owning_bus.eq(0),
            )
        ]
        
        self.submodules.dma_fsm = dma_fsm = ClockDomainsRenamer(cd_nubus)(FSM(reset_state="Reset"))
        dma_fsm.act("Reset",
                    NextState("Idle")
        )
        dma_fsm.act("Idle",
                    If(wb_dma.cyc & wb_dma.stb & ~sampled_rqst, # we need the bus and it's not being requested
                       If(owning_bus, # we own the bus, skip arbitration
                          NextState("AdrCycle"),
                       ).Else(        # go for arbitration
                           NextState("Arbitration"),
                       ),
                    )
        )
        dma_fsm.act("Arbitration",
                    start_arbitration.eq(1),
                    rqst_oe.eq(1),
                    rqst_o_n.eq(0),
                    NextState("WaitForGrant"),
        )
        dma_fsm.act("WaitForGrant",
                    start_arbitration.eq(1),
                    rqst_oe.eq(1),
                    rqst_o_n.eq(0),
                    If(grant & ~decoded_busy, # I'm now 'owner'
                       NextValue(owning_bus, 1),
                       NextState("AdrCycle"),
                    )
        )
        dma_fsm.act("AdrCycle",
                    start_arbitration.eq(0),
                    master_oe.eq(1), # for start
                    tmo_oe.eq(1), # for tm0, tm1, ack
                    ad_oe.eq(1), # for write address
                    start_o_n.eq(0),
                    tm0_o_n.eq(~((wb_dma.sel == 0x1) | (wb_dma.sel == 0x2) | (wb_dma.sel == 0x4) | (wb_dma.sel == 0x8))), # byte only
                    tm1_o_n.eq(~wb_dma.we),
                    ad_o_n[0].eq(~((wb_dma.sel == 0x2) | (wb_dma.sel == 0x3) | (wb_dma.sel == 0x8) | (wb_dma.sel == 0xc))), # odd bytes, both half-words
                    ad_o_n[1].eq(~((wb_dma.sel == 0x4) | (wb_dma.sel == 0x8) | (wb_dma.sel == 0xc))), # upper bytes and half-word
                    ad_o_n[2:32].eq(~wb_dma.adr),
                    ack_o_n.eq(1),
                    If(wb_dma.we,
                       NextState("DatCycle"),
                    ).Else(
                        NextState("ReadWaitForAck"),
                    )
        )
        dma_fsm.act("DatCycle",
                    master_oe.eq(1), # for start
                    ad_oe.eq(1), # for write data
                    start_o_n.eq(1), # start finished, but still need to be driven
                    ad_o_n.eq(~wb_dma.dat_w),
                    If(sampled_ack,
                       wb_dma.ack.eq(1),
                       # fixme: check status ??? (tm0 and tm1 should be active for no-error)
                       NextState("FinishCycle"),
                    )
        )
        dma_fsm.act("FinishCycle",
                    master_oe.eq(1), # for start
                    start_o_n.eq(1), # start finished, but still need to be driven
                    tmo_oe.eq(1), # for tm0, tm1, ack, need to be driven to inactive
                    tm0_o_n.eq(1),
                    tm1_o_n.eq(1),
                    ack_o_n.eq(1),
                    NextState("Idle"),
        )
        dma_fsm.act("ReadWaitForAck",
                    master_oe.eq(1), # for start
                    start_o_n.eq(1), # start finished, but still need to be driven
                    wb_dma.dat_r.eq(sampled_ad),
                    If(sampled_ack,
                       wb_dma.ack.eq(1),
                       # fixme: check status ??? (tm0 and tm1 should be active for no-error)
                       NextState("FinishCycle"),
                    )
        )
        
        # stuff at this end so we don't use the signals inadvertantly

        # real NuBus signals
        nub_tm0n = platform.request("tm0_3v3_n")
        nub_tm1n = platform.request("tm1_3v3_n")
        nub_startn = platform.request("start_3v3_n")
        nub_ackn = platform.request("ack_3v3_n")
        nub_adn = platform.request("ad_3v3_n")
        nub_idn = platform.request("id_3v3_n")

        # Tri-state
        self.specials += Tristate(nub_tm0n,   tm0_o_n,   tmo_oe,    tm0_i_n)
        self.specials += Tristate(nub_tm1n,   tm1_o_n,   tmo_oe,    tm1_i_n)
        self.specials += Tristate(nub_ackn,   ack_o_n,   tmo_oe,    ack_i_n)
        self.specials += Tristate(nub_adn,    ad_o_n,    ad_oe,     ad_i_n)
        self.specials += Tristate(nub_startn, start_o_n, master_oe, start_i_n)
        self.comb += [
            id_i_n.eq(nub_idn),
        ] 
        
        # NubusFPGA-only signals
        nf_tmoen = platform.request("tmoen")
        nf_nubus_ad_dir = platform.request("nubus_ad_dir")

        self.comb += [
            nf_tmoen.eq(~tmo_oe),
            nf_nubus_ad_dir.eq(~ad_oe),
        ]
        
        # real Nubus signal, for master
        nub_rqstn = platform.request("rqst_3v3_n")
        
        # Tri-state
        self.specials += Tristate(nub_rqstn, rqst_o_n, rqst_oe, rqst_i_n)

        # NubusFPGA-only signals, for master
        nub_arbcy_n = platform.request("arbcy_n")
        nf_grant = platform.request("grant")
        nf_nubus_master_dir = platform.request("nubus_master_dir")
        nf_fpga_to_cpld_signal = platform.request("fpga_to_cpld_signal")

        # NuBus90 signals, , for completeness
        nub_clk2xn = ClockSignal(cd_nubus90)
        nub_tm2n = platform.request("tm2_3v3_n")

        self.comb += [
            nf_nubus_master_dir.eq(master_oe),
            nub_arbcy_n.eq(~start_arbitration),
            grant.eq(nf_grant),
            nf_fpga_to_cpld_signal.eq(~rqst_oe),
        ] 

        
    def add_sources(self, platform):
        # sampling of data on falling edge of clock, done in verilog
        platform.add_source("nubus_sampling.v", "verilog")
