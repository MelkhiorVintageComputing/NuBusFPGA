EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 4 8
Title "nubus-to-ztex HDMI"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L TPD12S016PWR:TPD12S016PWR U9
U 1 1 6148D344
P 3300 2700
F 0 "U9" H 3300 4067 50  0000 C CNN
F 1 "TPD12S016PWR" H 3300 3976 50  0000 C CNN
F 2 "For_SeeedStudio:SOP65P640X120-24N" H 3300 2700 50  0001 L BNN
F 3 "" H 3300 2700 50  0001 L BNN
F 4 "1.2 mm" H 3300 2700 50  0001 L BNN "MAXIMUM_PACKAGE_HEIGHT"
F 5 "Texas Instruments" H 3300 2700 50  0001 L BNN "MANUFACTURER"
F 6 "F" H 3300 2700 50  0001 L BNN "PARTREV"
F 7 "IPC 7351B" H 3300 2700 50  0001 L BNN "STANDARD"
F 8 "TPD12S016PWR" H 3300 2700 50  0001 C CNN "MPN"
F 9 "https://lcsc.com/product-detail/Interface-Specialized_Texas-Instruments-TPD12S016PWR_C201665.html" H 3300 2700 50  0001 C CNN "URL"
	1    3300 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	4000 3600 4000 3650
Connection ~ 4000 3700
Wire Wire Line
	4000 3700 4000 3800
Connection ~ 4000 3800
Wire Wire Line
	4000 3800 4000 3900
$Comp
L power:GND #PWR099
U 1 1 60DDF342
P 4000 3900
F 0 "#PWR099" H 4000 3650 50  0001 C CNN
F 1 "GND" H 4005 3727 50  0000 C CNN
F 2 "" H 4000 3900 50  0001 C CNN
F 3 "" H 4000 3900 50  0001 C CNN
	1    4000 3900
	1    0    0    -1  
$EndComp
Text GLabel 4000 2100 2    50   Input ~ 0
HDMI_CLK+
Text GLabel 6250 2350 0    50   Input ~ 0
HDMI_CLK+
Text GLabel 4000 2200 2    50   Input ~ 0
HDMI_CLK-
Text GLabel 6250 2450 0    50   Input ~ 0
HDMI_CLK-
Text GLabel 6250 2150 0    50   Input ~ 0
HDMI_D0+
Text GLabel 6250 2250 0    50   Input ~ 0
HDMI_D0-
Text GLabel 6250 1950 0    50   Input ~ 0
HDMI_D1+
Text GLabel 6250 2050 0    50   Input ~ 0
HDMI_D1-
Text GLabel 6250 1750 0    50   Input ~ 0
HDMI_D2+
Text GLabel 6250 1850 0    50   Input ~ 0
HDMI_D2-
Text GLabel 4000 2300 2    50   Input ~ 0
HDMI_D0+
Text GLabel 4000 2400 2    50   Input ~ 0
HDMI_D0-
Text GLabel 4000 2500 2    50   Input ~ 0
HDMI_D1+
Text GLabel 4000 2600 2    50   Input ~ 0
HDMI_D1-
Text GLabel 4000 2700 2    50   Input ~ 0
HDMI_D2+
Text GLabel 4000 2800 2    50   Input ~ 0
HDMI_D2-
Wire Wire Line
	6250 2850 5000 2850
Wire Wire Line
	5000 2850 5000 3200
Wire Wire Line
	5000 3200 4000 3200
Wire Wire Line
	6250 2950 5100 2950
Wire Wire Line
	5100 2950 5100 3300
Wire Wire Line
	5100 3300 4000 3300
Wire Wire Line
	6250 2650 4900 2650
Wire Wire Line
	4900 2650 4900 3100
Wire Wire Line
	4900 3100 4000 3100
Wire Wire Line
	4000 3000 5700 3000
Wire Wire Line
	5700 3000 5700 3250
