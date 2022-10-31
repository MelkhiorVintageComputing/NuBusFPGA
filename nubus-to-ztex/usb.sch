EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 5 8
Title "nubus-to-ztex USB"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:USB_B_Micro J6
U 1 1 60D9A6A3
P 5000 2800
F 0 "J6" H 5055 3267 50  0000 C CNN
F 1 "USB micro-B" H 5055 3176 50  0000 C CNN
F 2 "Connector_USB:USB_Micro-B_Molex-105017-0001" H 5150 2750 50  0001 C CNN
F 3 "https://www.molex.com/pdm_docs/sd/1050170001_sd.pdf" H 5150 2750 50  0001 C CNN
F 4 "105017-0001" H 5000 2800 50  0001 C CNN "MPN"
F 5 "Molex" H 5000 2800 50  0001 C CNN "Manufacturer"
F 6 "https://lcsc.com/product-detail/USB-Connectors_MOLEX-1050170001_C136000.html" H 5000 2800 50  0001 C CNN "URL"
F 7 "https://www.mouser.fr/ProductDetail/Molex/105017-0001?qs=hlXxxvYE36k7QcsR97GUKA%3D%3D" H 5000 2800 50  0001 C CNN "URL-ALT"
	1    5000 2800
	-1   0    0    -1  
$EndComp
Text Label 7400 2800 0    50   ~ 0
VBus
Wire Wire Line
	7400 2800 7200 2800
$Comp
L power:GND #PWR0104
U 1 1 60D9A6B5
P 6700 3400
F 0 "#PWR0104" H 6700 3150 50  0001 C CNN
F 1 "GND" H 6705 3227 50  0000 C CNN
F 2 "" H 6700 3400 50  0001 C CNN
F 3 "" H 6700 3400 50  0001 C CNN
	1    6700 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	7200 2600 7400 2600
Text GLabel 7400 2600 2    50   Input ~ 0
+5V
Wire Wire Line
	6200 2600 6000 2600
Text Label 6000 2600 2    50   ~ 0
USB_FLT
Text Label 6000 3000 2    50   ~ 0
USB_EN
$Comp
L Device:R R?
U 1 1 60D9A6C2
P 6200 2450
AR Path="/5F6B165A/60D9A6C2" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A6C2" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A6C2" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A6C2" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A6C2" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A6C2" Ref="R27"  Part="1" 
F 0 "R27" V 6280 2450 50  0000 C CNN
F 1 "10k" V 6200 2450 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 6130 2450 50  0001 C CNN
F 3 "" H 6200 2450 50  0000 C CNN
F 4 "0603WAF1002T5E" V 6200 1850 50  0001 C CNN "MPN"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF1002T5E_C25804.html" V 6200 2450 50  0001 C CNN "URL"
	1    6200 2450
	-1   0    0    1   
$EndComp
Wire Wire Line
	6200 2300 6200 2100
$Comp
L Device:R R?
U 1 1 60D9A6CD
P 6100 2850
AR Path="/5F6B165A/60D9A6CD" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A6CD" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A6CD" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A6CD" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A6CD" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A6CD" Ref="R26"  Part="1" 
F 0 "R26" V 6180 2850 50  0000 C CNN
F 1 "10k" V 6100 2850 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 6030 2850 50  0001 C CNN
F 3 "" H 6100 2850 50  0000 C CNN
F 4 "0603WAF1002T5E" V 6100 2250 50  0001 C CNN "MPN"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF1002T5E_C25804.html" V 6100 2850 50  0001 C CNN "URL"
	1    6100 2850
	-1   0    0    1   
$EndComp
Wire Wire Line
	6100 2700 6100 2100
Wire Wire Line
	6100 2100 6200 2100
Wire Wire Line
	6250 2100 6200 2100
Connection ~ 6200 2100
Wire Wire Line
	7200 1850 7400 1850
