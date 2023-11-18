#
# This file is part of LiteX-Boards.
#
# Support for the ZTEX USB-FGPA Module 2.13:
# <https://www.ztex.de/usb-fpga-2/usb-fpga-2.13.e.html>
# With (no-so-optional) expansion, either the ZTEX Debug board:
# <https://www.ztex.de/usb-fpga-2/debug.e.html>
# Or the NuBusFPGA adapter board:
# <https://github.com/rdolbeau/NuBusFPGA>
#
# Copyright (c) 2015 Yann Sionneau <yann.sionneau@gmail.com>
# Copyright (c) 2015-2019 Florent Kermarrec <florent@enjoy-digital.fr>
# Copyright (c) 2020-2021 Romain Dolbeau <romain@dolbeau.org>
# SPDX-License-Identifier: BSD-2-Clause

from litex.build.generic_platform import *
from litex.build.xilinx import XilinxPlatform
from litex.build.openocd import OpenOCD

from VintageBusFPGA_Common.ztex_21x_common import ZTexPlatform

# IOs ----------------------------------------------------------------------------------------------

# NuBusFPGA I/O

# I/O
_nubus_io_v1_0 = [
    ## leds on the NuBus board
    ("user_led", 0, Pins("V5"),  IOStandard("lvcmos33")), #LED0
    ("user_led", 1, Pins("V4"),  IOStandard("lvcmos33")), #LED1
    ## serial header for console
    ("serial", 0,
     Subsignal("tx", Pins("V9")), # FIXME: might be the other way round
     Subsignal("rx", Pins("U9")),
     IOStandard("LVCMOS33")
    ),
    ## USB
    ("usb", 0,
     Subsignal("dp", Pins("B11")),
     Subsignal("dm", Pins("A11")),
     IOStandard("LVCMOS33")
    ),
    ## VGA
    ("vga", 0,
     Subsignal("clk", Pins("K6")),
     Subsignal("hsync", Pins("U4")),
     Subsignal("vsync", Pins("U3")),
     Subsignal("b", Pins("M2 M3 M4 N4 L5 L6 M6 N6")),
     Subsignal("g", Pins("N2 N1 M1 L1 K3 L3 L4 K5")),
     Subsignal("r", Pins("P5 N5 P4 P3 T1 R1 R2 P2")),
     IOStandard("LVCMOS33"),
    ),
    # HDMI
    ("hdmi", 0,
        Subsignal("clk_p",   Pins("R6"), IOStandard("TMDS_33")),
        Subsignal("clk_n",   Pins("R5"), IOStandard("TMDS_33")),
        Subsignal("data0_p", Pins("U1"), IOStandard("TMDS_33")),
        Subsignal("data0_n", Pins("V1"), IOStandard("TMDS_33")),
        Subsignal("data1_p", Pins("U2"), IOStandard("TMDS_33")),
        Subsignal("data1_n", Pins("V2"), IOStandard("TMDS_33")),
        Subsignal("data2_p", Pins("R3"), IOStandard("TMDS_33")),
        Subsignal("data2_n", Pins("T3"), IOStandard("TMDS_33")),
        Subsignal("hpd",     Pins("T8"), IOStandard("LVCMOS33")),
        Subsignal("sda",     Pins("R8"), IOStandard("LVCMOS33")),
        Subsignal("scl",     Pins("R7"), IOStandard("LVCMOS33")),
        Subsignal("cec",     Pins("T6"), IOStandard("LVCMOS33")),
    ),
    ]

_nubus_io_v1_2 = [
    ## extra 54 MHz clock reference for bank 34
    ("clk54", 0, Pins("R3"), IOStandard("LVCMOS33")),
    ## leds on the NuBus board
    ("user_led", 0, Pins("V9"),  IOStandard("lvcmos33")), #LED0
    ("user_led", 1, Pins("U9"),  IOStandard("lvcmos33")), #LED1; both are overlapping with serial TX/RX
    ## serial header for console
    ("serial", 0,
     Subsignal("tx", Pins("V9")), # FIXME: might be the other way round
     Subsignal("rx", Pins("U9")), # both are overlapping with LED0/1
     IOStandard("LVCMOS33")
    ),
    ## USB
    ("usb", 0,
     Subsignal("dp", Pins("B11")),
     Subsignal("dm", Pins("A11")),
     IOStandard("LVCMOS33")
    ),
    ## HDMI
    ("hdmi", 0,
        Subsignal("clk_p",   Pins("M4"), IOStandard("TMDS_33")),
        Subsignal("clk_n",   Pins("N4"), IOStandard("TMDS_33")),
        Subsignal("data0_p", Pins("M3"), IOStandard("TMDS_33")),
        Subsignal("data0_n", Pins("M2"), IOStandard("TMDS_33")),
        Subsignal("data1_p", Pins("K5"), IOStandard("TMDS_33")),
        Subsignal("data1_n", Pins("L4"), IOStandard("TMDS_33")),
        Subsignal("data2_p", Pins("K3"), IOStandard("TMDS_33")),
        Subsignal("data2_n", Pins("L3"), IOStandard("TMDS_33")),
        Subsignal("hpd",     Pins("N6"), IOStandard("LVCMOS33")),
        Subsignal("sda",     Pins("M6"), IOStandard("LVCMOS33")),
        Subsignal("scl",     Pins("L6"), IOStandard("LVCMOS33")),
        Subsignal("cec",     Pins("L5"), IOStandard("LVCMOS33")),
    ),
    ## micro-sd
    ("sdcard", 0,
        Subsignal("data", Pins("U1 T3 T4 U4"), Misc("PULLUP True")),
        Subsignal("cmd",  Pins("U3"), Misc("PULLUP True")),
        Subsignal("clk",  Pins("V1")),
        #Subsignal("cd",   Pins("")),
        Misc("SLEW=FAST"),
        IOStandard("LVCMOS33"),
    ),
    ]

