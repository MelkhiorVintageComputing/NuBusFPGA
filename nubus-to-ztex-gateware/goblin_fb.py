from migen import *
from migen.genlib.fifo import *

from litex.soc.interconnect.csr import *
from litex.soc.interconnect import stream
from litex.soc.interconnect import wishbone
from litex.soc.cores.code_tmds import TMDSEncoder

from litex.build.io import SDROutput, DDROutput

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
    if (mib == 3):
        mib = 4
    if (mib > 4 and mib < 8):
        mib = 8
    if (mib > 8 or mib < 1):
        print(f"{mib} mebibytes framebuffer not supported")
        assert(False)
    return int(1048576 * mib)

class VideoFrameBuffer256c(Module, AutoCSR):
    """Video FrameBuffer256c"""
    def __init__(self, dram_port, upd_clut_fifo = None, hres=800, vres=600, base=0x00000000, fifo_depth=65536, clock_domain="sys", clock_faster_than_sys=False):
        
        print(f"FRAMEBUFFER: dram_port.data_width = {dram_port.data_width}, {hres}x{vres}, 0x{base:x}, in {clock_domain}, clock_faster_than_sys={clock_faster_than_sys}")
        
        npixelsdiv8 = hres * vres // 8
        
        # mode, as x in 2^x (so 1, 2, 4, 8 bits)
        # should only be changed while in reset
        self.mode = Signal(2, reset = 3)
        self.vblping = Signal(reset = 0)

        self.vtg_sink  = vtg_sink = stream.Endpoint(video_timing_layout)
        self.source    = source   = stream.Endpoint(video_data_layout)
        self.underflow = Signal()

        #source_buf_ready = Signal()
        source_buf_valid = Signal()
        source_buf_de = Signal()
        source_buf_hsync = Signal()
        source_buf_vsync = Signal()
        data_buf = Signal(8)
        
        #source_out_ready = Signal()
        source_out_valid = Signal()
        source_out_de = Signal()
        source_out_hsync = Signal()
        source_out_vsync = Signal()
        source_out_r = Signal(8)
        source_out_g = Signal(8)
        source_out_b = Signal(8)
        
        # # #
        # First the Color Look-up Table (for all but 1 bit)
        # updated from the FIFO
        # 8-and-less-than-8-bits mode used the 2^x first entries
        clut = Array(Array(Signal(8, reset = (255-i)) for i in range(0, 256)) for j in range(0, 3))
        
        upd_clut_fifo_dout = Record(cmap_layout)
        self.comb += upd_clut_fifo_dout.raw_bits().eq(upd_clut_fifo.dout)
        
        vga_sync = getattr(self.sync, clock_domain)
        vga_sync += [
                     If(upd_clut_fifo.readable,
                        upd_clut_fifo.re.eq(1),
                        clut[upd_clut_fifo_dout.color][upd_clut_fifo_dout.address].eq(upd_clut_fifo_dout.data),
                        ).Else(
                               upd_clut_fifo.re.eq(0),
                               )
                     ]

        # # #

        # Video DMA.
        from fb_dma import LiteDRAMFBDMAReader
        # length should be changed to match mode
        self.submodules.fb_dma = LiteDRAMFBDMAReader(dram_port,
                                                     fifo_depth=fifo_depth//(dram_port.data_width//8),
                                                     default_base   = base,
                                                     default_length = npixelsdiv8 * 8)

        # If DRAM Data Width > 8-bit and Video clock is faster than sys_clk:
        # actually always use that case to simplify the design
        # if (dram_port.data_width > 8) and clock_faster_than_sys:
        # Do Clock Domain Crossing first...
        self.submodules.cdc = stream.ClockDomainCrossing([("data", dram_port.data_width)], cd_from="sys", cd_to=clock_domain)
        self.comb += self.fb_dma.source.connect(self.cdc.sink)
        # ... and then Data-Width Conversion.
        # we have 4 possible conversion and mux/connect the appropriate one
        self.submodules.conv8 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 8))
        self.submodules.conv4 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 4))
        self.submodules.conv2 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 2))
        self.submodules.conv1 = ClockDomainsRenamer({"sys": clock_domain})(stream.Converter(dram_port.data_width, 1))
        self.comb += Case(self.mode, {
                                0x3: self.cdc.source.connect(self.conv8.sink),
                                0x2: self.cdc.source.connect(self.conv4.sink),
                                0x1: self.cdc.source.connect(self.conv2.sink),
                                0x0: self.cdc.source.connect(self.conv1.sink),
                          })
        
        # Video Generation.
        # buffered by 1 cycle to accomodate the look-ups
        self.comb += [
            vtg_sink.ready.eq(1),
            If(vtg_sink.valid & vtg_sink.de,
               Case(self.mode, {
                    0x3: [ source_buf_valid.eq(self.conv8.source.valid),
                           self.conv8.source.connect(source, keep={"ready"}),
                           data_buf.eq(self.conv8.source.data),
                        ],
                    0x2: [ source_buf_valid.eq(self.conv4.source.valid),
                           self.conv4.source.connect(source, keep={"ready"}),
                           data_buf.eq(Cat(self.conv4.source.data, Signal(4, reset = 0))),
                         ],
                    0x1: [ source_buf_valid.eq(self.conv2.source.valid),
                           self.conv2.source.connect(source, keep={"ready"}),
                           data_buf.eq(Cat(self.conv2.source.data, Signal(6, reset = 0))),
                         ],
                    0x0: [ source_buf_valid.eq(self.conv1.source.valid),
                           self.conv1.source.connect(source, keep={"ready"}),
                           data_buf.eq(Replicate(self.conv2.source.data, 8)),
                         ],
                }),
               vtg_sink.ready.eq(source_buf_valid & source.ready),
            ),
            source_buf_de.eq(vtg_sink.de),
            source_buf_hsync.eq(vtg_sink.hsync),
            source_buf_vsync.eq(vtg_sink.vsync),
        ]

        vga_sync += [
                     source_out_de.eq(source_buf_de),
                     source_out_hsync.eq(source_buf_hsync),
                     source_out_vsync.eq(source_buf_vsync),
                     source_out_valid.eq(source_buf_valid),
                     #source_buf_ready.eq(source_out_ready), # ready flow the other way
                     If(source_buf_de,
                        If(self.mode == 0x0,
                           source_out_r.eq(data_buf),
                           source_out_g.eq(data_buf),
                           source_out_b.eq(data_buf)
                          ).Else(
                                 source_out_r.eq(clut[0][data_buf]),
                                 source_out_g.eq(clut[1][data_buf]),
                                 source_out_b.eq(clut[2][data_buf])
                                 )
                        ).Else(source_out_r.eq(0),
                               source_out_g.eq(0),
                               source_out_b.eq(0)
                      ) ]

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
        self.comb += self.underflow.eq(~source.valid)

        # track mode changes
        # in sys cd, not vga cd, as that's where the DMA runs
        # whenever the mode change, we fully reset the DMA
        # (we also need to reset the VTG at the same time)
        old_mode = Signal(2, reset = 3)
        force_reset = Signal(reset = 0)
        finish_reset = Signal(reset = 0)
        old_enable = Signal()
        self.sync += [
                      old_mode.eq(self.mode),
                      If(old_mode != self.mode,
                         force_reset.eq(1),),
                      If(force_reset == 1,
                         old_enable.eq(self.fb_dma.enable),
                         self.fb_dma.enable.eq(0),
                         self.fb_dma.length.eq(npixelsdiv8 << self.mode),
                         force_reset.eq(0),
                         finish_reset.eq(1),),
                      If(finish_reset == 1,
                         self.fb_dma.enable.eq(old_enable),
                         finish_reset.eq(0)),
                      ]

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
    def __init__(self, soc, phy=None, timings = None, clock_domain="sys"):
        
        # 2 bits for color (0/r, 1/g, 2/b), 8 for @ and 8 for value
        self.submodules.upd_cmap_fifo = upd_cmap_fifo = ClockDomainsRenamer({"read": "vga", "write": "sys"})(AsyncFIFOBuffered(width=layout_len(cmap_layout), depth=8))
        upd_cmap_fifo_din = Record(cmap_layout)
        self.comb += self.upd_cmap_fifo.din.eq(upd_cmap_fifo_din.raw_bits())
        
        name = "video_framebuffer"
        # near duplicate of plaform.add_video_framebuffer
        # Video Timing Generator.
        vtg = FBVideoTimingGenerator(default_video_timings=timings if isinstance(timings, str) else timings[1])
        vtg = ClockDomainsRenamer(clock_domain)(vtg)
        setattr(self.submodules, f"{name}_vtg", vtg)

        # Video FrameBuffer.
        timings = timings if isinstance(timings, str) else timings[0]
        base = soc.mem_map.get(name)
        print(f"goblin: visible memory at {base:x}")
        hres = int(timings.split("@")[0].split("x")[0])
        vres = int(timings.split("@")[0].split("x")[1])
        freq = vtg.video_timings["pix_clk"]
        print(f"goblin: using {hres} x {vres}, {freq/1e6} MHz pixclk")
        vfb = VideoFrameBuffer256c(dram_port = soc.sdram.crossbar.get_port(),
                                   upd_clut_fifo = upd_cmap_fifo,
                                   hres = hres,
                                   vres = vres,
                                   base = base,
                                   clock_domain = clock_domain,
                                   clock_faster_than_sys = (vtg.video_timings["pix_clk"] > soc.sys_clk_freq))
        setattr(self.submodules, name, vfb)

        # Connect Video Timing Generator to Video FrameBuffer.
        self.comb += vtg.source.connect(vfb.vtg_sink)

        # Connect Video FrameBuffer to Video PHY.
        self.comb += vfb.source.connect(phy if isinstance(phy, stream.Endpoint) else phy.sink)

        # Constants.
        soc.add_constant("VIDEO_FRAMEBUFFER_BASE", base)
        soc.add_constant("VIDEO_FRAMEBUFFER_HRES", hres)
        soc.add_constant("VIDEO_FRAMEBUFFER_VRES", vres)

        # goblin registers
        # struct bt_regs {
        # 	u_int	bt_addr;		/* map address register */
        # 	u_int	bt_cmap;		/* colormap data register */
        # 	u_int	bt_ctrl;		/* control register */
        # 	u_int	bt_omap;		/* overlay (cursor) map register */
        # };

        self.bus = bus = wishbone.Interface()

        # current cmap logic for the goblin, similar to the cg6, minus the HW cursor
        
        bt_mode = Signal(4, reset = 0) # 0 is 3, 2 is 0, 4 is 1, 8 is 2, and bit depth is 2^
        bt_addr = Signal(8, reset = 0)
        bt_cmap_state = Signal(2, reset = 0)
        m_vbl_disable = Signal(reset = 1)
        
        vbl_signal = Signal(reset = 0)
        vbl_irq = soc.platform.request("nmrq_3v3_n")
        self.comb += vbl_irq.eq(~vbl_signal | m_vbl_disable) # active low
        
        #self.comb += Case(bt_mode, {
        #                  0x0: self.video_framebuffer.mode.eq(3),
        #                  0x2: self.video_framebuffer.mode.eq(0),
        #                  0x4: self.video_framebuffer.mode.eq(1),
        #                  0x8: self.video_framebuffer.mode.eq(2),
        #                  })
        
        self.submodules.wishbone_fsm = wishbone_fsm = FSM(reset_state = "Reset")
        wishbone_fsm.act("Reset",
                         NextValue(bus.ack, 0),
                         NextState("Idle"))
        wishbone_fsm.act("Idle",
                         If(bus.cyc & bus.stb & bus.we & ~bus.ack & upd_cmap_fifo.writable, #write
                            # FIXME: should check for prefix?
                            Case(bus.adr[0:18], {
                                # gobofb_mode
                                0x0: [ NextValue(bt_mode, bus.dat_w[0:8]), ],
                                # gobofb_lut_addr
                                0x5: [ NextValue(bt_addr, bus.dat_w[0:8]),
                                       NextValue(bt_cmap_state, 0),
                                ],
                                # gobofb_lut
                                0x6: [ upd_cmap_fifo.we.eq(1),
                                           upd_cmap_fifo_din.color.eq(bt_cmap_state),
                                           upd_cmap_fifo_din.address.eq(bt_addr),
                                           upd_cmap_fifo_din.data.eq(bus.dat_w[0:8]),
                                           Case(bt_cmap_state, {
                                               0: [ NextValue(bt_cmap_state, 1), ],
                                               1: [ NextValue(bt_cmap_state, 2), ],
                                               2: [ NextValue(bt_cmap_state, 0), NextValue(bt_addr, (bt_addr+1) & 0xFF), ],
                                               "default":  NextValue(bt_cmap_state, 0),
                                           }),
                                ],
                                # set vbl
                                0x1: [ NextValue(m_vbl_disable, ~bus.dat_w[0:1]), ],
                                # clear irq
                                0x3: [ NextValue(vbl_signal, 0), ],
                                "default": [],
                            }),
                            NextValue(bus.ack, 1),
                         ).Elif(bus.cyc & bus.stb & ~bus.we & ~bus.ack, #read
                                Case(bus.adr[0:18], {
                                    # bt_addr
                                    0x0: [ NextValue(bus.dat_r, bt_mode), ],
                                    "default": [ NextValue(bus.dat_r, 0xDEADBEEF)],
                                }),
                                NextValue(bus.ack, 1),
                         ).Else(
                             NextValue(bus.ack, 0),
                         ),
        )
        # mode switch logic
        old_bt_mode = Signal(4)
        vtg_reset_counter = Signal(4, reset = 0) # to put the VTG in reset for a few cyles so that the DMA can restart
        self.sync += [ old_bt_mode.eq(bt_mode),
                      If(old_bt_mode != bt_mode,
                         Case(bt_mode, {
                              0x2: self.video_framebuffer.mode.eq(0),
                              0x4: self.video_framebuffer.mode.eq(1),
                              0x8: self.video_framebuffer.mode.eq(2),
                              0x0: self.video_framebuffer.mode.eq(3),
                              }),
                         vtg_reset_counter.eq(15),
                         vtg._enable.eq(0),),
                      If(vtg_reset_counter == 1,
                         vtg._enable.eq(1),),
                      If(vtg_reset_counter > 0,
                         vtg_reset_counter.eq(vtg_reset_counter - 1),),
                         ]


        # VBL logic
        self.sync += [
                      If(self.video_framebuffer.vblping == 1,
                         vbl_signal.eq(1),
                         ),]