Wire Wire Line
	5700 3250 6250 3250
Connection ~ 4000 3650
Wire Wire Line
	4000 3650 4000 3700
Wire Wire Line
	7300 1450 7300 1550
$Comp
L Device:C C?
U 1 1 6148D345
P 7300 1700
AR Path="/5F679B53/6148D345" Ref="C?"  Part="1" 
AR Path="/5F6B165A/6148D345" Ref="C?"  Part="1" 
AR Path="/612D28DD/6148D345" Ref="C?"  Part="1" 
AR Path="/61B62C00/6148D345" Ref="C24"  Part="1" 
F 0 "C24" H 7325 1800 50  0000 L CNN
F 1 "100nF" H 7325 1600 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 7338 1550 50  0001 C CNN
F 3 "" H 7300 1700 50  0000 C CNN
F 4 "www.yageo.com" H 7300 1700 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 7300 1700 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 7300 1700 50  0001 C CNN "Mouser"
F 7 "?" H 7300 1700 50  0001 C CNN "Digikey"
F 8 "?" H 7300 1700 50  0001 C CNN "LCSC"
F 9 "?" H 7300 1700 50  0001 C CNN "Koncar"
F 10 "TB" H 7300 1700 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    7300 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0100
U 1 1 6148D346
P 7300 1850
F 0 "#PWR0100" H 7300 1600 50  0001 C CNN
F 1 "GND" H 7305 1677 50  0000 C CNN
F 2 "" H 7300 1850 50  0001 C CNN
F 3 "" H 7300 1850 50  0001 C CNN
	1    7300 1850
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR097
U 1 1 6148D347
P 2600 1600
F 0 "#PWR097" H 2600 1450 50  0001 C CNN
F 1 "+3V3" H 2615 1773 50  0000 C CNN
F 2 "" H 2600 1600 50  0001 C CNN
F 3 "" H 2600 1600 50  0001 C CNN
	1    2600 1600
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR098
U 1 1 6148D348
P 2600 1900
F 0 "#PWR098" H 2600 1750 50  0001 C CNN
F 1 "+5V" H 2615 2073 50  0000 C CNN
F 2 "" H 2600 1900 50  0001 C CNN
F 3 "" H 2600 1900 50  0001 C CNN
	1    2600 1900
	1    0    0    -1  
$EndComp
Wire Wire Line
	2600 2300 2400 2300
Wire Wire Line
	2400 2300 2400 2100
Wire Wire Line
	2400 2100 2600 2100
Wire Wire Line
	2600 1600 2400 1600
Wire Wire Line
	2400 1600 2400 2100
Connection ~ 2600 1600
Connection ~ 2400 2100
$Comp
L Device:C C?
U 1 1 6148D349
P 2250 1600
AR Path="/5F679B53/6148D349" Ref="C?"  Part="1" 
AR Path="/5F6B165A/6148D349" Ref="C?"  Part="1" 
AR Path="/612D28DD/6148D349" Ref="C?"  Part="1" 
AR Path="/61B62C00/6148D349" Ref="C22"  Part="1" 
F 0 "C22" H 2275 1700 50  0000 L CNN
F 1 "100nF" H 2275 1500 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 2288 1450 50  0001 C CNN
F 3 "" H 2250 1600 50  0000 C CNN
F 4 "www.yageo.com" H 2250 1600 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 2250 1600 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 2250 1600 50  0001 C CNN "Mouser"
F 7 "?" H 2250 1600 50  0001 C CNN "Digikey"
F 8 "?" H 2250 1600 50  0001 C CNN "LCSC"
F 9 "?" H 2250 1600 50  0001 C CNN "Koncar"
F 10 "TB" H 2250 1600 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 2250 1600 50  0001 C CNN "URL"
	1    2250 1600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR096