# NuBus
_nubus_nubus_v1_0 = [
    ("clk_3v3_n",          0, Pins("H16"), IOStandard("lvttl")),
    ("clk2x_3v3_n",        0, Pins("T5"),  IOStandard("lvttl")),
    ("ack_3v3_n",          0, Pins("K13"), IOStandard("lvttl")),
    ("nmrq_3v3_n",         0, Pins("J18"), IOStandard("lvttl")),
    ("reset_3v3_n",        0, Pins("G17"), IOStandard("lvttl")),
    ("rqst_3v3_n"  ,       0, Pins("K16"), IOStandard("lvttl")),
    ("start_3v3_n",        0, Pins("J15"), IOStandard("lvttl")),
    ("ad_3v3_n",           0, Pins("A13 A14 C12 B12 B13 B14 A15 A16 "
                                   "D12 D13 D14 C14 B16 B17 D15 C15 "
                                   "B18 A18 C16 C17 E15 E16 F14 F13 "
                                   "D17 D18 E17 E18 F15 F18 F16 G18 "), IOStandard("lvttl")),
    # ("nubus_arb_n",        0, Pins(""), IOStandard("lvttl")), # CPLD only, we have 'arbcy_n'/'grant' instead
    ("id_3v3_n",           0, Pins("U7 V6 V7 U8"), IOStandard("lvttl")),
    ("tm0_3v3_n",          0, Pins("K15"), IOStandard("lvttl")),
    ("tm1_3v3_n",          0, Pins("J17"), IOStandard("lvttl")),
    ("tm2_3v3_n",          0, Pins("T4"),  IOStandard("lvttl")),
    
    ("nubus_oe",           0, Pins("G13"), IOStandard("lvttl")),
    ("nubus_ad_dir",       0, Pins("G16"), IOStandard("lvttl")),
    ("nubus_master_dir",   0, Pins("H17"), IOStandard("lvttl")),
    ("grant",              0, Pins("H15"), IOStandard("lvttl")),
    ("arbcy_n",            0, Pins("J13"), IOStandard("lvttl")), # arb in the schematics
    ("fpga_to_cpld_clk",   0, Pins("H14"), IOStandard("lvttl")),
    ("tmoen",              0, Pins("U6"),  IOStandard("lvttl")),
    ("fpga_to_cpld_signal",0, Pins("J14"), IOStandard("lvttl")),
    ("fpga_to_cpld_signal_2",0, Pins("G14"), IOStandard("lvttl")),
]

