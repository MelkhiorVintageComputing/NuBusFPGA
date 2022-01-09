import os
import argparse
from migen import *
from migen.genlib.fifo import *
from migen.fhdl.specials import Tristate

import litex
from litex.build.generic_platform import *
from litex.build.xilinx.vivado import vivado_build_args, vivado_build_argdict
from litex.soc.integration.soc import *
from litex.soc.integration.soc_core import *
from litex.soc.integration.builder import *
from litex.soc.interconnect import wishbone
from litex.soc.cores.clock import *
from litex.soc.cores.led import LedChaser
import ztex213_nubus

import nubus

from litedram.modules import MT41J128M16
from litedram.phy import s7ddrphy

from litedram.frontend.dma import *

from migen.genlib.cdc import BusSynchronizer
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex.soc.cores.video import VideoVGAPHY
import toby_fb

# Wishbone stuff
from sbus_wb import WishboneDomainCrossingMaster
from nubus_mem_wb import NuBus2Wishbone

# CRG ----------------------------------------------------------------------------------------------

class _CRG(Module):
    def __init__(self, platform, sys_clk_freq,
                 toby=False,
                 hdmi=False,
                 pix_clk=0):
        self.clock_domains.cd_sys       = ClockDomain() # 100 MHz PLL, reset'ed by NuBus (via pll), SoC/Wishbone main clock
        self.clock_domains.cd_sys4x     = ClockDomain(reset_less=True)
        self.clock_domains.cd_sys4x_dqs = ClockDomain(reset_less=True)
        self.clock_domains.cd_idelay    = ClockDomain()
        self.clock_domains.cd_native    = ClockDomain(reset_less=True) # 48MHz native, non-reset'ed (for power-on long delay, never reset, we don't want the delay after a warm reset)
        self.clock_domains.cd_nubus      = ClockDomain() # 10 MHz NuBus, reset'ed by NuBus, native NuBus clock domain (25% duty cycle)
        self.clock_domains.cd_nubus90    = ClockDomain() # 20 MHz NuBus90, reset'ed by NuBus, native NuBus90 clock domain (25% duty cycle)
        if (toby):
            if (not hdmi):
                self.clock_domains.cd_vga       = ClockDomain(reset_less=True)
            else:
                self.clock_domains.cd_hdmi      = ClockDomain()
                self.clock_domains.cd_hdmi5x    = ClockDomain()
            

        # # #
        clk48 = platform.request("clk48")
        ###### explanations from betrusted-io/betrusted-soc/betrusted_soc.py
        # Note: below feature cannot be used because Litex appends this *after* platform commands! This causes the generated
        # clock derived constraints immediately below to fail, because .xdc file is parsed in-order, and the main clock needs
        # to be created before the derived clocks. Instead, we use the line afterwards.
        platform.add_platform_command("create_clock -name clk48 -period 20.8333 [get_nets clk48]")
        # The above constraint must strictly proceed the below create_generated_clock constraints in the .XDC file
        # This allows PLLs/MMCMEs to be placed anywhere and reference the input clock
        self.clk48_bufg = Signal()
        self.specials += Instance("BUFG", i_I=clk48, o_O=self.clk48_bufg)
        self.comb += self.cd_native.clk.eq(self.clk48_bufg)                
        #self.cd_native.clk = clk48
        
        clk_nubus = platform.request("clk_3v3_n")
        if (clk_nubus is None):
            print(" ***** ERROR ***** Can't find the NuBus Clock !!!!\n");
            assert(false)
        self.cd_nubus.clk = clk_nubus
        rst_nubus_n = platform.request("reset_3v3_n")
        self.comb += self.cd_nubus.rst.eq(~rst_nubus_n)
        platform.add_platform_command("create_clock -name nubus_clk -period 100.0 -waveform {{0.0 75.0}} [get_ports clk_3v3_n]")
        
        #clk2x_nubus = platform.request("nubus_clk2x_n")
        #if (clk2x_nubus is None):
        #    print(" ***** ERROR ***** Can't find the NuBus90 Clock !!!!\n");
        #    assert(false)
        #self.cd_nubus90.clk = clk2x_nubus
        #self.comb += self.cd_nubus90.rst.eq(~rst_nubus_n)
        #platform.add_platform_command("create_clock -name nubus90_clk -period 50.0  -waveform {{0.0 37.5}} [get_ports nubus_clk2x_n]")

        num_adv = 0
        num_clk = 0

        self.submodules.pll = pll = S7MMCM(speedgrade=platform.speedgrade)
        #pll.register_clkin(clk48, 48e6)
        pll.register_clkin(self.clk48_bufg, 48e6)
        pll.create_clkout(self.cd_sys,       sys_clk_freq)
        platform.add_platform_command("create_generated_clock -name sysclk [get_pins {{{{MMCME2_ADV/CLKOUT{}}}}}]".format(num_clk))
        num_clk = num_clk + 1
        pll.create_clkout(self.cd_sys4x,     4*sys_clk_freq)
        platform.add_platform_command("create_generated_clock -name sys4xclk [get_pins {{{{MMCME2_ADV/CLKOUT{}}}}}]".format(num_clk))
        num_clk = num_clk + 1
        pll.create_clkout(self.cd_sys4x_dqs, 4*sys_clk_freq, phase=90)
        platform.add_platform_command("create_generated_clock -name sys4x90clk [get_pins {{{{MMCME2_ADV/CLKOUT{}}}}}]".format(num_clk))
        num_clk = num_clk + 1
        self.comb += pll.reset.eq(~rst_nubus_n) # | ~por_done 
        platform.add_false_path_constraints(self.cd_native.clk, self.cd_nubus.clk) # FIXME?
        platform.add_false_path_constraints(self.cd_nubus.clk, self.cd_native.clk) # FIXME?
        #platform.add_false_path_constraints(self.cd_sys.clk, self.cd_nubus.clk)
        #platform.add_false_path_constraints(self.cd_nubus.clk, self.cd_sys.clk)
        ##platform.add_false_path_constraints(self.cd_native.clk, self.cd_sys.clk)

        num_adv = num_adv + 1
        num_clk = 0

        self.submodules.pll_idelay = pll_idelay = S7MMCM(speedgrade=platform.speedgrade)
        #pll_idelay.register_clkin(clk48, 48e6)
        pll_idelay.register_clkin(self.clk48_bufg, 48e6)
        pll_idelay.create_clkout(self.cd_idelay, 200e6, margin = 0)
        platform.add_platform_command("create_generated_clock -name idelayclk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
        num_clk = num_clk + 1
        self.comb += pll_idelay.reset.eq(~rst_nubus_n) # | ~por_done
        self.submodules.idelayctrl = S7IDELAYCTRL(self.cd_idelay)
        num_adv = num_adv + 1
        num_clk = 0
        
        if (toby):
            self.submodules.video_pll = video_pll = S7MMCM(speedgrade=platform.speedgrade)
            video_pll.register_clkin(self.clk48_bufg, 48e6)
            if (not hdmi):
                video_pll.create_clkout(self.cd_vga, pix_clk, margin = 0.0005)
                platform.add_platform_command("create_generated_clock -name vga_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
            else:
                video_pll.create_clkout(self.cd_hdmi,   pix_clk, margin = 0.0005)
                video_pll.create_clkout(self.cd_hdmi5x, 5*pix_clk, margin = 0.0005)
                platform.add_platform_command("create_generated_clock -name hdmi_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
                platform.add_platform_command("create_generated_clock -name hdmi5x_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
            self.comb += video_pll.reset.eq(~rst_nubus_n)
            #platform.add_false_path_constraints(self.cd_sys.clk, self.cd_vga.clk)
            platform.add_false_path_constraints(self.cd_sys.clk, video_pll.clkin)
            num_adv = num_adv + 1
            num_clk = 0
                
            
        
class NuBusFPGA(SoCCore):
    def __init__(self, variant, version, sys_clk_freq, toby, hdmi, toby_res, **kwargs):
        print(f"Building NuBusFPGA for board version {version}")
        
        kwargs["cpu_type"] = "None"
        kwargs["integrated_sram_size"] = 0
        kwargs["with_uart"] = False
        kwargs["with_timer"] = False
        
        self.sys_clk_freq = sys_clk_freq
    
        self.platform = platform = ztex213_nubus.Platform(variant = variant, version = version)

        if (toby):
            hres = int(toby_res.split("@")[0].split("x")[0])
            vres = int(toby_res.split("@")[0].split("x")[1])
            toby_fb_size = toby_fb.toby_rounded_size(hres, vres)
            print(f"Reserving {toby_fb_size} bytes ({toby_fb_size//1048576} MiB) for the toby")
        else:
            hres = 0
            vres = 0
            toby_fb_size = 0
            # litex.soc.cores.video.video_timings.update(toby_fb.toby_timings)
        
        SoCCore.__init__(self,
                         platform=platform,
                         sys_clk_freq=sys_clk_freq,
                         clk_freq=sys_clk_freq,
                         csr_paging=0x800, #  default is 0x800
                         **kwargs)

        # Quoting the doc:
        # * Separate address spaces are reserved for processor access to cards in NuBus slots. For a
        # * device in NuBus slot number s, the address space in 32-bit mode begins at address
        # * $Fs00 0000 and continues through the highest address, $FsFF FFFF (where s is a constant in
        # * the range $9 through $E for the Macintosh II, the Macintosh IIx, and the Macintosh IIfx;
        # * $A through $E for the Macintosh Quadra 900; $9 through $B for the Macintosh IIcx;
        # * $C through $E for the Macintosh IIci; $D and $E for the Macintosh Quadra 700; and
        # * $9 for the Macintosh IIsi).
        # So at best we get 16 MiB in 32-bits moden unless using "super slot space"
        # in 24 bits it's only one megabyte,  $s0 0000 through $sF FFFF
        # they are translated: '$s0 0000-$sF FFFF' to '$Fs00 0000-$Fs0F FFFF' (for s in range $9 through $E)
        self.wb_mem_map = wb_mem_map = {
            "toby_mem":          0x00000000, # up to 512 KiB of FB memory
            "csr" :              0x000D0000, # CSR in the middle of the first MB, oups
            "toby_bt" :          0x00080000, # BT for toby just before the ROM, 0x70000 long
            "rom":               0x000FF000, # ROM at the end of the first MB (4 KiB of it ATM)
            "END OF FIRST MB" :  0x000FFFFF,
            "rom1":              0x001FF000, # ROM mirrored
            "rom2":              0x002FF000, # ROM mirrored
            "rom3":              0x003FF000, # ROM mirrored
            "rom4":              0x004FF000, # ROM mirrored
            "rom5":              0x005FF000, # ROM mirrored
            "rom6":              0x006FF000, # ROM mirrored
            "rom7":              0x007FF000, # ROM mirrored
            "rom8":              0x008FF000, # ROM mirrored
            "toby_mem_dupl" :    0x00900000, # replicated FB memory
            "rom9":              0x009FF000, # ROM mirrored
            "roma":              0x00AFF000, # ROM mirrored
            "romb":              0x00BFF000, # ROM mirrored
            "romc":              0x00CFF000, # ROM mirrored
            "romd":              0x00DFF000, # ROM mirrored
            "rome":              0x00EFF000, # ROM mirrored
            "romf":              0x00FFF000, # ROM mirrored
            "END OF SLOT SPACE": 0x00FFFFFF,
            "main_ram":          0x80000000, # not directly reachable from NuBus
            "video_framebuffer": 0x80000000 + 0x10000000 - toby_fb_size, # Updated later
        }
        self.mem_map.update(wb_mem_map)
        self.submodules.crg = _CRG(platform=platform, sys_clk_freq=sys_clk_freq, toby=toby, pix_clk=litex.soc.cores.video.video_timings[toby_res]["pix_clk"])

        ## add our custom timings after the clocks have been defined
        xdc_timings_filename = None;
        #if (version == "V1.0"):
        #    xdc_timings_filename = "/home/dolbeau/nubus-to-ztex-gateware/nubus-to-ztex-timings.xdc"

        if (xdc_timings_filename != None):
            xdc_timings_file = open(xdc_timings_filename)
            xdc_timings_lines = xdc_timings_file.readlines()
            for line in xdc_timings_lines:
                if (line[0:3] == "set"):
                    fix_line = line.strip().replace("{", "{{").replace("}", "}}")
                    #print(fix_line)
                    platform.add_platform_command(fix_line)

        rom_file = "rom_{}.bin".format(version.replace(".", "_"))
        rom_data = soc_core.get_mem_data(rom_file, "big")
        # rom = Array(rom_data)
        #print("\n****************************************\n")
        #for i in range(len(rom)):
        #    print(hex(rom[i]))
        #print("\n****************************************\n")
        self.add_ram("rom", origin=self.mem_map["rom"], size=2**12, contents=rom_data, mode="r") ### FIXME: round up the prom_data size & check for <= 2**12!
        # do we need to mirror the rom in *all* 16 mb ?
        self.bus.add_slave("romf", self.rom.bus, SoCRegion(origin=self.mem_map["romf"], size=2**12, mode="r"))
        #getattr(self,"rom").mem.init = rom_data
        #getattr(self,"rom").mem.depth = 2**16

        avail_sdram = 0
        #self.submodules.ddrphy = s7ddrphy.A7DDRPHY(platform.request("ddram"),
        #                                           memtype        = "DDR3",
        #                                           nphases        = 4,
        #                                           sys_clk_freq   = sys_clk_freq)
        #self.add_sdram("sdram",
        #               phy           = self.ddrphy,
        #               module        = MT41J128M16(sys_clk_freq, "1:4"),
        #               l2_cache_size = 0,
        #)
        #avail_sdram = self.bus.regions["main_ram"].size
        avail_sdram = 256 * 1024 * 1024

        self.submodules.leds = LedChaser(
            pads         = platform.request_all("user_led"),
            sys_clk_freq = sys_clk_freq)
        self.add_csr("leds")

        base_fb = self.wb_mem_map["main_ram"] + avail_sdram - 1048576 # placeholder
        if (toby):
            if (avail_sdram >= toby_fb_size):
                avail_sdram = avail_sdram - toby_fb_size
                base_fb = self.wb_mem_map["main_ram"] + avail_sdram
                self.wb_mem_map["video_framebuffer"] = base_fb
            else:
                print("***** ERROR ***** Can't have a FrameBuffer without main ram\n")
                assert(False)
    
        # don't enable anything on the NuBus side for XX seconds after power up
        # this avoids FPGA initialization messing with the cold boot process
        # requires us to reset the Macintosh afterward so the FPGA board
        # is properly identified
        # This is in the 'native' ClockDomain that is never reset
        #hold_reset_ctr = Signal(30, reset=960000000)
        hold_reset_ctr = Signal(5, reset=31)
        self.sync.native += If(hold_reset_ctr>0, hold_reset_ctr.eq(hold_reset_ctr - 1))
        hold_reset = Signal(reset=1)
        self.comb += hold_reset.eq(~(hold_reset_ctr == 0))
        pad_nubus_oe = platform.request("nubus_oe")
        self.comb += pad_nubus_oe.eq(hold_reset)

        # Interface NuBus to wishbone
        # we need to cross clock domains
        
        wishbone_master_sys = wishbone.Interface(data_width=self.bus.data_width)
        self.submodules.wishbone_master_nubus = WishboneDomainCrossingMaster(platform=self.platform, slave=wishbone_master_sys, cd_master="nubus", cd_slave="sys")
        self.bus.add_master(name="NuBusBridgeToWishbone", master=wishbone_master_sys)
        
        self.submodules.nubus = nubus.NuBus(platform=platform, cd_nubus="nubus")
        self.submodules.nubus2wishbone = ClockDomainsRenamer("nubus")(NuBus2Wishbone(nubus=self.nubus,wb=self.wishbone_master_nubus))

        self.add_ram("ram", origin=self.mem_map["toby_mem"], size=2**16, mode="rw")

        if (toby):
            if (not hdmi):
                self.submodules.videophy = VideoVGAPHY(platform.request("vga"), clock_domain="vga")
                self.submodules.toby = toby_fb.toby(soc=self, phy=self.videophy, timings=toby_res, clock_domain="vga") # clock_domain for the VGA side, toby is running in cd_sys
            else:
                self.submodules.videophy = VideoS7HDMIPHY(platform.request("hdmi"), clock_domain="hdmi")
                self.submodules.toby = toby_fb.toby(soc=self, phy=self.videophy, timings=toby_res, clock_domain="hdmi") # clock_domain for the VGA side, toby is running in cd_sys
            self.bus.add_slave("toby_bt", self.toby.bus, SoCRegion(origin=self.mem_map.get("toby_bt", None), size=0x70000, cached=False))

        
def main():
    parser = argparse.ArgumentParser(description="SbusFPGA")
    parser.add_argument("--build", action="store_true", help="Build bitstream")
    parser.add_argument("--variant", default="ztex2.13a", help="ZTex board variant (default ztex2.13a)")
    parser.add_argument("--version", default="V1.0", help="NuBusFPGA board version (default V1.0)")
    parser.add_argument("--sys-clk-freq", default=100e6, help="NuBusFPGA system clock (default 100e6 = 100 MHz)")
    parser.add_argument("--toby", action="store_true", help="add a toby framebuffer")
    parser.add_argument("--hdmi", action="store_true", help="The framebuffer uses HDMI (default to VGA)")
    parser.add_argument("--toby-res", default="640x480@60Hz", help="Specify the toby resolution")
    builder_args(parser)
    vivado_build_args(parser)
    args = parser.parse_args()
    
    soc = NuBusFPGA(**soc_core_argdict(args),
                    variant=args.variant,
                    version=args.version,
                    sys_clk_freq=int(float(args.sys_clk_freq)),
                    toby=args.toby,
                    hdmi=args.hdmi,
                    toby_res=args.toby_res)

    version_for_filename = args.version.replace(".", "_")

    soc.platform.name += "_" + version_for_filename
    
    builder = Builder(soc, **builder_argdict(args))
    builder.build(**vivado_build_argdict(args), run=args.build)

    # Generate modified CSR registers definitions/access functions to netbsd_csr.h.
    # should be split per-device (and without base) to still work if we have identical devices in different configurations on multiple boards
    # now it is split

    #csr_contents_dict = nubus_to_fpga_export.get_csr_header_split(
    #    regions   = soc.csr_regions,
    #    constants = soc.constants,
    #    csr_base  = soc.mem_regions['csr'].origin)
    #for name in csr_contents_dict.keys():
    #    write_to_file(os.path.join("nubusfpga_csr_{}.h".format(name)), csr_contents_dict[name])
    
    
if __name__ == "__main__":
    main()