U 1 1 6148D34A
P 2100 1600
F 0 "#PWR096" H 2100 1350 50  0001 C CNN
F 1 "GND" V 2105 1472 50  0000 R CNN
F 2 "" H 2100 1600 50  0001 C CNN
F 3 "" H 2100 1600 50  0001 C CNN
	1    2100 1600
	0    1    1    0   
$EndComp
$Comp
L Device:C C?
U 1 1 6148D34B
P 2450 1900
AR Path="/5F679B53/6148D34B" Ref="C?"  Part="1" 
AR Path="/5F6B165A/6148D34B" Ref="C?"  Part="1" 
AR Path="/612D28DD/6148D34B" Ref="C?"  Part="1" 
AR Path="/61B62C00/6148D34B" Ref="C23"  Part="1" 
F 0 "C23" H 2475 2000 50  0000 L CNN
F 1 "100nF" H 2475 1800 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 2488 1750 50  0001 C CNN
F 3 "" H 2450 1900 50  0000 C CNN
F 4 "www.yageo.com" H 2450 1900 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 2450 1900 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 2450 1900 50  0001 C CNN "Mouser"
F 7 "?" H 2450 1900 50  0001 C CNN "Digikey"
F 8 "?" H 2450 1900 50  0001 C CNN "LCSC"
F 9 "?" H 2450 1900 50  0001 C CNN "Koncar"
F 10 "TB" H 2450 1900 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    2450 1900
	0    1    1    0   
$EndComp
Connection ~ 2600 1900
Wire Wire Line
	2300 1900 2100 1900
Wire Wire Line
	2100 1900 2100 1600
Text GLabel 2600 3000 0    50   Input ~ 0
HDMI_HPD_A
Text GLabel 2600 3100 0    50   Input ~ 0
HDMI_CEC_A
Text GLabel 2600 3200 0    50   Input ~ 0
HDMI_SCL_A
Text GLabel 2600 3300 0    50   Input ~ 0
HDMI_SDA_A
$Comp
L Connector:HDMI_A J5
U 1 1 6148D34C
P 6650 2550
F 0 "J5" H 7079 2596 50  0000 L CNN
F 1 "10029449-111RLF (HDMI A)" H 7079 2505 50  0000 L CNN
F 2 "For_SeeedStudio:HDMI_A_Amphenol_10029449-111" H 6675 2550 50  0001 C CNN
F 3 "https://en.wikipedia.org/wiki/HDMI" H 6675 2550 50  0001 C CNN
F 4 "10029449-111RLF" H 6650 2550 50  0001 C CNN "MPN"
F 5 "https://www2.mouser.com/ProductDetail/Amphenol-FCI/10029449-111RLF?qs=fmpTyLOWOey0HPdD9%2F%2FaXA%3D%3D" H 6650 2550 50  0001 C CNN "URL-ALT"
F 6 "https://lcsc.com/product-detail/D-Sub-DVI-HDMI-Connectors_Amphenol-ICC-10029449-111RLF_C427307.html" H 6650 2550 50  0001 C CNN "URL"
	1    6650 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6450 3650 6550 3650
Connection ~ 6450 3650
Wire Wire Line
	6650 3650 6750 3650
Connection ~ 6750 3650
Wire Wire Line
	6750 3650 6850 3650
Wire Wire Line
	6550 3650 6650 3650
