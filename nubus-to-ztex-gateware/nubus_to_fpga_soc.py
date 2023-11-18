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
import nubus_to_fpga_export

import nubus_full_unified
import nubus_stat

from litedram.modules import MT41J128M16
from litedram.phy import s7ddrphy

from litedram.frontend.dma import *

from liteeth.phy.rmii import LiteEthPHYRMII

from migen.genlib.cdc import BusSynchronizer
from migen.genlib.resetsync import AsyncResetSynchronizer

from litex.soc.cores.video import VideoS7HDMIPHY
from litex.soc.cores.video import VideoVGAPHY
from litex.soc.cores.video import video_timings
from VintageBusFPGA_Common.goblin_accel import *

# Wishbone stuff
from VintageBusFPGA_Common.cdc_wb import WishboneDomainCrossingMaster
from VintageBusFPGA_Common.fpga_blk_dma import *
from VintageBusFPGA_Common.fpga_sd_dma import *
from VintageBusFPGA_Common.MacPeriphSoC import *

from nubus_mem_wb import NuBus2Wishbone
from nubus_memfifo_wb import NuBus2WishboneFIFO
from nubus_cpu_wb import Wishbone2NuBus

# CRG ----------------------------------------------------------------------------------------------
class _CRG(Module):
    def __init__(self, platform, version, sys_clk_freq,
                 goblin=False,
                 hdmi=False,
                 pix_clk=0,
                 ethernet=False):
        self.clock_domains.cd_sys       = ClockDomain() # 100 MHz PLL, reset'ed by NuBus (via pll), SoC/Wishbone main clock
        self.clock_domains.cd_sys4x     = ClockDomain(reset_less=True)
        self.clock_domains.cd_sys4x_dqs = ClockDomain(reset_less=True)
        self.clock_domains.cd_idelay    = ClockDomain()
        self.clock_domains.cd_native    = ClockDomain(reset_less=True) # 48MHz native, non-reset'ed (for power-on long delay, never reset, we don't want the delay after a warm reset)
        self.clock_domains.cd_nubus      = ClockDomain() # 10 MHz NuBus, reset'ed by NuBus, native NuBus clock domain (25% duty cycle)
        self.clock_domains.cd_nubus90    = ClockDomain() # 20 MHz NuBus90, reset'ed by NuBus, native NuBus90 clock domain (25% duty cycle)
        if (goblin):
            if (not hdmi):
                self.clock_domains.cd_vga       = ClockDomain(reset_less=True)
            else:
                self.clock_domains.cd_hdmi      = ClockDomain()
                self.clock_domains.cd_hdmi5x    = ClockDomain()
        if (ethernet):
            self.clock_domains.cd_eth = ClockDomain()


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

        ##### V1.2 extra clock for B34
        if (version == "V1.2"):
            self.clock_domains.cd_bank34      = ClockDomain()
            clk54 = platform.request("clk54")
            platform.add_platform_command("create_clock -name clk54 -period 18.51851851851851851 [get_nets clk54]")
            self.clk54_bufg = Signal()
            self.specials += Instance("BUFG", i_I=clk54, o_O=self.clk54_bufg)
            self.comb += self.cd_bank34.clk.eq(self.clk54_bufg)     
        else:
            clk54 = None
            
        
        clk_nubus = platform.request("clk_3v3_n")
        if (clk_nubus is None):
            print(" ***** ERROR ***** Can't find the NuBus Clock !!!!\n");
            assert(false)
        self.cd_nubus.clk = clk_nubus
        rst_nubus_n = platform.request("reset_3v3_n")
        self.comb += self.cd_nubus.rst.eq(~rst_nubus_n)
        platform.add_platform_command("create_clock -name nubus_clk -period 100.0 -waveform {{0.0 75.0}} [get_ports clk_3v3_n]")
        
        clk2x_nubus = platform.request("clk2x_3v3_n")
        if (clk2x_nubus is None):
            print(" ***** ERROR ***** Can't find the NuBus90 Clock !!!!\n");
            assert(false)
        self.cd_nubus90.clk = clk2x_nubus
        self.comb += self.cd_nubus90.rst.eq(~rst_nubus_n)
        platform.add_platform_command("create_clock -name nubus90_clk -period 50.0  -waveform {{0.0 37.5}} [get_ports clk2x_3v3_n]")

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
        if (ethernet):
            pll.create_clkout(self.cd_eth, 50e6, phase=90) # fixme: what if sys_clk_feq != 100e6?
            platform.add_platform_command("create_generated_clock -name ethclk [get_pins {{{{MMCME2_ADV/CLKOUT{}}}}}]".format(num_clk))
            num_clk = num_clk + 1

        self.comb += pll.reset.eq(~rst_nubus_n) # | ~por_done 
        platform.add_false_path_constraints(clk48, self.cd_nubus.clk) # FIXME?
        platform.add_false_path_constraints(self.cd_nubus.clk, clk48) # FIXME?
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
        
        if (goblin):
            self.submodules.video_pll = video_pll = S7MMCM(speedgrade=platform.speedgrade)
            if (clk54 is None):
                # no 54 MHz clock, drive hdmi from the main clock
                video_pll.register_clkin(self.clk48_bufg, 48e6)
            else:
                # drive hdmi from the 54 MHz clock, easier to generate e.g. 148.5 MHz
                video_pll.register_clkin(self.clk54_bufg, 54e6)
                platform.add_false_path_constraints(self.cd_bank34.clk, self.cd_nubus.clk) # FIXME?
                platform.add_false_path_constraints(self.cd_bank34.clk, clk48) # FIXME?
                
            if (not hdmi):
                video_pll.create_clkout(self.cd_vga, pix_clk, margin = 0.0005)
                platform.add_platform_command("create_generated_clock -name vga_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
            else:
                video_pll.create_clkout(self.cd_hdmi,   pix_clk, margin = 0.005)
                video_pll.create_clkout(self.cd_hdmi5x, 5*pix_clk, margin = 0.005)
                platform.add_platform_command("create_generated_clock -name hdmi_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
                platform.add_platform_command("create_generated_clock -name hdmi5x_clk [get_pins {{{{MMCME2_ADV_{}/CLKOUT{}}}}}]".format(num_adv, num_clk))
                num_clk = num_clk + 1
                
            self.comb += video_pll.reset.eq(~rst_nubus_n)
            #platform.add_false_path_constraints(self.cd_sys.clk, self.cd_vga.clk)
            platform.add_false_path_constraints(self.cd_sys.clk, video_pll.clkin)
            num_adv = num_adv + 1
            num_clk = 0
                
            
        
class NuBusFPGA(MacPeriphSoC):
    def __init__(self, variant, version, sys_clk_freq, goblin, hdmi, goblin_res, sdcard, flash, config_flash, ethernet, **kwargs):
        print(f"Building NuBusFPGA for board version {version}")
        
        self.platform = platform = ztex213_nubus.Platform(variant = variant, version = version)
            
        if (flash and (version == "V1.2")):
            platform.add_extension(ztex213_nubus._flashtemp_pmod_io_v1_2)

        if (ethernet and (version == "V1.2")):
            platform.add_extension(ztex213_nubus._rmii_eth_extpmod_io_v1_2)

        use_goblin_alt = True
        
        MacPeriphSoC.__init__(self,
                              platform=platform,
                              sys_clk_freq=sys_clk_freq,
                              csr_paging=0x800, #  default is 0x800
                              bus_interconnect = "crossbar",
                              goblin = goblin,
                              hdmi = hdmi,
                              goblin_res = goblin_res,
                              use_goblin_alt = use_goblin_alt,
                              **kwargs)

        self.mem_map.update(self.wb_mem_map)
        
        self.submodules.crg = _CRG(platform=platform, version=version, sys_clk_freq=sys_clk_freq, goblin=goblin, hdmi=hdmi, pix_clk=litex.soc.cores.video.video_timings[goblin_res]["pix_clk"], ethernet=ethernet)

        ## add our custom timings after the clocks have been defined
        xdc_timings_filename = None;
        #if (version == "V1.0"):
        #    xdc_timings_filename = "/home/dolbeau/nubus-to-ztex-gateware/nubus_fpga_V1_0_timings.xdc"
        if (version == "V1.2"):
            xdc_timings_filename = "nubus_fpga_V1_2_timings.xdc"

        if (xdc_timings_filename != None):
            xdc_timings_file = open(xdc_timings_filename)
            
            xdc_timings_lines = xdc_timings_file.readlines()
            for line in xdc_timings_lines:
                if (line[0:3] == "set"):
                    fix_line = line.strip().replace("{", "{{").replace("}", "}}")
                    #print(fix_line)
                    platform.add_platform_command(fix_line)

        MacPeriphSoC.add_rom(self, version = version, flash = flash, config_flash = config_flash)
            
        #from wb_test import WA2D
        #self.submodules.wa2d = WA2D(self.platform)
        #self.bus.add_slave("WA2D", self.wa2d.bus, SoCRegion(origin=0x00C00000, size=0x00400000, cached=False))

        # notsimul to signify we're making a real bitstream
        # notsimul == False only to produce a verilog implementation to simulate the bus side of things
        notsimul = True
        if (notsimul):
            avail_sdram = 0
            self.submodules.ddrphy = s7ddrphy.A7DDRPHY(platform.request("ddram"),
                                                       memtype        = "DDR3",
                                                       nphases        = 4,
                                                       sys_clk_freq   = sys_clk_freq)
            self.add_sdram("sdram",
                           phy           = self.ddrphy,
                           module        = MT41J128M16(sys_clk_freq, "1:4"),
                           l2_cache_size = 0,
            )
            avail_sdram = self.bus.regions["main_ram"].size
            #from sdram_init import DDR3FBInit
            #self.submodules.sdram_init = DDR3FBInit(sys_clk_freq=sys_clk_freq, bitslip=1, delay=25)
            #self.bus.add_master(name="DDR3Init", master=self.sdram_init.bus)
        else:
            avail_sdram = 256 * 1024 * 1024
            self.add_ram("ram", origin=0x8f800000, size=2**16, mode="rw")

        if (not notsimul): # otherwise we have no CSRs and litex doesn't like that
            self.submodules.leds = ClockDomainsRenamer("nubus")(LedChaser(
                pads         = platform.request_all("user_led"),
                sys_clk_freq = 10e6))
            self.add_csr("leds")

        base_fb = self.wb_mem_map["main_ram"] + avail_sdram - 1048576 # placeholder
        if (goblin):
            if (avail_sdram >= self.goblin_fb_size):
                avail_sdram = avail_sdram - self.goblin_fb_size
                base_fb = self.wb_mem_map["main_ram"] + avail_sdram
                self.wb_mem_map["video_framebuffer"] = base_fb
                print(f"FrameBuffer base_fb @ {base_fb:x}")
            else:
                print("***** ERROR ***** Can't have a FrameBuffer without main ram\n")
                assert(False)
    
        # don't enable anything on the NuBus side for XX seconds after power up
        # this avoids FPGA initialization messing with the cold boot process
        # requires us to reset the Macintosh afterward so the FPGA board
        # is properly identified
        # This is in the 'native' ClockDomain that is never reset
        # not needed, FPGA initializes fast enough, works on cold boots
        #hold_reset_ctr = Signal(30, reset=960000000)
        hold_reset_ctr = Signal(5, reset=31)
        self.sync.native += If(hold_reset_ctr>0, hold_reset_ctr.eq(hold_reset_ctr - 1))
        self.hold_reset = hold_reset = Signal() # in reset if high, out-of-reset if low
        self.comb += hold_reset.eq(~(hold_reset_ctr == 0))
        pad_nubus_oe = platform.request("nubus_oe")
        self.comb += pad_nubus_oe.eq(hold_reset)
        #pad_user_led_0 = platform.request("user_led", 0)
        #self.comb += pad_user_led_0.eq(~hold_reset)

        # Interface NuBus to wishbone
        # we need to cross clock domains

        # Xibus is the original VErilog implementation I used
        # mostly only for testing now, it doesn't have block mode so doesn't support the DMA mode of the RAM disk
        # Should be set to False unless for testing (usually with notsimul=False)
        xibus=False
        if (xibus):
            wishbone_master_sys = wishbone.Interface(data_width=self.bus.data_width)
            self.submodules.wishbone_master_nubus = WishboneDomainCrossingMaster(platform=self.platform, slave=wishbone_master_sys, cd_master="nubus", cd_slave="sys")
            self.bus.add_master(name="NuBusBridgeToWishbone", master=wishbone_master_sys)
            if (version == "V1.0"):
                from nubus_V1_0 import NuBus
            elif (version == "V1.2"):
                from nubus_V1_2 import NuBus
            self.submodules.nubus = NuBus(platform=platform, cd_nubus="nubus")
            #self.submodules.nubus2wishbone = ClockDomainsRenamer("nubus")(NuBus2Wishbone(nubus=self.nubus,wb=self.wishbone_master_nubus))
            if (version == "V1.2"):
                self.comb += self.nubus.nubus_oe.eq(hold_reset) # improveme
            nubus_writemaster_sys = wishbone.Interface(data_width=self.bus.data_width)
            self.submodules.nubus2wishbone = NuBus2WishboneFIFO(platform=self.platform,nubus=self.nubus,wb_read=self.wishbone_master_nubus,wb_write=nubus_writemaster_sys)
            self.bus.add_master(name="NuBusBridgeToWishboneWrite", master=nubus_writemaster_sys)
            
            wishbone_slave_nubus = wishbone.Interface(data_width=self.bus.data_width)
            self.submodules.wishbone2nubus = ClockDomainsRenamer("nubus")(Wishbone2NuBus(nubus=self.nubus,wb=wishbone_slave_nubus))
            self.submodules.wishbone_slave_sys = WishboneDomainCrossingMaster(platform=self.platform, slave=wishbone_slave_nubus, cd_master="sys", cd_slave="nubus")
            self.bus.add_slave("DMA", self.wishbone_slave_sys, SoCRegion(origin=self.mem_map.get("master", None), size=0x40000000, cached=False))
            
            irq_line = self.platform.request("nmrq_3v3_n") # active low
            fb_irq = Signal() # active low
            #led0 = platform.request("user_led", 0)
            #self.comb += [
            #    led0.eq(~fb_irq),
            #]
            self.comb += irq_line.eq(fb_irq) # active low, enable if one is low
        else:
            # details for usesampling in the NuBus python object
            usesampling = False
            wishbone_master_sys = wishbone.Interface(data_width=self.bus.data_width)
            if (not usesampling): # we need an extra CDC
                self.submodules.wishbone_master_nubus = WishboneDomainCrossingMaster(platform=self.platform, slave=wishbone_master_sys, cd_master="nubus", cd_slave="sys") # for non-sampling only
            nubus_writemaster_sys = wishbone.Interface(data_width=self.bus.data_width)
            wishbone_slave_nubus = wishbone.Interface(data_width=self.bus.data_width)
            self.submodules.wishbone_slave_sys = WishboneDomainCrossingMaster(platform=self.platform, slave=wishbone_slave_nubus, cd_master="sys", cd_slave="nubus", force_delay=9) # force delay needed to avoid back-to-back transaction running into issue https://github.com/alexforencich/verilog-wishbone/issues/4
            #led0 = platform.request("user_led", 0)
            #led1 = platform.request("user_led", 1)
            #self.comb += [ led0.eq(self.wishbone_slave_sys.stb),
            #               led1.eq(self.wishbone_slave_sys.cyc), ]
            
            burst_size=4
            
            data_width = burst_size * 4
            data_width_bits = burst_size * 32
            blk_addr_width = 32 - log2_int(data_width)
            
            self.tosbus_layout = [
                ("address", 32),
                ("data", data_width_bits),
            ]
            self.fromsbus_layout = [
                ("blkaddress", blk_addr_width),
                ("data", data_width_bits),
            ]
            self.fromsbus_req_layout = [
                ("blkaddress", blk_addr_width),
                ("dmaaddress", 32),
            ]
        

            irq_line = self.platform.request("nmrq_3v3_n") # active low
            fb_irq = Signal(reset = 1) # active low
            dma_irq = Signal(reset = 1) # active low
            audio_irq = Signal(reset = 1) # active low
            #led0 = platform.request("user_led", 0)
            #led1 = platform.request("user_led", 1)
            #self.comb += [
            #    led0.eq(~fb_irq),
            #    led1.eq(~dma_irq),
            #]

            self.comb += irq_line.eq(fb_irq & dma_irq & audio_irq) # active low, enable if one is low

            
            self.submodules.tosbus_fifo = ClockDomainsRenamer({"read": "nubus", "write": "sys"})(AsyncFIFOBuffered(width=layout_len(self.tosbus_layout), depth=1024//data_width))
            self.submodules.fromsbus_fifo = ClockDomainsRenamer({"write": "nubus", "read": "sys"})(AsyncFIFOBuffered(width=layout_len(self.fromsbus_layout), depth=512//data_width))
            self.submodules.fromsbus_req_fifo = ClockDomainsRenamer({"read": "nubus", "write": "sys"})(AsyncFIFOBuffered(width=layout_len(self.fromsbus_req_layout), depth=512//data_width))

            #if (not sdcard): # fixme: temporay exclusion
            self.submodules.exchange_with_mem = ExchangeWithMem(soc=self,
                                                                platform=platform,
                                                                tosbus_fifo=self.tosbus_fifo,
                                                                fromsbus_fifo=self.fromsbus_fifo,
                                                                fromsbus_req_fifo=self.fromsbus_req_fifo,
                                                                dram_native_r=self.sdram.crossbar.get_port(mode="read", data_width=data_width_bits),
                                                                dram_native_w=self.sdram.crossbar.get_port(mode="write", data_width=data_width_bits),
                                                                mem_size=avail_sdram//1048576,
                                                                burst_size=burst_size,
                                                                do_checksum = False,
                                                                clock_domain="nubus")
            self.comb += dma_irq.eq(self.exchange_with_mem.irq)
            #else:
            #    self.add_sdcard_custom()
            #    self.submodules.exchange_with_sd = ExchangeWithSD(soc=self,
            #                                                    platform=platform,
            #                                                    tosbus_fifo=self.tosbus_fifo,
            #                                                    fromsbus_fifo=self.fromsbus_fifo,
            #                                                    fromsbus_req_fifo=self.fromsbus_req_fifo,
            #                                                       sd_source=self.sdcore.source,
            #                                                       sd_sink=self.sdcore.sink,
            #                                                    burst_size=burst_size,
            #                                                    clock_domain="nubus")
            #    self.comb += dma_irq.eq(self.exchange_with_sd.irq)
                

            self.submodules.nubus = nubus_full_unified.NuBus(soc=self,
                                                             version=version,
                                                             burst_size=burst_size,
                                                             tosbus_fifo=self.tosbus_fifo,
                                                             fromsbus_fifo=self.fromsbus_fifo,
                                                             fromsbus_req_fifo=self.fromsbus_req_fifo,
                                                             wb_read=(wishbone_master_sys if usesampling else self.wishbone_master_nubus), # CDC or not
                                                             wb_write=nubus_writemaster_sys,
                                                             wb_dma=wishbone_slave_nubus,
                                                             usesampling=usesampling,
                                                             cd_nubus="nubus")
            
            self.bus.add_master(name="NuBusBridgeToWishbone", master=wishbone_master_sys)
            self.bus.add_slave("DMA", self.wishbone_slave_sys, SoCRegion(origin=self.mem_map.get("master", None), size=0x40000000, cached=False))
            self.bus.add_master(name="NuBusBridgeToWishboneWrite", master=nubus_writemaster_sys)

            self.submodules.stat = nubus_stat.NuBusStat(nubus=self.nubus, platform=platform)
            self.bus.add_slave("Stat", self.stat.bus_slv, SoCRegion(origin=self.mem_map.get("stat", None), size=0x1000, cached=False))
            
        if (goblin):
            if ((not use_goblin_alt) or (not hdmi)):
                from VintageBusFPGA_Common.goblin_fb import goblin_rounded_size, Goblin
            else:
                from VintageBusFPGA_Common.goblin_alt_fb import goblin_rounded_size, GoblinAlt
                
            if (not hdmi):
                self.submodules.videophy = VideoVGAPHY(platform.request("vga"), clock_domain="vga")
                self.submodules.goblin = Goblin(soc=self, phy=self.videophy, timings=goblin_res, clock_domain="vga", irq_line=fb_irq, endian="little", hwcursor=False, truecolor=True) # clock_domain for the VGA side, goblin is running in cd_sys
            else:
                if (not use_goblin_alt):
                    self.submodules.videophy = VideoS7HDMIPHY(platform.request("hdmi"), clock_domain="hdmi")
                    self.submodules.goblin = Goblin(soc=self, phy=self.videophy, timings=goblin_res, clock_domain="hdmi", irq_line=fb_irq, endian="little", hwcursor=False, truecolor=True) # clock_domain for the HDMI side, goblin is running in cd_sys
                else:
                    # GoblinAlt contains its own PHY
                    self.submodules.goblin = GoblinAlt(soc=self, timings=goblin_res, clock_domain="hdmi", irq_line=fb_irq, endian="little", hwcursor=False, truecolor=True)
                    # it also has a bus master so that the audio bit can fetch data from Wishbone
                    self.bus.add_master(name="GoblinAudio", master=self.goblin.goblin_audio.busmaster)
                    self.add_ram("goblin_audio_ram", origin=self.mem_map["goblin_audio_ram"], size=2**13, mode="rw") # 8 KiB buffer, planned as 2*4KiB
                    self.comb += [ audio_irq.eq(self.goblin.goblin_audio.irq), ]
                    
            self.bus.add_slave("goblin_bt", self.goblin.bus, SoCRegion(origin=self.mem_map.get("goblin_bt", None), size=0x1000, cached=False))
            #pad_user_led_0 = platform.request("user_led", 0)
            #pad_user_led_1 = platform.request("user_led", 1)
            #self.comb += pad_user_led_0.eq(self.goblin.video_framebuffer.underflow)
            #self.comb += pad_user_led_1.eq(self.goblin.video_framebuffer.fb_dma.enable)
            if (True):
                self.submodules.goblin_accel = GoblinAccelNuBus(soc = self)
                self.bus.add_slave("goblin_accel", self.goblin_accel.bus, SoCRegion(origin=self.mem_map.get("goblin_accel", None), size=0x1000, cached=False))
                self.bus.add_master(name="goblin_accel_r5_i", master=self.goblin_accel.ibus)
                self.bus.add_master(name="goblin_accel_r5_d", master=self.goblin_accel.dbus)
                goblin_rom_file = "VintageBusFPGA_Common/blit_goblin_nubus.raw"
                goblin_rom_data = soc_core.get_mem_data(filename_or_regions=goblin_rom_file, endianness="little")
                goblin_rom_len = 4*len(goblin_rom_data);
                rounded_goblin_rom_len = 2**log2_int(goblin_rom_len, False)
                print(f"GOBLIN ROM is {goblin_rom_len} bytes, using {rounded_goblin_rom_len}")
                assert(rounded_goblin_rom_len <= 2**16)
                self.add_ram("goblin_accel_rom", origin=self.mem_map["goblin_accel_rom"], size=rounded_goblin_rom_len, contents=goblin_rom_data, mode="r")
                self.add_ram("goblin_accel_ram", origin=self.mem_map["goblin_accel_ram"], size=2**12, mode="rw")

        if (sdcard):
            self.add_sdcard()
            # irq?
        
        if (ethernet): ### WIP WIP WIP WIP
            # we need the CRG to provide the cd_eth clock: "use refclk_cd as RMII reference clock (provided by user design) (no external clock).
            self.ethphy = LiteEthPHYRMII(
                clock_pads = self.platform.request("eth_clocks"),
                pads       = self.platform.request("eth"))
            self.add_ethernet(phy=self.ethphy, data_width = 32)
            print(f"%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% {self.ethmac.interface.sram.ev.irq}") # FIXME HANDLEME

            from mdio import MDIOCtrl
            self.submodules.mdio_ctrl = MDIOCtrl(platform=platform)


        # for testing
        if (False):
            from nubus_master_tst import PingMaster
            self.submodules.pingmaster = PingMaster(nubus=self.nubus, platform=self.platform)
            self.bus.add_slave("pingmaster_slv", self.pingmaster.bus_slv, SoCRegion(origin=self.mem_map.get("pingmaster", None), size=0x010, cached=False))
            self.bus.add_master(name="pingmaster_mst", master=self.pingmaster.bus_mst)
        
def main():
    parser = argparse.ArgumentParser(description="NuBusFPGA")
    parser.add_argument("--build", action="store_true", help="Build bitstream")
    parser.add_argument("--variant", default="ztex2.13a", help="ZTex board variant (default ztex2.13a)")
    parser.add_argument("--version", default="V1.0", help="NuBusFPGA board version (default V1.0)")
    parser.add_argument("--sys-clk-freq", default=100e6, help="NuBusFPGA system clock (default 100e6 = 100 MHz)")
    parser.add_argument("--goblin", action="store_true", help="add a goblin framebuffer")
    parser.add_argument("--hdmi", action="store_true", help="The framebuffer uses HDMI (default to VGA, required for V1.2)")
    parser.add_argument("--goblin-res", default="640x480@60Hz", help="Specify the goblin resolution")
    parser.add_argument("--sdcard", action="store_true", help="add a sdcard controller (V1.2 only)")
    parser.add_argument("--flash", action="store_true", help="add a Flash device [V1.2+FLASHTEMP PMod] and configure the ROM to it")
    parser.add_argument("--config-flash", action="store_true", help="Configure the ROM to the internal Flash used for FPGA config")
    parser.add_argument("--ethernet", action="store_true", help="Add Ethernet (V1.2 w/ custom PMod only)")
    builder_args(parser)
    vivado_build_args(parser)
    args = parser.parse_args()

    if (args.sdcard and (args.version == "V1.0")):
        print(" ***** ERROR ***** : Ethernet not supported on V1.0\n");
        assert(False)
        
    if (args.flash and (args.version == "V1.0")):
        print(" ***** ERROR ***** : Flash not supported on V1.0\n");
        assert(False)
        
    if (args.ethernet and (args.version == "V1.0")):
        print(" ***** ERROR ***** : Ethernet not supported on V1.0\n");
        assert(False)
        
    if (args.ethernet and args.flash):
        print(" ***** ERROR ***** : Only one PMod usable on V1.2\n");
        assert(False)
            
    if ((not args.hdmi) and (args.version == "V1.2")):
        print(" ***** ERROR ***** : VGA not supported on V1.2\n");
        assert(False)
        
    if (args.config_flash and args.flash):
        print(" ***** ERROR ***** : ROM-in-Flash can only use config OR PMod, not both\n");
        assert(False)
    
    soc = NuBusFPGA(**soc_core_argdict(args),
                    variant=args.variant,
                    version=args.version,
                    sys_clk_freq=int(float(args.sys_clk_freq)),
                    goblin=args.goblin,
                    hdmi=args.hdmi,
                    goblin_res=args.goblin_res,
                    sdcard=args.sdcard,
                    flash=args.flash,
                    config_flash=args.config_flash,
                    ethernet=args.ethernet)

    version_for_filename = args.version.replace(".", "_")

    soc.platform.name += "_" + version_for_filename
    
    builder = Builder(soc, **builder_argdict(args))
    builder.build(**vivado_build_argdict(args), run=args.build)

    # Generate modified CSR registers definitions/access functions to netbsd_csr.h.
    # should be split per-device (and without base) to still work if we have identical devices in different configurations on multiple boards
    # now it is split

    csr_contents_dict = nubus_to_fpga_export.get_csr_header_split(
        regions   = soc.csr_regions,
        constants = soc.constants,
        csr_base  = soc.mem_regions['csr'].origin)
    for name in csr_contents_dict.keys():
        write_to_file(os.path.join("nubusfpga_csr_{}.h".format(name)), csr_contents_dict[name])
    
    
if __name__ == "__main__":
    main()
