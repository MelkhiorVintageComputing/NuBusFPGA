import os
import math

from migen import *
from migen.genlib.cdc import MultiReg

from litex.soc.interconnect.csr import *
from litex.soc.interconnect import stream
from litex.soc.cores.code_tmds import TMDSEncoder

from litex.build.io import SDROutput, DDROutput

from litex.soc.cores.video import *

video_timing_hwcursor_layout = [
    # Synchronization signals.
    ("hsync", 1),
    ("vsync", 1),
    ("de",    1),
    ("hwcursor", 1),
    ("hwcursorx", 5),
    ("hwcursory", 5),
    # Extended/Optional synchronization signals.
    ("hres",   hbits),
    ("vres",   vbits),
    ("hcount", hbits),
    ("vcount", vbits),
]

# FB Video Timing Generator ---------------------------------------------------------------------------
# Same as the normal one except (a) _enable isn't a CSR

class FBVideoTimingGenerator(Module, AutoCSR):
    def __init__(self, default_video_timings="800x600@60Hz", hwcursor=False):
        # Check / Get Video Timings (can be str or dict)
        if isinstance(default_video_timings, str):
            try:
                self.video_timings = vt = video_timings[default_video_timings]
            except KeyError:
                msg = [f"Video Timings {default_video_timings} not supported, availables:"]
                for video_timing in video_timings.keys():
                    msg.append(f" - {video_timing} / {video_timings[video_timing]['pix_clk']/1e6:3.2f}MHz.")
                raise ValueError("\n".join(msg))
        else:
            self.video_timings = vt = default_video_timings

        # MMAP Control/Status Registers.
        self.enable      = Signal() # external control signal

        self._hres        = CSRStorage(hbits, vt["h_active"])
        self._hsync_start = CSRStorage(hbits, vt["h_active"] + vt["h_sync_offset"])
        self._hsync_end   = CSRStorage(hbits, vt["h_active"] + vt["h_sync_offset"] + vt["h_sync_width"])
        self._hscan       = CSRStorage(hbits, vt["h_active"] + vt["h_blanking"])

        self._vres        = CSRStorage(vbits, vt["v_active"])
        self._vsync_start = CSRStorage(vbits, vt["v_active"] + vt["v_sync_offset"])
        self._vsync_end   = CSRStorage(vbits, vt["v_active"] + vt["v_sync_offset"] + vt["v_sync_width"])
        self._vscan       = CSRStorage(vbits, vt["v_active"] + vt["v_blanking"])

        # Video Timing Source
        if (hwcursor):
            self.source = source = stream.Endpoint(video_timing_hwcursor_layout)
            _hwcursor_x = Signal(12) # 12 out of 16 is enough
            _hwcursor_y = Signal(12) # 12 out of 16 is enough
            self.hwcursor_x = Signal(12)
            self.hwcursor_y = Signal(12)
            self.specials += MultiReg(self.hwcursor_x, _hwcursor_x)
            self.specials += MultiReg(self.hwcursor_y, _hwcursor_y)
        else:
            self.source = source = stream.Endpoint(video_timing_layout)

        # # #

        # Resynchronize Horizontal Timings to Video clock domain.
        self.hres        = hres        = Signal(hbits)
        self.hsync_start = hsync_start = Signal(hbits)
        self.hsync_end   = hsync_end   = Signal(hbits)
        self.hscan       = hscan       = Signal(hbits)
        self.specials += MultiReg(self._hres.storage,        hres)
        self.specials += MultiReg(self._hsync_start.storage, hsync_start)
        self.specials += MultiReg(self._hsync_end.storage,   hsync_end)
        self.specials += MultiReg(self._hscan.storage,       hscan)

        # Resynchronize Vertical Timings to Video clock domain.
        self.vres        = vres        = Signal(vbits)
        self.vsync_start = vsync_start = Signal(vbits)
        self.vsync_end   = vsync_end   = Signal(vbits)
        self.vscan       = vscan       = Signal(vbits)
        self.specials += MultiReg(self._vres.storage,        vres)
        self.specials += MultiReg(self._vsync_start.storage, vsync_start)
        self.specials += MultiReg(self._vsync_end.storage,   vsync_end)
        self.specials += MultiReg(self._vscan.storage,       vscan)

        # Generate timings.
        hactive = Signal()
        vactive = Signal()
        fsm = FSM(reset_state="IDLE")
        fsm = ResetInserter()(fsm)
        self.submodules.fsm = fsm
        self.comb += fsm.reset.eq(~self.enable)
        fsm.act("IDLE",
            NextValue(hactive, 0),
            NextValue(vactive, 0),
            NextValue(source.hres, hres),
            NextValue(source.vres, vres),
            NextValue(source.hcount,  0),
            NextValue(source.vcount,  0),
            NextState("RUN")
        )
        self.comb += source.de.eq(hactive & vactive) # DE when both HActive and VActive.
        self.sync += source.first.eq((source.hcount ==     0) & (source.vcount ==     0)),
        self.sync += source.last.eq( (source.hcount == hscan) & (source.vcount == vscan)),
        fsm.act("RUN",
            source.valid.eq(1),
            If(source.ready,
                # Increment HCount.
                NextValue(source.hcount, source.hcount + 1),
                # Generate HActive / HSync.
                If(source.hcount == 0,           NextValue(hactive,      1)), # Start of HActive.
                If(source.hcount == hres,        NextValue(hactive,      0)), # End of HActive.
                If(source.hcount == hsync_start, NextValue(source.hsync, 1)), # Start of HSync.
                If(source.hcount == hsync_end,   NextValue(source.hsync, 0)), # End of HSync.
                # End of HScan.
                If(source.hcount == hscan,
                    # Reset HCount.
                    NextValue(source.hcount, 0),
                    # Increment VCount.
                    NextValue(source.vcount, source.vcount + 1),
                    # Generate VActive / VSync.
                    If(source.vcount == 0,           NextValue(vactive,      1)), # Start of VActive.
                    If(source.vcount == vres,        NextValue(vactive,      0)), # End of HActive.
                    If(source.vcount == vsync_start, NextValue(source.vsync, 1)), # Start of VSync.
                    If(source.vcount == vsync_end,   NextValue(source.vsync, 0)), # End of VSync.
                    # End of VScan.
                    If(source.vcount == vscan,
                        # Reset VCount.
                        NextValue(source.vcount, 0),
                    )
                )
            )
        )


        if (hwcursor):
            self.sync += source.hwcursor.eq((source.hcount >= _hwcursor_x) &
                                            (source.hcount < (_hwcursor_x+32)) &
                                            (source.vcount >= _hwcursor_y) &
                                            (source.vcount < (_hwcursor_y+32)))
            self.sync += source.hwcursorx.eq(_hwcursor_x - source.hcount)
            self.sync += source.hwcursory.eq(_hwcursor_y - source.vcount)