Text GLabel 7400 1850 2    50   Input ~ 0
+5V
$Comp
L Device:C C?
U 1 1 60D9A6E1
P 7200 2000
AR Path="/5F679B53/60D9A6E1" Ref="C?"  Part="1" 
AR Path="/5F69F4EF/60D9A6E1" Ref="C?"  Part="1" 
AR Path="/60D72F2C/60D9A6E1" Ref="C?"  Part="1" 
AR Path="/619A5A47/60D9A6E1" Ref="C?"  Part="1" 
AR Path="/61B604DE/60D9A6E1" Ref="C26"  Part="1" 
F 0 "C26" H 7225 2100 50  0000 L CNN
F 1 "100nF" H 7225 1900 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 7238 1850 50  0001 C CNN
F 3 "" H 7200 2000 50  0000 C CNN
F 4 "www.yageo.com" H 7200 2000 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 7200 2000 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 7200 2000 50  0001 C CNN "Mouser"
F 7 "?" H 7200 2000 50  0001 C CNN "Digikey"
F 8 "?" H 7200 2000 50  0001 C CNN "LCSC"
F 9 "?" H 7200 2000 50  0001 C CNN "Koncar"
F 10 "TB" H 7200 2000 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    7200 2000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 60D9A6E8
P 7200 2150
F 0 "#PWR0105" H 7200 1900 50  0001 C CNN
F 1 "GND" H 7205 1977 50  0000 C CNN
F 2 "" H 7200 2150 50  0001 C CNN
F 3 "" H 7200 2150 50  0001 C CNN
	1    7200 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 2900 4450 2900
Wire Wire Line
	4700 2800 4450 2800
$Comp
L Power_Protection:SN65220 U10
U 1 1 60D9A6FD
P 4250 2850
F 0 "U10" V 4296 2937 50  0000 L CNN
F 1 "SN65220" V 4205 2937 50  0000 L CNN
F 2 "Package_TO_SOT_SMD:SOT-23-6" H 4600 2700 50  0001 L CNN
F 3 "http://www.ti.com/lit/ds/symlink/sn65220.pdf" H 4250 3000 50  0001 C CNN
F 4 "SN65220DBVT" V 4250 2850 50  0001 C CNN "MPN"
F 5 "https://www2.mouser.com/ProductDetail/Texas-Instruments/SN65220DBVR?qs=5nGYs9Do7G0gEpYxbYqyeA%3D%3D" V 4250 2850 50  0001 C CNN "URL-ALT"
F 6 "https://www.lcsc.com/product-detail/Others_Texas-Instruments-TI-SN65220DBVT_C350555.html" V 4250 2850 50  0001 C CNN "URL"
F 7 "SN65220DBVT or SN65220DBVR (Tape or Reel...)" V 4250 2850 50  0001 C CNN "Notes"
	1    4250 2850
	0    1    -1   0   
$EndComp
Wire Wire Line
	4450 2800 4450 2250
Wire Wire Line
	4450 2900 4450 3450
$Comp
L power:GND #PWR0101
U 1 1 60D9A706
P 3850 2850
F 0 "#PWR0101" H 3850 2600 50  0001 C CNN
F 1 "GND" H 3855 2677 50  0000 C CNN
F 2 "" H 3850 2850 50  0001 C CNN
F 3 "" H 3850 2850 50  0001 C CNN
	1    3850 2850
	1    0    0    -1  
$EndComp
Wire Wire Line
	3850 2850 3950 2850
Connection ~ 3950 2850
$Comp
L Device:R R?
U 1 1 60D9A70F
P 3950 2500
AR Path="/5F6B165A/60D9A70F" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A70F" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A70F" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A70F" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A70F" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A70F" Ref="R24"  Part="1" 
F 0 "R24" V 4030 2500 50  0000 C CNN
F 1 "15k" V 3950 2500 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3880 2500 50  0001 C CNN
F 3 "" H 3950 2500 50  0000 C CNN
F 4 "0603WAF1502T5E" V 3950 1900 50  0001 C CNN "MPN"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF1502T5E_C22809.html" V 3950 2500 50  0001 C CNN "URL"
	1    3950 2500
	-1   0    0    1   
$EndComp
$Comp
L Device:R R?
U 1 1 60D9A717
P 3950 3200
AR Path="/5F6B165A/60D9A717" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A717" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A717" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A717" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A717" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A717" Ref="R25"  Part="1" 
F 0 "R25" V 4030 3200 50  0000 C CNN
F 1 "15k" V 3950 3200 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3880 3200 50  0001 C CNN
F 3 "" H 3950 3200 50  0000 C CNN
F 4 "0603WAF1502T5E" V 3950 2600 50  0001 C CNN "MPN"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF1502T5E_C22809.html" V 3950 3200 50  0001 C CNN "URL"
	1    3950 3200
	-1   0    0    1   
$EndComp
Wire Wire Line
	3950 3350 3950 3450
Wire Wire Line
	3950 3450 4250 3450
Wire Wire Line
	3950 2250 3950 2350
Connection ~ 4250 2250
Connection ~ 4250 3450
Connection ~ 3950 2950
Connection ~ 3950 2750
Wire Wire Line
	3950 2750 3950 2650
Wire Wire Line
	3950 2850 3950 2750
Wire Wire Line
	3950 3050 3950 2950
Wire Wire Line
	3950 2950 3950 2850
