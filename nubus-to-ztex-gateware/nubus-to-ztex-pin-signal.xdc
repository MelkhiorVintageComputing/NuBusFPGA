# !!! Constraint files are application specific !!!
# !!!          This is a template only          !!!

# on-board signals

# CLKOUT/FXCLK 
create_clock -name fxclk_in -period 20.833 [get_ports fxclk_in]
set_property PACKAGE_PIN P15 [get_ports fxclk_in]
set_property IOSTANDARD LVCMOS33 [get_ports fxclk_in]

# IFCLK 
#create_clock -name ifclk_in -period 20.833 [get_ports ifclk_in]
#set_property PACKAGE_PIN P17 [get_ports ifclk_in]
#set_property IOSTANDARD LVCMOS33 [get_ports ifclk_in]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 66 [current_design]  
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR No [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 2 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS true [current_design]


# set_property PACKAGE_PIN  [get_ports {}]
# set_property IOSTANDARD LVTTL [get_ports {}]

#### AB
# AB TOP LEFT (12)
set_property PACKAGE_PIN K16 [get_ports {rqst_n}]
set_property PACKAGE_PIN K15 [get_ports {start_n}]
set_property PACKAGE_PIN J15 [get_ports {start_oe_n}]
set_property PACKAGE_PIN H15 [get_ports {start_o_n}]
set_property PACKAGE_PIN J14 [get_ports {arb_o_n[0]}]
set_property PACKAGE_PIN H17 [get_ports {arb_o_n[3]}]
set_property PACKAGE_PIN G17 [get_ports {nubus_ad_dir}]
set_property PACKAGE_PIN G18 [get_ports {ad_n[31]}]
set_property PACKAGE_PIN F18 [get_ports {ad_n[29]}]
set_property PACKAGE_PIN E18 [get_ports {ad_n[27]}]
set_property PACKAGE_PIN D18 [get_ports {ad_n[25]}]
set_property PACKAGE_PIN G13 [get_ports {nubus_oe}]

# AB BOTTOM LEFT (13)
set_property PACKAGE_PIN F13 [get_ports {ad_n[23]}]
set_property PACKAGE_PIN E16 [get_ports {ad_n[21]}]
set_property PACKAGE_PIN C17 [get_ports {ad_n[19]}]
set_property PACKAGE_PIN A18 [get_ports {ad_n[17]}]
set_property PACKAGE_PIN C15 [get_ports {ad_n[15]}]
set_property PACKAGE_PIN B17 [get_ports {ad_n[13]}]
set_property PACKAGE_PIN C14 [get_ports {ad_n[11]}]
set_property PACKAGE_PIN D13 [get_ports {ad_n[9]}]
set_property PACKAGE_PIN A16 [get_ports {ad_n[7]}]
set_property PACKAGE_PIN B14 [get_ports {ad_n[5]}]
set_property PACKAGE_PIN B12 [get_ports {ad_n[3]}]
set_property PACKAGE_PIN A14 [get_ports {ad_n[1]}]
set_property PACKAGE_PIN B11 [get_ports {usbh0_p}]

# AB TOP RIGHT (12)
set_property PACKAGE_PIN J18 [get_ports {nmrq_n}]
set_property PACKAGE_PIN J17 [get_ports {ack_n}]
set_property PACKAGE_PIN K13 [get_ports {rsqt_o_n}]
set_property PACKAGE_PIN J13 [get_ports {ack_oe_n}]
set_property PACKAGE_PIN H14 [get_ports {ack_o_n}]
set_property PACKAGE_PIN G14 [get_ports {arb_o_n[2]}]
set_property PACKAGE_PIN G16 [get_ports {arb_o_n[1]}]
set_property PACKAGE_PIN H16 [get_ports {clk_n}]
set_property PACKAGE_PIN F16 [get_ports {ad_n[30]}]
set_property PACKAGE_PIN F15 [get_ports {ad_n[28]}]
set_property PACKAGE_PIN E17 [get_ports {ad_n[26]}]
set_property PACKAGE_PIN D17 [get_ports {ad_n[24]}]

# AB BOTTOM RIGHT (13)
set_property PACKAGE_PIN F14 [get_ports {ad_n[22]}]
set_property PACKAGE_PIN E15 [get_ports {ad_n[20]}]
set_property PACKAGE_PIN C16 [get_ports {ad_n[18]}]
set_property PACKAGE_PIN B18 [get_ports {ad_n[16]}]
set_property PACKAGE_PIN D15 [get_ports {ad_n[14]}]
set_property PACKAGE_PIN B16 [get_ports {ad_n[12]}]
set_property PACKAGE_PIN D14 [get_ports {ad_n[10]}]
set_property PACKAGE_PIN D12 [get_ports {ad_n[8]}]
set_property PACKAGE_PIN A15 [get_ports {ad_n[6]}]
set_property PACKAGE_PIN B13 [get_ports {ad_n[4]}]
set_property PACKAGE_PIN C12 [get_ports {ad_n[2]}]
set_property PACKAGE_PIN A13 [get_ports {ad_n[0]}]
set_property PACKAGE_PIN A11 [get_ports {usbh0_n}]

#### CD
# CD TOP LEFT (13)
set_property PACKAGE_PIN U9 [get_ports {RX}]
set_property PACKAGE_PIN U8 [get_ports {id_n[3]}]
set_property PACKAGE_PIN U7 [get_ports {id_n[0]}]
set_property PACKAGE_PIN U6 [get_ports {arb_n[3]}]
set_property PACKAGE_PIN T8 [get_ports {arb_n[0]}]
set_property PACKAGE_PIN R8 [get_ports {PMOD6}]
set_property PACKAGE_PIN R7 [get_ports {PMOD5}]
set_property PACKAGE_PIN T6 [get_ports {PMOD8}]
set_property PACKAGE_PIN R6 [get_ports {PMOD7}]
set_property PACKAGE_PIN R5 [get_ports {PMOD10}]
set_property PACKAGE_PIN V2 [get_ports {PMOD9}]
set_property PACKAGE_PIN U2 [get_ports {PMOD12}]
set_property PACKAGE_PIN K6 [get_ports {PMOD11}]

# CD BOTTOM LEFT (12)
set_property PACKAGE_PIN N6 [get_ports {hdmi_hpd_a}]
set_property PACKAGE_PIN M6 [get_ports {hdmi_sda_a}]
set_property PACKAGE_PIN L6 [get_ports {hdmi_scl_a}]
set_property PACKAGE_PIN L5 [get_ports {hdmi_cec_a}]
set_property PACKAGE_PIN N4 [get_ports {hdmi_clk_n}]
set_property PACKAGE_PIN M4 [get_ports {hdmi_clk_p}]
set_property PACKAGE_PIN M3 [get_ports {hdmi_d0_p}]
set_property PACKAGE_PIN M2 [get_ports {hdmi_d0_n}]
set_property PACKAGE_PIN K5 [get_ports {hdmi_d1_p}]
set_property PACKAGE_PIN L4 [get_ports {hdmi_d1_n}]
set_property PACKAGE_PIN L3 [get_ports {hdmi_d2_n}]
set_property PACKAGE_PIN K3 [get_ports {hdmi_d2_p}]

# CD TOP RIGHT (13)
set_property PACKAGE_PIN V9 [get_ports {TX}]
set_property PACKAGE_PIN V7 [get_ports {id_n[2]}]
set_property PACKAGE_PIN V6 [get_ports {id_n[1]}]
set_property PACKAGE_PIN V5 [get_ports {arb_n[2]}]
set_property PACKAGE_PIN V4 [get_ports {arb_n[1]}]
set_property PACKAGE_PIN T5 [get_ports {clk2x_n}]
set_property PACKAGE_PIN T4 [get_ports {SD_D1}]
set_property PACKAGE_PIN U4 [get_ports {SD_D0}]
set_property PACKAGE_PIN U3 [get_ports {SD_CLK}]
set_property PACKAGE_PIN V1 [get_ports {SD_CMD}]
set_property PACKAGE_PIN U1 [get_ports {SD_D3}]
set_property PACKAGE_PIN T3 [get_ports {SD_D2}]
set_property PACKAGE_PIN R3 [get_ports {tmx_oe_n}]

# CD BOTTOM RIGHT (12)
set_property PACKAGE_PIN P5 [get_ports {tm_n[0]}]
set_property PACKAGE_PIN N5 [get_ports {tm_n[1]}]
set_property PACKAGE_PIN P4 [get_ports {tm_n_o[1]}]
set_property PACKAGE_PIN P3 [get_ports {tm_n_o[0]}]
set_property PACKAGE_PIN T1 [get_ports {tm2_oe_n}]
set_property PACKAGE_PIN R1 [get_ports {tm_o_n[2]}]
set_property PACKAGE_PIN R2 [get_ports {tm_n[2]}]
set_property PACKAGE_PIN P2 [get_ports {reset_n}]
set_property PACKAGE_PIN N2 [get_ports {led[0]}]
set_property PACKAGE_PIN N1 [get_ports {led[1]}]
set_property PACKAGE_PIN M1 [get_ports {led[2]}]
set_property PACKAGE_PIN L1 [get_ports {led[3]}]