Connection ~ 6550 3650
Connection ~ 6650 3650
Text Label 4900 2650 0    50   ~ 0
HDMI_CEC_B
Text Label 5000 2850 0    50   ~ 0
HDMI_SCL_B
Text Label 5100 2950 0    50   ~ 0
HDMI_SDA_B
Text Label 5700 3000 0    50   ~ 0
HDMI_HPD_B
$Comp
L Device:C C?
U 1 1 6148D34D
P 2250 1350
AR Path="/5F69F4EF/6148D34D" Ref="C?"  Part="1" 
AR Path="/5F6B165A/6148D34D" Ref="C?"  Part="1" 
AR Path="/612D28DD/6148D34D" Ref="C?"  Part="1" 
AR Path="/61B62C00/6148D34D" Ref="C21"  Part="1" 
F 0 "C21" H 2275 1450 50  0000 L CNN
F 1 "47uF 10V 0805" H 2275 1250 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 2288 1200 50  0001 C CNN
F 3 "" H 2250 1350 50  0000 C CNN
F 4 "GRM21BR61A476ME15L # 10V" H 2250 1350 50  0001 C CNN "MPN-ALT3"
F 5 "GRM21BR60J476ME15L # 6V3 # delay" H 2250 1350 50  0001 C CNN "MPN-ALT2"
F 6 "CC0805MRX5R5BB476 # obsolete" H 2250 1350 50  0001 C CNN "MPN-ALT"
F 7 "GRM21BR60J476ME01L" H 2250 1350 50  0001 C CNN "MPN-PREV"
F 8 "https://www2.mouser.com/ProductDetail/Murata/GRM21BR60J476ME15L?qs=Tw3AuTVwGeLlkNhaDtjM1w%3D%3D" H 2250 1350 50  0001 C CNN "URL-ALT2"
F 9 "https://www2.mouser.com/ProductDetail/?qs=u16ybLDytRYYQtTToF3RWA%3D%3D" H 2250 1350 50  0001 C CNN "URL-PREV"
F 10 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_TDK-C2012X5R1A476MTJ00E_C76636.html" H 2250 1350 50  0001 C CNN "URL-ALT"
F 11 "GRM21BR61A476ME15K" H 2250 1350 50  0001 C CNN "MPN"
F 12 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Murata-Electronics-GRM21BR61A476ME15K_C2292827.html" H 2250 1350 50  0001 C CNN "URL"
	1    2250 1350
	0    1    1    0   
$EndComp
Connection ~ 2400 1600
Connection ~ 2100 1600
Text GLabel 6950 3650 2    50   Input ~ 0
SHIELD
Text HLabel 4000 3000 2    50   Input ~ 0
hpd_b
Text HLabel 4000 3100 2    50   Input ~ 0
cec_b
Text HLabel 4000 3200 2    50   Input ~ 0
scl_b
Text HLabel 4000 3300 2    50   Input ~ 0
sda_b
Text HLabel 2600 2300 2    50   Input ~ 0
ls_oe
Text HLabel 2600 2100 2    50   Input ~ 0
ct_hpd
$Comp
L Device:C C?
U 1 1 61B9B186
P 2250 1100
AR Path="/5F679B53/61B9B186" Ref="C?"  Part="1" 
AR Path="/5F6B165A/61B9B186" Ref="C?"  Part="1" 
AR Path="/612D28DD/61B9B186" Ref="C?"  Part="1" 
AR Path="/61B62C00/61B9B186" Ref="C20"  Part="1" 
F 0 "C20" H 2275 1200 50  0000 L CNN
F 1 "10nF" H 2275 1000 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 2288 950 50  0001 C CNN
F 3 "" H 2250 1100 50  0000 C CNN
F 4 "www.yageo.com" H 2250 1100 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB103" H 2250 1100 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB103" H 2250 1100 50  0001 C CNN "Mouser"
F 7 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB103_C327204.html" H 2250 1100 50  0001 C CNN "URL"
	1    2250 1100
	0    1    1    0   
$EndComp
Wire Wire Line
	2400 1100 2400 1350
Wire Wire Line
	2100 1100 2100 1350
Connection ~ 2400 1350
Wire Wire Line
	2400 1350 2400 1600
Connection ~ 2100 1350
Wire Wire Line
	2100 1350 2100 1600
Wire Wire Line
	4000 3650 6450 3650
NoConn ~ 6250 3150
Wire Wire Line
	6650 1450 7300 1450