Wire Wire Line
	4450 3450 4250 3450
Wire Wire Line
	4250 2250 3950 2250
Wire Wire Line
	4450 2250 4250 2250
$Comp
L Device:R R?
U 1 1 60D9A72D
P 3700 2250
AR Path="/5F6B165A/60D9A72D" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A72D" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A72D" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A72D" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A72D" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A72D" Ref="R22"  Part="1" 
F 0 "R22" V 3780 2250 50  0000 C CNN
F 1 "27" V 3700 2250 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3630 2250 50  0001 C CNN
F 3 "" H 3700 2250 50  0000 C CNN
F 4 "0603WAF270JT5E" V 3700 2250 50  0001 C CNN "MPN"
F 5 "ERJ-3EKF27R0V" V 3700 1650 50  0001 C CNN "MPN-ALT"
F 6 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF270JT5E_C25190.html" V 3700 2250 50  0001 C CNN "URL"
	1    3700 2250
	0    1    1    0   
$EndComp
$Comp
L Device:R R?
U 1 1 60D9A735
P 3700 3450
AR Path="/5F6B165A/60D9A735" Ref="R?"  Part="1" 
AR Path="/5F679B53/60D9A735" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/60D9A735" Ref="R?"  Part="1" 
AR Path="/60D72F2C/60D9A735" Ref="R?"  Part="1" 
AR Path="/619A5A47/60D9A735" Ref="R?"  Part="1" 
AR Path="/61B604DE/60D9A735" Ref="R23"  Part="1" 
F 0 "R23" V 3780 3450 50  0000 C CNN
F 1 "27" V 3700 3450 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 3630 3450 50  0001 C CNN
F 3 "" H 3700 3450 50  0000 C CNN
F 4 "0603WAF270JT5E" V 3700 3450 50  0001 C CNN "MPN"
F 5 "ERJ-3EKF27R0V" V 3700 2850 50  0001 C CNN "MPN-ALT"
F 6 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF270JT5E_C25190.html" V 3700 3450 50  0001 C CNN "URL"
	1    3700 3450
	0    1    1    0   
$EndComp
Wire Wire Line
	3850 3450 3950 3450
Connection ~ 3950 3450
Wire Wire Line
	3850 2250 3950 2250
Connection ~ 3950 2250
Text Label 4950 1450 2    50   ~ 0
VBus
$Comp
L power:GND #PWR0103
U 1 1 60D9A747
P 5000 3200
F 0 "#PWR0103" H 5000 2950 50  0001 C CNN
F 1 "GND" H 5005 3027 50  0000 C CNN
F 2 "" H 5000 3200 50  0001 C CNN
F 3 "" H 5000 3200 50  0001 C CNN
	1    5000 3200
	1    0    0    -1  
$EndComp
Wire Wire Line
	4700 1850 4700 2600
Wire Wire Line
	4700 1850 4950 1850
$Comp
L Device:CP C25
U 1 1 60D9A750
P 4950 2000
F 0 "C25" H 5068 2046 50  0000 L CNN
F 1 "150uF (could be >= 100 uF or even less, probably)" H 5068 1955 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 4988 1850 50  0001 C CNN
F 3 "~" H 4950 2000 50  0001 C CNN
F 4 "GRM31CR60J157ME11L" H 4950 2000 50  0001 C CNN "MPN-ALT"
F 5 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Murata-Electronics-GRM31CR60J157ME11L_C528968.html" H 4950 2000 50  0001 C CNN "URL-ALT"
F 6 "https://www.mouser.fr/ProductDetail/Murata-Electronics/GRM31CR60J157ME11L?qs=qSv5qXjCIG3a12X8fU8miQ%3D%3D" H 4950 2000 50  0001 C CNN "URL-ALT (mouser)"
F 7 "JMK316ABJ107ML-T" H 4950 2000 50  0001 C CNN "MPN"
F 8 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Taiyo-Yuden-JMK316ABJ107ML-T_C268006.html" H 4950 2000 50  0001 C CNN "URL"
	1    4950 2000
	1    0    0    -1  
$EndComp
$Comp
L Device:Ferrite_Bead_Small FB1
U 1 1 60D9A758
P 4950 1750
F 0 "FB1" H 5050 1796 50  0000 L CNN
F 1 "Ferrite_Bead_Small" H 5050 1705 50  0000 L CNN
F 2 "Inductor_SMD:L_0805_2012Metric" V 4880 1750 50  0001 C CNN
F 3 "~" H 4950 1750 50  0001 C CNN
F 4 "742792022" H 4950 1750 50  0001 C CNN "MPN-ALT"
F 5 "PZ2012U221-2R0TF" H 4950 1750 50  0001 C CNN "MPN"
F 6 "https://lcsc.com/product-detail/Ferrite-Beads_Sunlord-PZ2012U221-2R0TF_C44361.html" H 4950 1750 50  0001 C CNN "URL"
	1    4950 1750
	1    0    0    -1  
