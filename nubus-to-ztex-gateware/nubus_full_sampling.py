from migen import *
from migen.genlib.fifo import *
from migen.genlib.cdc import *
from migen.fhdl.specials import Tristate

import litex
from litex.soc.interconnect import wishbone

class NuBus(Module):
    def __init__(self, soc,
                 burst_size, tosbus_fifo, fromsbus_fifo, fromsbus_req_fifo,
                 wb_read, wb_write, wb_dma,
                 cd_nubus="nubus", cd_nubus90="nubus90"):
        
        platform = soc.platform
        self.add_sources(platform)

        #led0 = platform.request("user_led", 0)
        #led1 = platform.request("user_led", 1)

        nub_clk = ClockSignal(cd_nubus)
        nub_resetn = ~ResetSignal(cd_nubus)
        nub_clk_prev_bits = 4 # how many cycles after posedge do we still dare set some signals (i.e. still before setup time before negedge)
        nub_clk_prev = Signal(nub_clk_prev_bits)
        nub_clk_negedge = Signal()
        nub_clk_posedge = Signal()
        nub_clk_insetup = Signal()
        self.sync += [
            nub_clk_prev[0].eq(nub_clk),
        ]
        self.sync += [
            nub_clk_prev[i].eq(nub_clk_prev[i-1]) for i in range(1, nub_clk_prev_bits)
        ]
        self.sync += [
            nub_clk_negedge.eq(~nub_clk &  nub_clk_prev[0]),
            nub_clk_posedge.eq( nub_clk & ~nub_clk_prev[0]),
            nub_clk_insetup.eq( nub_clk & (nub_clk_prev != ((2**nub_clk_prev_bits)-1))), # if one of the previous X cycles is zero, we're early enough to set up signals
        ]

        # Signals for tri-stated nubus access
        # slave
        tmo_oe = Signal() # output enable
        tm0_i_n = Signal()
        tm0_o_n = Signal(reset = 1)
        tm1_i_n = Signal()
        tm1_o_n = Signal(reset = 1)
        ack_i_n = Signal()
        ack_o_n = Signal(reset = 1)

        ad_oe = Signal()
        ad_i_n = Signal(32)
        ad_o_n = Signal(32)

        id_i_n = Signal(4)

        start_i_n = Signal()
        start_o_n = Signal(reset = 1) # master via master_oe

        # master
        rqst_oe = Signal()
        rqst_i_n = Signal()
        rqst_o_n = Signal(reset = 1)

        # sampled signals, exposing the value of the register acquired on the falling edge
        # they can change every cycle *on falling edge*
        # slave
        sampled_tm0 = Signal() # high is byte (which byte is in ad0/ad1); low is halfword/word/block depending on ad0/ad1
        sampled_tm1 = Signal() # high is write
        sampled_start = Signal()
        sampled_ack = Signal()
        sampled_ad = Signal(32)
        sampled_ad_byterev = Signal(32)

        # master
        sampled_rqst = Signal()

        # address rewriting
        # can change every cycle *on falling edge*
        processed_ad = Signal(32)
        processed_super_ad = Signal(32)
        self.comb += [
            processed_ad[0:23].eq(sampled_ad[0:23]),
            If(~sampled_ad[23], # first 8 MiB of slot space: remap to last 8 Mib of SDRAM
               processed_ad[23:32].eq(Cat(Signal(1, reset=1), Signal(8, reset = 0x8f))), # 0x8f8...
            ).Else( # second 8 MiB: direct access
                processed_ad[23:32].eq(Cat(sampled_ad[23], Signal(8, reset = 0xf0)))), # 24 bits, a.k.a 22 bits of words
            processed_super_ad[0:28].eq(sampled_ad[0:28]),
            processed_super_ad[28:32].eq(Signal(4, reset = 0x8)),
            sampled_ad_byterev[ 0: 8].eq(sampled_ad[24:32]),
            sampled_ad_byterev[ 8:16].eq(sampled_ad[16:24]),
            sampled_ad_byterev[16:24].eq(sampled_ad[ 8:16]),
            sampled_ad_byterev[24:32].eq(sampled_ad[ 0: 8]),
        ]

        # decoded signals, exposing decoded results from the sampled signals
        # they can change every cycle *on falling edge*
        # from sampling (fixme?)
        decoded_sel = Signal(4)
        decoded_block = Signal()
        decoded_busy = Signal()
        # locally evaluated
        decoded_myslot = Signal()
        decoded_mysuperslot = Signal()
        self.comb += [
            decoded_myslot.eq(
                (sampled_ad[28:32] == 0xF) &
                (sampled_ad[27] == ~id_i_n[3]) &
                (sampled_ad[26] == ~id_i_n[2]) &
                (sampled_ad[25] == ~id_i_n[1]) &
                (sampled_ad[24] == ~id_i_n[0])),
            decoded_mysuperslot.eq(
                (sampled_ad[31] == ~id_i_n[3]) &
                (sampled_ad[30] == ~id_i_n[2]) &
                (sampled_ad[29] == ~id_i_n[1]) &
                (sampled_ad[28] == ~id_i_n[0])),
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
        self.submodules.write_fifo = write_fifo = SyncFIFOBuffered(width=layout_len(write_fifo_layout), depth=16)
        write_fifo_dout = Record(write_fifo_layout)
        self.comb += write_fifo_dout.raw_bits().eq(write_fifo.dout)
        write_fifo_din = Record(write_fifo_layout)
        self.comb += write_fifo.din.eq(write_fifo_din.raw_bits())

        self.sync += [
            #If((~nub_clk &  nub_clk_prev[0]), # simultaneous with setting negedge
            If(nub_clk_negedge,
               sampled_tm0.eq(~tm0_i_n),
               sampled_tm1.eq(~tm1_i_n),
               sampled_start.eq(~start_i_n),
               sampled_rqst.eq(~rqst_i_n),
               sampled_ack.eq(~ack_i_n),
               sampled_ad.eq(~ad_i_n),
            )
        ]
        
        self.comb += [
            decoded_block.eq(sampled_ad[1] & ~sampled_ad[0] & ~sampled_tm0), # 1x block write or 1x block read
            decoded_sel[3].eq(sampled_tm1 &  sampled_ad[1] &  sampled_ad[0] &  sampled_tm0 # Byte 3
                            | sampled_tm1 &  sampled_ad[1] &  sampled_ad[0] & ~sampled_tm0 # Half 1
                            | sampled_tm1 & ~sampled_ad[1] & ~sampled_ad[0] & ~sampled_tm0 # Word
            ),
            decoded_sel[2].eq(sampled_tm1 &  sampled_ad[1] & ~sampled_ad[0] &  sampled_tm0 # Byte 2
                            | sampled_tm1 &  sampled_ad[1] &  sampled_ad[0] & ~sampled_tm0 # Half 1
                            | sampled_tm1 & ~sampled_ad[1] & ~sampled_ad[0] & ~sampled_tm0 # Word
            ),
            decoded_sel[1].eq(sampled_tm1 & ~sampled_ad[1] &  sampled_ad[0] &  sampled_tm0 # Byte 1
                            | sampled_tm1 & ~sampled_ad[1] &  sampled_ad[0] & ~sampled_tm0 # Half 0
                            | sampled_tm1 & ~sampled_ad[1] & ~sampled_ad[0] & ~sampled_tm0 # Word
            ),
            decoded_sel[0].eq(sampled_tm1 & ~sampled_ad[1] & ~sampled_ad[0] &  sampled_tm0 # Byte 0
                            | sampled_tm1 & ~sampled_ad[1] &  sampled_ad[0] & ~sampled_tm0 # Half 0
                            | sampled_tm1 & ~sampled_ad[1] & ~sampled_ad[0] & ~sampled_tm0 # Word
            ),
        ]
        
        self.read_ctr = read_ctr = Signal(32)
        self.writ_ctr = writ_ctr = Signal(32)

        self.submodules.slave_fsm = slave_fsm = FSM(reset_state="Reset")
        slave_fsm.act("Reset",
                      NextState("Idle")
        )
        slave_fsm.act("Idle",
                      # only react to transaction start at posedge
                      If(nub_clk_posedge & (decoded_myslot | decoded_mysuperslot) & sampled_start & ~sampled_ack & ~sampled_tm1,# & ~decoded_block, # regular read (we always send back 32 bits, so don't worry about byte/word)
                         If(decoded_myslot,
                            NextValue(current_adr, processed_ad),
                         ).Else( # decoded_mysuperslot,
                                NextValue(current_adr, processed_super_ad),
                         ),
                         #NextValue(current_tm0, sampled_tm0),
                         #NextValue(current_tm1, sampled_tm1),
                         #NextValue(current_sel, decoded_sel),
                         #NextValue(current_block, decoded_block),
                         #If(decoded_block,
                         #   NextValue(decoded_block_memory, 1),),
                         NextValue(read_ctr, read_ctr + 1),
                         NextState("WaitWBRead"),
                      ).Elif(nub_clk_posedge & (decoded_myslot | decoded_mysuperslot) & sampled_start & ~sampled_ack & sampled_tm1,# & ~decoded_block, # regular write
                             If(decoded_myslot,
                                NextValue(current_adr, processed_ad),
                             ).Else( # decoded_mysuperslot,
                                    NextValue(current_adr, processed_super_ad),
                             ),
                             #NextValue(current_tm0, sampled_tm0),
                             #NextValue(current_tm1, sampled_tm1),
                             NextValue(current_sel, decoded_sel),
                             #NextValue(current_block, decoded_block),
                             #If(decoded_block,
                             #   NextValue(decoded_block_memory, 1),),
                             #NextState("GetNubusWriteData"),
                             NextValue(writ_ctr, writ_ctr + 1),
                             If(write_fifo.writable,
                                NextState("NubusWriteDataToFIFO"),
                             ).Else(
                                NextState("NubusWaitForFIFO"),
                             )
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
                         NextValue(current_data, wb_read.dat_r),
                         If(nub_clk_insetup,
                            ad_oe.eq(1),
                            ad_o_n.eq(~wb_read.dat_r),
                            tm0_o_n.eq(0),
                            tm1_o_n.eq(0),
                            ack_o_n.eq(0),
                            NextState("FinishRead"),
                         ).Else(
                             NextState("WaitBeforeFinishRead"),
                         )
                      )
        )
        slave_fsm.act("WaitBeforeFinishRead",
                      tmo_oe.eq(1),
                      tm0_o_n.eq(1),
                      tm1_o_n.eq(1),
                      ack_o_n.eq(1),
                      If(nub_clk_insetup,
                         ad_oe.eq(1),
                         ad_o_n.eq(~current_data),
                         tm0_o_n.eq(0),
                         tm1_o_n.eq(0),
                         ack_o_n.eq(0),
                         NextState("FinishRead"),
                      ),
        )
        slave_fsm.act("FinishRead",
                      tmo_oe.eq(1),
                      ad_oe.eq(1),
                      ad_o_n.eq(~current_data),
                      tm0_o_n.eq(0),
                      tm1_o_n.eq(0),
                      ack_o_n.eq(0),
                      #If((~nub_clk &  nub_clk_prev[0]), # simultaneous with setting negedge
                      If(nub_clk_negedge,
                         NextState("ReadCleanup"),
                      )
        )
        slave_fsm.act("ReadCleanup",
                      tmo_oe.eq(1),
                      ad_oe.eq(1),
                      ad_o_n.eq(~current_data),
                      tm0_o_n.eq(0),
                      tm1_o_n.eq(0),
                      ack_o_n.eq(0),
                      NextState("Idle"),
                      ),
        
        slave_fsm.act("NubusWriteDataToFIFO",
                      tmo_oe.eq(1),
                      tm0_o_n.eq(0),
                      tm1_o_n.eq(0),
                      ack_o_n.eq(0),
                      #If((~nub_clk &  nub_clk_prev[0]), # simultaneous with setting negedge
                      If(nub_clk_negedge,
                         write_fifo.we.eq(1),
                         NextState("WriteCleanup"),
                      )
        )
        slave_fsm.act("NubusWaitForFIFO",
                      tmo_oe.eq(1),
                      tm0_o_n.eq(1),
                      tm1_o_n.eq(1),
                      ack_o_n.eq(1),
                      If(nub_clk_posedge & write_fifo.writable,
                         NextState("NubusWriteDataToFIFO"),
                      )
        )             
        slave_fsm.act("WriteCleanup", # extra sysclk cycle after negedge
                      tmo_oe.eq(1),
                      tm0_o_n.eq(0),
                      tm1_o_n.eq(0),
                      ack_o_n.eq(0),
                      NextState("Idle"),
        )

        # connect the write FIFO inputs
        self.comb += [ write_fifo_din.adr.eq(current_adr), # recorded
                       write_fifo_din.data.eq(~ad_i_n), # we do it live, direct from the bus as we use it at the same time we update sampled_ad
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
        ctr = Signal(log2_int(burst_size)) # burst counter
        burst = Signal()
        burst_we = Signal()
        
        data_width = burst_size * 4
        data_width_bits = burst_size * 32
        blk_addr_width = 32 - log2_int(data_width) # 27 for burst_size == 8, 28 for burst_size == 4
        fifo_addr = Signal(blk_addr_width)
        fifo_blk_addr = Signal(blk_addr_width)
        fifo_buffer = Signal(data_width_bits)
        
        tosbus_fifo_dout = Record(soc.tosbus_layout)
        self.comb += tosbus_fifo_dout.raw_bits().eq(tosbus_fifo.dout)
        tosbus_fifo_dout_data_byterev = Signal(data_width_bits)
        tosbus_fifo_dout_bytereversal_stmts = [ tosbus_fifo_dout_data_byterev[k*32+j*8:k*32+j*8+8].eq(tosbus_fifo_dout.data[k*32+32-j*8-8:k*32+32-j*8])  for k in range(burst_size) for j in range(4) ]
        self.comb += tosbus_fifo_dout_bytereversal_stmts
        
        fromsbus_req_fifo_dout = Record(soc.fromsbus_req_layout)
        self.comb += fromsbus_req_fifo_dout.raw_bits().eq(fromsbus_req_fifo.dout)
        
        fromsbus_fifo_din = Record(soc.fromsbus_layout)
        self.comb += fromsbus_fifo.din.eq(fromsbus_fifo_din.raw_bits())

        #self.comb += led0.eq(~dma_fsm.ongoing("Idle"))
        #self.comb += led1.eq(burst)
        
        dma_fsm.act("Reset",
                    NextState("Idle")
        )
        dma_fsm.act("Idle",
                    If(wb_dma.cyc & wb_dma.stb & ~sampled_rqst, # we need the bus and it's not being requested
                       NextValue(burst, 0),
                       If(owning_bus, # we own the bus, skip arbitration
                          NextState("AdrCycle"),
                       ).Else(        # go for arbitration
                           NextState("Arbitration"),
                       ),
                    ).Elif(tosbus_fifo.readable & ~sampled_rqst,
                           NextValue(burst, 1),
                           NextValue(burst_we, 1),
                           NextValue(fifo_addr, tosbus_fifo_dout.address[(32-blk_addr_width):32]),
                           If(owning_bus, # we own the bus, skip arbitration
                              NextState("Burst4AdrCycle"),
                           ).Else(        # go for arbitration
                               NextState("Arbitration"),
                           )
                    ).Elif(fromsbus_req_fifo.readable & fromsbus_fifo.writable & ~sampled_rqst,
                           NextValue(burst, 1),
                           NextValue(burst_we, 0),
                           NextValue(fifo_addr, fromsbus_req_fifo_dout.dmaaddress[(32-blk_addr_width):32]),
                           NextValue(fifo_blk_addr, fromsbus_req_fifo_dout.blkaddress),
                           If(owning_bus, # we own the bus, skip arbitration
                              NextState("Burst4AdrCycle"),
                           ).Else(        # go for arbitration
                               NextState("Arbitration"),
                           )
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
                       If(burst,
                          NextState("Burst4AdrCycle"),
                       ).Else(
                           NextState("AdrCycle"),
                       ),
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
                    NextValue(burst, 0),
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

        if (burst_size == 4):
            handle_ad_for_burst = [
                    ad_o_n[0].eq(1), # burst
                    ad_o_n[1].eq(0), # burst
                    ad_o_n[2].eq(0), # burst  == 4
                    ad_o_n[3].eq(1), # burst  == 4
                    ad_o_n[4:32].eq(~fifo_addr), # adr
            ]
        elif (burst_size == 8):
            handle_ad_for_burst = [
                    ad_o_n[0].eq(1), # burst
                    ad_o_n[1].eq(0), # burst
                    ad_o_n[2].eq(0), # burst  == 8
                    ad_o_n[3].eq(0), # burst  == 8
                    ad_o_n[4].eq(1), # burst  == 8
                    ad_o_n[5:32].eq(~fifo_addr), # adr
            ]
        else:
            raise ValueError(f"Unsupported burst_size {burst_size}")

        dma_fsm.act("Burst4AdrCycle",
                    start_arbitration.eq(0),
                    master_oe.eq(1), # for start
                    tmo_oe.eq(1), # for tm0, tm1, ack
                    ad_oe.eq(1), # for write address
                    start_o_n.eq(0),
                    tm0_o_n.eq(1), # burst
                    tm1_o_n.eq(~burst_we),
                    *handle_ad_for_burst,
                    ack_o_n.eq(1),
                    NextValue(ctr, 0),
                    If(burst_we,
                       NextState("Burst4DatCycleTM0"),
                    ).Else(
                        NextState("Burst4ReadWaitForTM0"),
                    )
        )

        if (burst_size == 4):
            handle_buffer_read_for_burst = [
                Case(ctr, {
                    0x0: NextValue(fifo_buffer[ 0: 32], sampled_ad),
                    0x1: NextValue(fifo_buffer[32: 64], sampled_ad),
                    0x2: NextValue(fifo_buffer[64: 96], sampled_ad),
                    #0x3: NextValue(fifo_buffer[96:128], sampled_ad),
                    #0x0: NextValue(fifo_buffer[ 0: 32], sampled_ad_byterev),
                    #0x1: NextValue(fifo_buffer[32: 64], sampled_ad_byterev),
                    #0x2: NextValue(fifo_buffer[64: 96], sampled_ad_byterev),
                    ##0x3: NextValue(fifo_buffer[96:128], sampled_ad_byterev),
                }),
            ]
            handle_final_buffer_read_for_burst = [
                fromsbus_fifo_din.data.eq(Cat(fifo_buffer[0:96], sampled_ad)), # we use sampled_ad directly for 96:128
            ]
        elif (burst_size == 8):
            handle_buffer_read_for_burst = [
                Case(ctr, {
                    0x0: NextValue(fifo_buffer[  0: 32], sampled_ad),
                    0x1: NextValue(fifo_buffer[ 32: 64], sampled_ad),
                    0x2: NextValue(fifo_buffer[ 64: 96], sampled_ad),
                    0x3: NextValue(fifo_buffer[ 96:128], sampled_ad),
                    0x4: NextValue(fifo_buffer[128:160], sampled_ad),
                    0x5: NextValue(fifo_buffer[160:192], sampled_ad),
                    0x6: NextValue(fifo_buffer[192:224], sampled_ad),
                    #0x7: NextValue(fifo_buffer[224:256], sampled_ad),
                }),
            ]
            handle_final_buffer_read_for_burst = [
                fromsbus_fifo_din.data.eq(Cat(fifo_buffer[0:224], sampled_ad)), # we use sampled_ad directly for 224:256
            ]
        else:
            raise ValueError(f"Unsupported burst_size {burst_size}")
        
        dma_fsm.act("Burst4ReadWaitForTM0",
                    master_oe.eq(1), # for start
                    start_o_n.eq(1), # start finished, but still need to be driven
                    If(sampled_ack, # oups
                       fromsbus_req_fifo.re.eq(1), # remove request to avoid infinite repeat
                       #NextValue(led0, 1),
                       #NextValue(led1, 1),
                       NextState("FinishCycle"),
                    ).Elif(sampled_tm0,
                           *handle_buffer_read_for_burst,
                           NextValue(ctr, ctr + 1),
                           If(ctr == (burst_size - 2), # burst next-to-last
                              NextState("Burst4ReadWaitForAck"),
                           ).Else(
                               NextState("Burst4ReadWaitForTM0"),
                           )
                    )
        )
        dma_fsm.act("Burst4ReadWaitForAck",
                    master_oe.eq(1), # for start
                    start_o_n.eq(1), # start finished, but still need to be driven
                    If(sampled_ack,
                       fromsbus_req_fifo.re.eq(1), # remove request
                       fromsbus_fifo.we.eq(1),
                       fromsbus_fifo_din.blkaddress.eq(fifo_blk_addr),
                       *handle_final_buffer_read_for_burst,
                       # fixme: check status ??? (tm0 and tm1 should be active for no-error)
                       #NextValue(led0, (~sampled_tm0 | ~sampled_tm1)),
                       NextState("FinishCycle"),
                    )
        )


        if (burst_size == 4):
            handle_buffer_write_for_burst = [
                    Case(ctr, {
                        0x0: ad_o_n.eq(~tosbus_fifo_dout.data[ 0: 32]),
                        0x1: ad_o_n.eq(~tosbus_fifo_dout.data[32: 64]),
                        0x2: ad_o_n.eq(~tosbus_fifo_dout.data[64: 96]),
                        ##0x3: ad_o_n.eq(~tosbus_fifo_dout.data[96:128]),
                        #0x0: ad_o_n.eq(~tosbus_fifo_dout_data_byterev[ 0: 32]),
                        #0x1: ad_o_n.eq(~tosbus_fifo_dout_data_byterev[32: 64]),
                        #0x2: ad_o_n.eq(~tosbus_fifo_dout_data_byterev[64: 96]),
                        ##0x3: ad_o_n.eq(~tosbus_fifo_dout_data_byterev[96:128]),
                    }),
            ]
            handle_last_buffer_write_for_burst = [
                ad_o_n.eq(~tosbus_fifo_dout.data[96:128]), # last word
            ]
        elif (burst_size == 8):
            handle_buffer_write_for_burst = [
                    Case(ctr, {
                        0x0: ad_o_n.eq(~tosbus_fifo_dout.data[  0: 32]),
                        0x1: ad_o_n.eq(~tosbus_fifo_dout.data[ 32: 64]),
                        0x2: ad_o_n.eq(~tosbus_fifo_dout.data[ 64: 96]),
                        0x3: ad_o_n.eq(~tosbus_fifo_dout.data[ 96:128]),
                        0x4: ad_o_n.eq(~tosbus_fifo_dout.data[128:160]),
                        0x5: ad_o_n.eq(~tosbus_fifo_dout.data[160:192]),
                        0x6: ad_o_n.eq(~tosbus_fifo_dout.data[192:224]),
                        #0x7: ad_o_n.eq(~tosbus_fifo_dout.data[224:256]),
                    }),
            ]
            handle_last_buffer_write_for_burst = [
                ad_o_n.eq(~tosbus_fifo_dout.data[224:256]), # last word
            ]
        else:
            raise ValueError(f"Unsupported burst_size {burst_size}")
        
        dma_fsm.act("Burst4DatCycleTM0",
                    master_oe.eq(1), # for start
                    ad_oe.eq(1), # for write data
                    start_o_n.eq(1), # start finished, but still need to be driven
                    *handle_buffer_write_for_burst,
                    If(sampled_ack, # oups
                       #NextValue(led0, 1),
                       #NextValue(led1, 1),
                       tosbus_fifo.re.eq(1), # remove FIFO entry to avoid infinite repeat
                       NextState("FinishCycle"),
                    ).Elif(sampled_tm0,
                        NextValue(ctr, ctr + 1),
                       If(ctr == (burst_size - 2), # burst next-to-last
                          NextState("Burst4DatCycleAck"),
                       ).Else(
                           NextState("Burst4DatCycleTM0"),
                       )
                    )
        )
        dma_fsm.act("Burst4DatCycleAck",
                    master_oe.eq(1), # for start
                    ad_oe.eq(1), # for write data
                    start_o_n.eq(1), # start finished, but still need to be driven
                    *handle_last_buffer_write_for_burst,
                    If(sampled_ack,
                       tosbus_fifo.re.eq(1), # remove FIFO entry at last
                       # fixme: check status ??? (tm0 and tm1 should be active for no-error)
                       #NextValue(led0, (~sampled_tm0 | ~sampled_tm1)),
                       NextState("FinishCycle"),
                    )
        )

        #self.comb += [
        #    led0.eq(~dma_fsm.ongoing("Idle")), 
        #    #led1.eq(dma_fsm.ongoing("Burst4DatCycleAck") | dma_fsm.ongoing("Burst4DatCycleTM0") ),
        #    led1.eq(sampled_rqst | wb_dma.cyc),
        #]
        
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

        self.sync += [
            If((~nub_clk &  nub_clk_prev[0]), # simultaneous with setting negedge
               decoded_busy.eq(~decoded_busy & nub_ackn & ~nub_startn # beginning of transaction
			     |  decoded_busy & nub_ackn &  nub_resetn), # hold during cycle
            )
        ]

        
    def add_sources(self, platform):
        # sampling of data on falling edge of clock, done in verilog
        platform.add_source("nubus_sampling.v", "verilog")
