from migen import *
from migen.genlib.fifo import *

from litex.soc.interconnect.csr import *
from litex.soc.interconnect import stream
from litex.soc.interconnect import wishbone
from litex.soc.cores.code_tmds import TMDSEncoder

from litex.build.io import SDROutput, DDROutput

from migen.genlib.cdc import MultiReg

from litex.soc.cores.video import *

from fb_video import *

from math import ceil

cmap_layout = [
    ("color", 2),
    ("address", 8),
    ("data", 8),
]
omap_layout = [
    ("color", 2),
    ("address", 2),
    ("data", 8),
]

def goblin_rounded_size(hres, vres):
    mib = int(ceil(((hres * vres) + 0) / 1048576))
    if (mib > 0 and mib < 8): # FIXME : NuBus
        mib = 8
    #if (mib > 0 and mib < 16): # FIXME : SBus
    #    mib = 16
    if (mib > 16 or mib < 1):
        print(f"{mib} mebibytes framebuffer not supported")
        assert(False)
    return int(1048576 * mib)

class VideoFrameBufferMultiDepth(Module, AutoCSR):
    """Video FrameBufferMultiDepth"""
    def __init__(self, dram_port, upd_clut_fifo = None, hres=800, vres=600, base=0x00000000, fifo_depth=65536, clock_domain="sys", clock_faster_than_sys=False, hwcursor=False, upd_overlay_fifo=False, upd_omap_fifo=False, truecolor=True):
        
        print(f"FRAMEBUFFER: dram_port.data_width = {dram_port.data_width}, {hres}x{vres}, 0x{base:x}, in {clock_domain}, clock_faster_than_sys={clock_faster_than_sys}")
        
        vga_sync = getattr(self.sync, clock_domain)
        
        npixels = hres * vres

        # if 0, 32-bits mode
        # should only be changed while in reset
        self.use_indexed = Signal(1, reset = 0x1)
        # mode, as x in 2^x (so 1, 2, 4, 8 bits)
        # should only be changed while in reset
        self.indexed_mode = Signal(2, reset = 0x3)
        self.vblping = Signal(reset = 0)
        
        if (hwcursor):
            self.vtg_sink  = vtg_sink = stream.Endpoint(video_timing_hwcursor_layout)
            upd_omap_fifo_dout = Record(omap_layout)
            self.comb += upd_omap_fifo_dout.raw_bits().eq(upd_omap_fifo.dout)
            overlay = Array(Array(Array(Signal(1) for x in range(0,32)) for y in range(0,32)) for i in range(0, 2))
            omap = Array(Array(Signal(8, reset = (255-i)) for i in range(0, 4)) for j in range(0, 3))
            vga_sync += [
                If(upd_overlay_fifo.readable,
                    upd_overlay_fifo.re.eq(1),
                    [ overlay[upd_overlay_fifo.dout[0]][upd_overlay_fifo.dout[1:6]][x].eq(upd_overlay_fifo.dout[6+x]) for x in range(0, 32)],
                    ).Else(
                        upd_overlay_fifo.re.eq(0),
                    )
            ]
            vga_sync += [
                If(upd_omap_fifo.readable,
                   upd_omap_fifo.re.eq(1),
                   omap[upd_omap_fifo_dout.color][upd_omap_fifo_dout.address].eq(upd_omap_fifo_dout.data),
                ).Else(
                    upd_omap_fifo.re.eq(0),
                )
            ]
        else:
            self.vtg_sink  = vtg_sink = stream.Endpoint(video_timing_layout)


        
        self.source    = source   = stream.Endpoint(video_data_layout)
        self.underflow = Signal()

        #source_buf_ready = Signal()
        source_buf_valid = Signal()
        source_buf_de = Signal()
        source_buf_hsync = Signal()
        source_buf_vsync = Signal()
        data_buf_index = Signal(8)
        data_buf_direct = Array(Signal(8) for x in range(3))
        if (hwcursor):
            hwcursor_buf = Signal()
            hwcursorx_buf = Signal(5)
            hwcursory_buf = Signal(5)
        
        source_buf_b_valid = Signal()
        source_buf_b_de = Signal()
        source_buf_b_hsync = Signal()
        source_buf_b_vsync = Signal()
        data_buf_b_index = Signal(8)
        if (truecolor):
            data_buf_b_direct = Array(Signal(8) for x in range(3))
        if (hwcursor):
            hwcursor_color_idx = Signal(2)
        
        #source_out_ready = Signal()
        source_out_valid = Signal()
        source_out_de = Signal()
        source_out_hsync = Signal()
        source_out_vsync = Signal()
        source_out_r = Signal(8)
        source_out_g = Signal(8)
        source_out_b = Signal(8)
        
        # # #
        # First the Color Look-up Table (for all but 1 bit & 32 bits)
        # updated from the FIFO
        # 8-and-less-than-8-bits mode used the 2^x first entries
        ### clut = Array(Array(Signal(8, reset = (255-i)) for i in range(0, 256)) for j in range(0, 3))
        clut = Array(Array(Signal(8, reset = (255-i)) for j in range(0, 3)) for i in range(0, 256))
        
        upd_clut_fifo_dout = Record(cmap_layout)
        self.comb += upd_clut_fifo_dout.raw_bits().eq(upd_clut_fifo.dout)
        vga_sync += [
                     If(upd_clut_fifo.readable,
                        upd_clut_fifo.re.eq(1),
                        clut[upd_clut_fifo_dout.address][upd_clut_fifo_dout.color].eq(upd_clut_fifo_dout.data),
                        ).Else(
                               upd_clut_fifo.re.eq(0),
                               )
                     ]

        # # #

        # Video DMA.
        from fb_dma import LiteDRAMFBDMAReader
        # length should be changed to match mode
        self.submodules.fb_dma = LiteDRAMFBDMAReader(dram_port,
                                                     fifo_depth     = fifo_depth//(dram_port.data_width//8),
                                                     default_base   = base,
                                                     default_length = npixels)
        ##self.submodules.fb_dma = ResetInserter()(self._fb_dma)
        ##self.fb_dma_reset = Signal(reset = 0)
        ##self.comb += self.fb_dma.reset.eq(self.fb_dma_reset)
        
        # If DRAM Data Width > 8-bit and Video clock is faster than sys_clk:
        # actually always use that case to simplify the design
        # if (dram_port.data_width > 8) and clock_faster_than_sys:
        # Do Clock Domain Crossing first...
        self.submodules.cdc = stream.ClockDomainCrossing([("data", dram_port.data_width)], cd_from="sys", cd_to=clock_domain)
        self.comb += self.fb_dma.source.connect(self.cdc.sink)
        # ... and then Data-Width Conversion.
        # we have 5 possible conversion and mux/connect the appropriate one
        if (truecolor):
            self.submodules.conv32 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 32))
            handle_truecolor_sink = [ self.cdc.source.connect(self.conv32.sink) ]
            handle_truecolor_source = [ source_buf_valid.eq(self.conv32.source.valid),
                                        self.conv32.source.connect(source, keep={"ready"}), ]
            handle_truecolor_databuf = [ data_buf_direct[0].eq(self.conv32.source.data[24:32]),
                                         data_buf_direct[1].eq(self.conv32.source.data[16:24]),
                                         data_buf_direct[2].eq(self.conv32.source.data[8:16]), ]
            handle_truecolor_databuf_b = [ data_buf_b_direct[0].eq(data_buf_direct[0]),
                                           data_buf_b_direct[1].eq(data_buf_direct[1]),
                                           data_buf_b_direct[2].eq(data_buf_direct[2]), ]
            handle_truecolor_source = [ source_out_r.eq(data_buf_b_direct[2]),
                                        source_out_g.eq(data_buf_b_direct[1]),
                                        source_out_b.eq(data_buf_b_direct[0]), ]
        else:
            handle_truecolor_sink = [ ]
            handle_truecolor_source = [ ]
            handle_truecolor_databuf = [ ]
            handle_truecolor_databuf_b = [ ]
            handle_truecolor_source = [ ]
        self.submodules.conv8 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 8))
        self.submodules.conv4 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 4))
        self.submodules.conv2 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 2))
        self.submodules.conv1 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 1))
        self.comb += [
            If(self.use_indexed,
               Case(self.indexed_mode, {
                   0x3: self.cdc.source.connect(self.conv8.sink),
                   0x2: self.cdc.source.connect(self.conv4.sink),
                   0x1: self.cdc.source.connect(self.conv2.sink),
                   0x0: self.cdc.source.connect(self.conv1.sink),
               })
            ).Else(
                *handle_truecolor_sink
            )
        ]
            
        # Video Generation.
        self.comb += [
            vtg_sink.ready.eq(1),
            If(vtg_sink.valid & vtg_sink.de,
               If(self.use_indexed,
                  Case(self.indexed_mode, {
                      0x3: [ source_buf_valid.eq(self.conv8.source.valid),
                             self.conv8.source.connect(source, keep={"ready"}),
                      ],
                      0x2: [ source_buf_valid.eq(self.conv4.source.valid),
                             self.conv4.source.connect(source, keep={"ready"}),
                      ],
                      0x1: [ source_buf_valid.eq(self.conv2.source.valid),
                             self.conv2.source.connect(source, keep={"ready"}),
                      ],
                      0x0: [ source_buf_valid.eq(self.conv1.source.valid),
                             self.conv1.source.connect(source, keep={"ready"}),
                      ],
                  }),
               ).Else(
                   *handle_truecolor_source,
               ),
               vtg_sink.ready.eq(source_buf_valid & source.ready),
            ),
            source_buf_de.eq(vtg_sink.de),
            source_buf_hsync.eq(vtg_sink.hsync),
            source_buf_vsync.eq(vtg_sink.vsync),
            Case(self.indexed_mode, {
                0x3: [ data_buf_index.eq(self.conv8.source.data),
                ],
                0x2: [ data_buf_index.eq(Cat(self.conv4.source.data, Signal(4, reset = 0))),
                ],
                0x1: [ data_buf_index.eq(Cat(self.conv2.source.data, Signal(6, reset = 0))),
                ],
                0x0: [ data_buf_index.eq(Replicate(self.conv1.source.data, 8)),
                ],
            }),
            *handle_truecolor_databuf,
        ]
        if (hwcursor):
            self.comb += [
                hwcursor_buf.eq(vtg_sink.hwcursor),
                hwcursorx_buf.eq(vtg_sink.hwcursorx),
                hwcursory_buf.eq(vtg_sink.hwcursory),
            ]
        vga_sync += [
            source_buf_b_de.eq(source_buf_de),
            source_buf_b_hsync.eq(source_buf_hsync),
            source_buf_b_vsync.eq(source_buf_vsync),
            source_buf_b_valid.eq(source_buf_valid),
            data_buf_b_index.eq(data_buf_index),
            *handle_truecolor_databuf_b,
        ]
        if (hwcursor):
            vga_sync += [
                If(hwcursor_buf,
                   hwcursor_color_idx.eq(Cat(overlay[0][hwcursory_buf][hwcursorx_buf], overlay[1][hwcursory_buf][hwcursorx_buf])),
                ).Else(
                    hwcursor_color_idx.eq(0),
                )
            ]
            
        vga_sync += [
            source_out_de.eq(source_buf_b_de),
            source_out_hsync.eq(source_buf_b_hsync),
            source_out_vsync.eq(source_buf_b_vsync),
            source_out_valid.eq(source_buf_b_valid),
            #source_buf_ready.eq(source_out_ready), # ready flow the other way
        ]
        if (hwcursor):
            vga_sync += [
                If(hwcursor_color_idx != 0,
                   source_out_r.eq(omap[0][hwcursor_color_idx]),
                   source_out_g.eq(omap[1][hwcursor_color_idx]),
                   source_out_b.eq(omap[2][hwcursor_color_idx]),
                ).Elif(source_buf_b_de,
                       If(self.use_indexed,
                          source_out_r.eq(clut[data_buf_b_index][2]),
                          source_out_g.eq(clut[data_buf_b_index][1]),
                          source_out_b.eq(clut[data_buf_b_index][0])
                       ).Else(
                           *handle_truecolor_source,
                       ),
                ).Else(source_out_r.eq(0),
                       source_out_g.eq(0),
                       source_out_b.eq(0)
                )
            ]
        else:
            vga_sync += [
                If(source_buf_b_de,
                       If(self.use_indexed,
                          source_out_r.eq(clut[data_buf_b_index][2]),
                          source_out_g.eq(clut[data_buf_b_index][1]),
                          source_out_b.eq(clut[data_buf_b_index][0])
                       ).Else(
                           *handle_truecolor_source,
                       ),
                ).Else(source_out_r.eq(0),
                       source_out_g.eq(0),
                       source_out_b.eq(0)
                )
            ]
            
        self.comb += [
            source.de.eq(source_out_de),
            source.hsync.eq(source_out_hsync),
            source.vsync.eq(source_out_vsync),
            source.valid.eq(source_out_valid),
            #source_out_ready.eq(source.ready), # ready flow the other way
            source.r.eq(source_out_r),
            source.g.eq(source_out_g),
            source.b.eq(source_out_b),
        ]

        # Underflow.
        self.comb += self.underflow.eq(~source.valid & source.de)
        
        # VBL handling
        # create a pulse in self.vlbping in sys at the end of the frame
        from migen.genlib.cdc import PulseSynchronizer
        old_last = Signal()
        vga_vblping = Signal()
        vga_sync += [
                     old_last.eq(vtg_sink.last),
                     If((vtg_sink.last == 1) & (old_last == 0),
                        vga_vblping.eq(1),
                        ).Else(
                               vga_vblping.eq(0)
                               )
                     ]
        self.submodules.vbl_ps = PulseSynchronizer(idomain = clock_domain, odomain = "sys")
        self.comb += self.vbl_ps.i.eq(vga_vblping)
        self.comb += self.vblping.eq(self.vbl_ps.o)