$EndComp
Connection ~ 4950 1850
Wire Wire Line
	4950 1650 4950 1450
$Comp
L power:GND #PWR0102
U 1 1 60D9A761
P 4950 2150
F 0 "#PWR0102" H 4950 1900 50  0001 C CNN
F 1 "GND" H 4955 1977 50  0000 C CNN
F 2 "" H 4950 2150 50  0001 C CNN
F 3 "" H 4950 2150 50  0001 C CNN
	1    4950 2150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6000 3000 6100 3000
Connection ~ 6100 3000
Wire Wire Line
	6100 3000 6200 3000
Text GLabel 3550 2250 0    50   Input ~ 0
USBH0_D+
Text GLabel 3550 3450 0    50   Input ~ 0
USBH0_D-
Text Label 4700 2050 2    50   ~ 0
VBus_USB0
Text Notes 5050 4200 0    50   ~ 0
Inspired by Dolu1990's USB pmod\nSwitch to a TPS2051C for availability (and .5A is enough as there's just one port)\n
Text GLabel 6250 2100 2    50   Input ~ 0
+5V
Text Notes 6350 4050 1    50   ~ 0
TPS2051C uses EN not !EN
Wire Wire Line
	7850 1850 8050 1850
$Comp
L Device:C C?
U 1 1 612D3A06
P 7850 2000
AR Path="/5F679B53/612D3A06" Ref="C?"  Part="1" 
AR Path="/5F69F4EF/612D3A06" Ref="C?"  Part="1" 
AR Path="/60D72F2C/612D3A06" Ref="C?"  Part="1" 
AR Path="/619A5A47/612D3A06" Ref="C?"  Part="1" 
AR Path="/61B604DE/612D3A06" Ref="C27"  Part="1" 
F 0 "C27" H 7875 2100 50  0000 L CNN
F 1 "100nF" H 7875 1900 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 7888 1850 50  0001 C CNN
F 3 "" H 7850 2000 50  0000 C CNN
F 4 "www.yageo.com" H 7850 2000 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 7850 2000 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 7850 2000 50  0001 C CNN "Mouser"
F 7 "?" H 7850 2000 50  0001 C CNN "Digikey"
F 8 "?" H 7850 2000 50  0001 C CNN "LCSC"
F 9 "?" H 7850 2000 50  0001 C CNN "Koncar"
F 10 "TB" H 7850 2000 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    7850 2000
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 612D3A0D
P 7850 2150
F 0 "#PWR0106" H 7850 1900 50  0001 C CNN
F 1 "GND" H 7855 1977 50  0000 C CNN
F 2 "" H 7850 2150 50  0001 C CNN
F 3 "" H 7850 2150 50  0001 C CNN
	1    7850 2150
	1    0    0    -1  
$EndComp
Text Label 8050 1850 0    50   ~ 0
VBus
$Comp
L Power_Management:TPS2041B U11
U 1 1 60D9A6AC
P 6700 2800
F 0 "U11" H 6700 3267 50  0000 C CNN
F 1 "TPS2051C" H 6700 3176 50  0000 C CNN
F 2 "Package_TO_SOT_SMD:SOT-23-5" H 6700 3300 50  0001 C CNN
F 3 "" H 6650 3100 50  0001 C CNN
F 4 "TPS2051CDBVR" H 6700 2800 50  0001 C CNN "MPN"
F 5 "595-TPS2051CDBVR" H 6700 2800 50  0001 C CNN "Mouser No"
F 6 "https://www.mouser.fr/ProductDetail/Texas-Instruments/TPS2051CDBVR?qs=PF3AD18CSE5vi2HeWLJCmw%3D%3D" H 6700 2800 50  0001 C CNN "URL (Mouser)"
F 7 "https://lcsc.com/product-detail/Power-Distribution-Switches_Texas-Instruments-TPS2051CDBVR_C129581.html" H 6700 2800 50  0001 C CNN "URL"
	1    6700 2800
	1    0    0    -1  
$EndComp
Connection ~ 6200 2600
Text HLabel 4450 2250 2    50   Input ~ 0
USB_D+
Text HLabel 4450 3450 2    50   Input ~ 0
USB_D-
Text GLabel 5100 3200 3    50   Input ~ 0
SHIELD
NoConn ~ 4700 3000
$EndSCHEMATC