_nubus_nubus_v1_2 = [
    ("clk_3v3_n",          0, Pins("H16"), IOStandard("lvttl")),
    ("clk2x_3v3_n",        0, Pins("T5"),  IOStandard("lvttl")),
    ("ack_3v3_n",          0, Pins("J17"), IOStandard("lvttl")),
    ("ack_o_n",            0, Pins("H14"), IOStandard("lvttl")),
    ("ack_oe_n",           0, Pins("J13"), IOStandard("lvttl")),
    ("nmrq_3v3_n",         0, Pins("K16"), IOStandard("lvttl")), # 'irq' line, Output only direct to 74LVT125
    ("reset_3v3_n",        0, Pins("U8"),  IOStandard("lvttl")), # Input only
    ("rqst_3v3_n"  ,       0, Pins("J18"), IOStandard("lvttl")), # Open Collector
    ("rqst_o_n"  ,         0, Pins("K13"), IOStandard("lvttl")),
    ("start_3v3_n",        0, Pins("K15"), IOStandard("lvttl")),
    ("start_o_n",          0, Pins("H15"), IOStandard("lvttl")),
    ("start_oe_n",         0, Pins("J15"), IOStandard("lvttl")),
    ("ad_3v3_n",           0, Pins("A13 A14 C12 B12 B13 B14 A15 A16 "
                                   "D12 D13 D14 C14 B16 B17 D15 C15 "
                                   "B18 A18 C16 C17 E15 E16 F14 F13 "
                                   "D17 D18 E17 E18 F15 F18 F16 G18 "), IOStandard("lvttl")),
    ("arb_3v3_n",          0, Pins("T8 V4 V5 U6"), IOStandard("lvttl")), # Open Collector
    ("arb_o_n",            0, Pins("J14 G16 G14 H17"), IOStandard("lvttl")),
    ("id_3v3_n",           0, Pins("U7 V6 V7"), IOStandard("lvttl")),
    ("tm0_3v3_n",          0, Pins("U2"), IOStandard("lvttl")),
    ("tm0_o_n",            0, Pins("T6"), IOStandard("lvttl")),
    ("tm1_3v3_n",          0, Pins("V2"), IOStandard("lvttl")),
    ("tm1_o_n",            0, Pins("R7"), IOStandard("lvttl")),
    ("tmx_oe_n",           0, Pins("R8"), IOStandard("lvttl")),
    ("tm2_3v3_n",          0, Pins("K6"),  IOStandard("lvttl")),
    ("tm2_o_n",            0, Pins("R5"),  IOStandard("lvttl")),
    ("tm2_oe_n",           0, Pins("R6"),  IOStandard("lvttl")),
    
    ("nubus_oe",           0, Pins("G13"), IOStandard("lvttl")),
    ("nubus_ad_dir",       0, Pins("G17"), IOStandard("lvttl")),
]

# Connectors ---------------------------------------------------------------------------------------
connectors_v1_0 = [
    ]
connectors_v1_2 = [
    ("P1", "M1 L1 N2 N1 R2 P2 T1 R1 P4 P3 P5 N5"), # check sequence! currently in pmod-* order
    ]

# Extension
def flashtemp_pmod_io(pmod):
    return [
        # completely inconsistent with the SBus entry as P1 is in a different order...
        ("spiflash4x", 0,
         Subsignal("cs_n", Pins(f"{pmod}:2")),
         Subsignal("clk",  Pins(f"{pmod}:5")),
         Subsignal("dq",   Pins(f"{pmod}:7 {pmod}:4 {pmod}:6 {pmod}:3")),
         IOStandard("LVCMOS33")
        ),
]
_flashtemp_pmod_io_v1_2 = flashtemp_pmod_io("P1")

# Ethernet ----------------------------------------------------------------------------------------------
# custom not-quite-pmod
def rmii_eth_extpmod_io(extpmod):
    return [
        ("eth_clocks", 0,
         Subsignal("ref_clk", Pins(f"{extpmod}:8")),
         IOStandard("LVCMOS33"),
         ),
        ("eth", 0,
         Subsignal("rst_n",   Pins(f"{extpmod}:3")),
         Subsignal("rx_data", Pins(f"{extpmod}:11 {extpmod}:10")),
         Subsignal("crs_dv",  Pins(f"{extpmod}:6")),
         Subsignal("tx_en",   Pins(f"{extpmod}:2")),
         Subsignal("tx_data", Pins(f"{extpmod}:0 {extpmod}:1")),
         #Subsignal("mdc",     Pins(f"{extpmod}:4")),
         #Subsignal("mdio",    Pins(f"{extpmod}:7")),
         Subsignal("rx_er",   Pins(f"{extpmod}:9")),
         Subsignal("int_n",   Pins(f"{extpmod}:5")),
         IOStandard("LVCMOS33"),
         ),
         ("sep_mdc",  0, Pins(f"{extpmod}:4"), IOStandard("LVCMOS33")),
         ("sep_mdio", 0, Pins(f"{extpmod}:7"), IOStandard("LVCMOS33")),
]
_rmii_eth_extpmod_io_v1_2 = rmii_eth_extpmod_io("P1")

# Platform -----------------------------------------------------------------------------------------

class Platform(ZTexPlatform):

    def __init__(self, variant="ztex2.13a", version="V1.0"):
        
        nubus_io = {
            "V1.0" : _nubus_io_v1_0,
            "V1.2" : _nubus_io_v1_2,
        }[version]
        nubus_nubus = {
            "V1.0" : _nubus_nubus_v1_0,
            "V1.2" : _nubus_nubus_v1_2,
        }[version]
        connectors = {
            "V1.0" : connectors_v1_0,
            "V1.2" : connectors_v1_2,
        }[version]
        
        ZTexPlatform.__init__(self, variant=variant, version=version, connectors=connectors)
        
        self.add_extension(nubus_io)
        #print(nubus_nubus)
        self.add_extension(nubus_nubus)