class goblin(Module, AutoCSR):
    def __init__(self, soc=None, phy=None, timings=None, clock_domain="sys", irq_line=None, endian="big", truecolor=True):
        
        # 2 bits for color (0/r, 1/g, 2/b), 8 for @ and 8 for value
        self.submodules.upd_cmap_fifo = upd_cmap_fifo = ClockDomainsRenamer({"read": clock_domain, "write": "sys"})(AsyncFIFOBuffered(width=layout_len(cmap_layout), depth=8))
        upd_cmap_fifo_din = Record(cmap_layout)
        self.comb += self.upd_cmap_fifo.din.eq(upd_cmap_fifo_din.raw_bits())

        # hw cursor support
        self.submodules.upd_overlay_fifo = upd_overlay_fifo = ClockDomainsRenamer({"read": clock_domain, "write": "sys"})(AsyncFIFOBuffered(width=1+5+32, depth=8))
        self.submodules.upd_omap_fifo = upd_omap_fifo = ClockDomainsRenamer({"read": clock_domain, "write": "sys"})(AsyncFIFOBuffered(width=layout_len(omap_layout), depth=8))
        upd_omap_fifo_din = Record(omap_layout)
        self.comb += self.upd_omap_fifo.din.eq(upd_omap_fifo_din.raw_bits())
        
        name = "video_framebuffer"
        # near duplicate of plaform.add_video_framebuffer
        # Video Timing Generator.
        vtg = FBVideoTimingGenerator(default_video_timings=timings if isinstance(timings, str) else timings[1], hwcursor=True)
        vtg = ClockDomainsRenamer(clock_domain)(vtg)
        setattr(self.submodules, f"{name}_vtg", vtg)
        vtg_enable = Signal(reset = 0)
        #self.specials += MultiReg(vtg_enable, vtg.enable, clock_domain)
        self.comb += [ vtg.enable.eq(vtg_enable) ]

        # Video FrameBuffer.
        timings = timings if isinstance(timings, str) else timings[0]
        base = soc.mem_map.get(name)
        print(f"goblin: visible memory at {base:x}")
        hres = int(timings.split("@")[0].split("x")[0])
        vres = int(timings.split("@")[0].split("x")[1])
        freq = vtg.video_timings["pix_clk"]
        print(f"goblin: using {hres} x {vres}, {freq/1e6} MHz pixclk")
        vfb = VideoFrameBufferMultiDepth(dram_port = soc.sdram.crossbar.get_port(),
                                         upd_clut_fifo = upd_cmap_fifo,
                                         hres = hres,
                                         vres = vres,
                                         base = base,
                                         fifo_depth=(64*1024),
                                         clock_domain = clock_domain,
                                         clock_faster_than_sys = (vtg.video_timings["pix_clk"] > soc.sys_clk_freq),
                                         hwcursor = True,
                                         upd_overlay_fifo = upd_overlay_fifo,
                                         upd_omap_fifo = upd_omap_fifo,
                                         truecolor = truecolor,
        )
        setattr(self.submodules, name, vfb)
        ##dma_reset = Signal(reset = 0)
        ##self.comb += self.video_framebuffer.fb_dma_reset.eq(dma_reset)

        # Connect Video Timing Generator to Video FrameBuffer.
        self.comb += vtg.source.connect(vfb.vtg_sink)

        # Connect Video FrameBuffer to Video PHY.
        self.comb += vfb.source.connect(phy if isinstance(phy, stream.Endpoint) else phy.sink)

        # Constants.
        soc.add_constant("VIDEO_FRAMEBUFFER_BASE", base)
        soc.add_constant("VIDEO_FRAMEBUFFER_HRES", hres)
        soc.add_constant("VIDEO_FRAMEBUFFER_VRES", vres)

        # HW Cursor
        
        hwcursor_x = Signal(12)
        hwcursor_y = Signal(12)

        self.comb += vtg.hwcursor_x.eq(hwcursor_x)
        self.comb += vtg.hwcursor_y.eq(hwcursor_y)

        self.bus = bus = wishbone.Interface()

        # current cmap logic for the goblin, similar to the cg6, minus the HW cursor
        
        bt_mode = Signal(8, reset = 0x3) # bit depth is 2^x ; 0x10 is direct mode (32 bits)
        bt_addr = Signal(8, reset = 0)
        bt_cmap_state = Signal(2, reset = 0)
        m_vbl_disable = Signal(reset = 1)

        videoctrl = Signal()
        
        vbl_signal = Signal(reset = 0)
        self.comb += irq_line.eq(~vbl_signal | m_vbl_disable) # active low

        if (endian == "big"):
            low_byte = slice(0, 8)
            low_bit = slice(0, 1)
        else:
            low_byte = slice(24, 32)
            low_bit = slice(24, 25)
            
        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus.cyc & bus.stb & bus.we & ~bus.ack & upd_cmap_fifo.writable, #write
                            # FIXME: should check for prefix?
                            Case(bus.adr[0:18], {
                                "default": [],
                                # gobofb_mode
                                0x0: [ NextValue(bt_mode, bus.dat_w[low_byte]), ],
                                # set vbl
                                0x1: [ NextValue(m_vbl_disable, ~bus.dat_w[low_bit]), ],
                                # gobofb on/off
                                0x2: [ NextValue(videoctrl, bus.dat_w[low_bit]), ],
                                # clear irq
                                0x3: [ NextValue(vbl_signal, 0), ],
                                # 0x4: rest in SW
                                # gobofb_lut_addr
                                0x5: [ NextValue(bt_addr, bus.dat_w[low_byte]),
                                       NextValue(bt_cmap_state, 0),
                                ],
                                # gobofb_lut
                                0x6: [ upd_cmap_fifo.we.eq(1),
                                           upd_cmap_fifo_din.color.eq(bt_cmap_state),
                                           upd_cmap_fifo_din.address.eq(bt_addr),
                                           upd_cmap_fifo_din.data.eq(bus.dat_w[low_byte]),
                                           Case(bt_cmap_state, {
                                               0: [ NextValue(bt_cmap_state, 1), ],
                                               1: [ NextValue(bt_cmap_state, 2), ],
                                               2: [ NextValue(bt_cmap_state, 0), NextValue(bt_addr, (bt_addr+1) & 0xFF), ],
                                               "default":  NextValue(bt_cmap_state, 0),
                                           }),
                                ],
                                # 0x7: debug in SW
                                # cursor lut
                                0x8: [ upd_omap_fifo.we.eq(1),
                                       upd_omap_fifo_din.color.eq(bt_cmap_state),
                                       upd_omap_fifo_din.address.eq(bt_addr[0:2]),
                                       upd_omap_fifo_din.data.eq(bus.dat_w[low_byte]),
                                       Case(bt_cmap_state, {
                                           0: [ NextValue(bt_cmap_state, 1), ],
                                           1: [ NextValue(bt_cmap_state, 2), ],
                                           2: [ NextValue(bt_cmap_state, 0), NextValue(bt_addr, (bt_addr+1) & 0xFF), ],
                                           "default":  NextValue(bt_cmap_state, 0),
                                       }),
                                ],
                                # hw cursor x/y
                                0x9: [ NextValue(hwcursor_x, bus.dat_w[16:28]), # FIXME: endianess
                                       NextValue(hwcursor_y, bus.dat_w[ 0:12]), # FIXME: endianess
                                ],
                            }),
                            Case(bus.adr[5:18], {
                                "default": [],
                                0x1 : [ upd_overlay_fifo.we.eq(1), # 1*32 = 32..63 / 0x20..0x3F
                                        upd_overlay_fifo.din.eq(Cat(Signal(1, reset = 0), 31-bus.adr[0:5], bus.dat_w)) # FIXME: endianess
                                ],
                                0x2 : [ upd_overlay_fifo.we.eq(1), # 2*32 = 64..95 / 0x40..0x5F
                                        upd_overlay_fifo.din.eq(Cat(Signal(1, reset = 1), 31-bus.adr[0:5], bus.dat_w)) # FIXME: endianess
                                ],
                            }),
                            NextValue(bus.ack, 1),
                         ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack, #read
                                Case(bus.adr[0:18], {
                                    # bt_addr
                                    0x0: [ NextValue(bus.dat_r[low_byte], bt_mode), ],
                                    0x2: [ NextValue(bus.dat_r[low_byte], videoctrl), ],
                                    "default": [ NextValue(bus.dat_r, 0xDEADBEEF)],
                                }),
                                NextValue(bus.ack, 1),
                         ).Else(
                             NextValue(bus.ack, 0),
                         ),
        )
        # mode switch logic
        npixels = hres * vres
        old_bt_mode = Signal(8) # different from bt_mode
        in_reset = Signal()
        post_reset_ctr = Signal(3)
        previous_videoctrl = Signal()

        if (truecolor):
            handle_truecolor_bit = [ self.video_framebuffer.use_indexed.eq(~bt_mode[4:5]) ]
        else:
            handle_truecolor_bit = [ ]
            
        # this has grown complicated and should be a FSM...
        self.sync += [ old_bt_mode.eq(bt_mode),
                       If(old_bt_mode != bt_mode,
                          in_reset.eq(1),
                          videoctrl.eq(0), # start a disabling cycle, or stay disabled
                          previous_videoctrl.eq(videoctrl), # preserve old state for restoration later
                       ),
                       If(in_reset & ~vtg_enable, # we asked for a reset and by now, the VTG has been turned off (or was off) so we reset the DMA and change the parameters
                          ##dma_reset.eq(1), # hpefully this will clear the FIFO as well
                          self.video_framebuffer.indexed_mode.eq(bt_mode[0:2] & ~(Replicate(bt_mode[4:5], 2))),
                          *handle_truecolor_bit,
                          in_reset.eq(0),
                          post_reset_ctr.eq(7),
                       ),
                       ##If(post_reset_ctr == 5, # take DMA out of reset
                       ##   dma_reset.eq(0),
                       ##),
                       If(post_reset_ctr == 4, # now reconfigure the DMA
                          If(bt_mode[4:5],
                             self.video_framebuffer.fb_dma.length.eq(npixels * 4),
                          ).Else(
                              Case(bt_mode[0:2], {
                                  3: self.video_framebuffer.fb_dma.length.eq(npixels   ),
                                  2: self.video_framebuffer.fb_dma.length.eq(npixels//2),
                                  1: self.video_framebuffer.fb_dma.length.eq(npixels//4),
                                  0: self.video_framebuffer.fb_dma.length.eq(npixels//8),
                              }),
                          ),
                       ),
                       If(post_reset_ctr == 1, # we've waited for the mode switch so restore video mode
                          videoctrl.eq(previous_videoctrl),
                       ),
                       If(post_reset_ctr != 0,
                           post_reset_ctr.eq(post_reset_ctr - 1),
                       ),
        ]

        # videoctrl logic
        old_videoctrl = Signal()
        videoctrl_starting = Signal()
        videoctrl_stopping = Signal()
        self.sync += [
            If(~videoctrl_starting & ~videoctrl_stopping, # while we're changing state, delay any new request for change
               old_videoctrl.eq(videoctrl),
            ),
            # turn on
            If(videoctrl & ~old_videoctrl, # pos edge
               self.video_framebuffer.fb_dma.enable.eq(1), # enable DMA
               videoctrl_starting.eq(1),
            ),
            If(videoctrl & (self.video_framebuffer.fb_dma.rsv_level != 0),
               vtg_enable.eq(1), # there's some data requested, good to go
               videoctrl_starting.eq(0),
            ),
            # turn off
            If(~videoctrl & old_videoctrl, # neg edge
               self.video_framebuffer.fb_dma.enable.eq(0), # disable DMA
               videoctrl_stopping.eq(1),
            ),
            If(~videoctrl & (self.video_framebuffer.fb_dma.rsv_level == 0) & (self.video_framebuffer.underflow),
               vtg_enable.eq(0), # the DMA FIFO is purged, stop vtg
               videoctrl_stopping.eq(0),
            ),
            ]
            
        # VBL logic
        self.sync += [
                      If(self.video_framebuffer.vblping == 1,
                         vbl_signal.eq(1),
                         ),]