Text HLabel 7300 1450 2    50   Input ~ 0
HDMI_5V
Text HLabel 4000 1900 2    50   Input ~ 0
HDMI_5V
Text GLabel 6400 4500 0    50   Input ~ 0
SHIELD
$Comp
L power:GND #PWR?
U 1 1 63467FDF
P 6400 4800
AR Path="/6193AB43/63467FDF" Ref="#PWR?"  Part="1" 
AR Path="/61B62C00/63467FDF" Ref="#PWR0132"  Part="1" 
F 0 "#PWR0132" H 6400 4550 50  0001 C CNN
F 1 "GND" H 6405 4627 50  0000 C CNN
F 2 "" H 6400 4800 50  0001 C CNN
F 3 "" H 6400 4800 50  0001 C CNN
	1    6400 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	6650 4800 6400 4800
Wire Wire Line
	6650 4500 6400 4500
$Comp
L Device:C C?
U 1 1 63467FEB
P 6650 4650
AR Path="/6193AB43/63467FEB" Ref="C?"  Part="1" 
AR Path="/61B62C00/63467FEB" Ref="C39"  Part="1" 
F 0 "C39" H 6765 4696 50  0000 L CNN
F 1 "1uF 250V Radial 6.3x2.5" H 6765 4605 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D6.3mm_P2.50mm" H 6688 4500 50  0001 C CNN
F 3 "~" H 6650 4650 50  0001 C CNN
F 4 "860021373002" H 6650 4650 50  0001 C CNN "MPN-ALT"
F 5 "https://www2.mouser.com/ProductDetail/Wurth-Elektronik/860021373002?qs=0KOYDY2FL28tNXbPyU6hsg%3D%3D" H 6650 4650 50  0001 C CNN "URL-ALT"
F 6 "KM010M400E110A" H 6650 4650 50  0001 C CNN "MPN"
F 7 "https://lcsc.com/product-detail/Aluminum-Electrolytic-Capacitors-Leaded_Capxon-International-Elec-KM010M400E110A_C59365.html" H 6650 4650 50  0001 C CNN "URL"
	1    6650 4650
	1    0    0    -1  
$EndComp
Connection ~ 6400 4800
$Comp
L Device:R R?
U 1 1 63467FF7
P 6400 4650
AR Path="/6193AB43/63467FF7" Ref="R?"  Part="1" 
AR Path="/61B62C00/63467FF7" Ref="R33"  Part="1" 
F 0 "R33" H 6470 4696 50  0000 L CNN
F 1 "1M 1210" H 6470 4605 50  0000 L CNN
F 2 "Resistor_SMD:R_1210_3225Metric" V 6330 4650 50  0001 C CNN
F 3 "~" H 6400 4650 50  0001 C CNN
F 4 "RC1210FR-071ML" H 6400 4650 50  0001 C CNN "MPN-ALT"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_YAGEO-RC1210FR-071ML_C470029.html" H 6400 4650 50  0001 C CNN "URL-ALT"
F 6 "1210W2F1004T5E" H 6400 4650 50  0001 C CNN "MPN"
F 7 "https://www.lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-1210W2F1004T5E_C620664.html" H 6400 4650 50  0001 C CNN "URL"
	1    6400 4650
	1    0    0    -1  
$EndComp
$Comp
L Mechanical:MountingHole_Pad H?
U 1 1 63467FFE
P 6650 4400
AR Path="/6193AB43/63467FFE" Ref="H?"  Part="1" 
AR Path="/61B62C00/63467FFE" Ref="H1"  Part="1" 
F 0 "H1" H 6750 4451 50  0000 L CNN
F 1 "MountingHole_Pad" H 6750 4360 50  0000 L CNN
F 2 "MountingHole:MountingHole_2.2mm_M2_Pad" H 6650 4400 50  0001 C CNN
F 3 "~" H 6650 4400 50  0001 C CNN
	1    6650 4400
	1    0    0    -1  
$EndComp
Connection ~ 6650 4500
$EndSCHEMATC
