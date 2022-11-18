EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 8 8
Title "sbus-to-ztex blinkey stuff"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Notes 7300 2850 0    50   ~ 0
Dual-row "extended" Pmod\nExternal, in line w/ the carrier
$Comp
L Connector_Generic:Conn_02x08_Odd_Even J8
U 1 1 63467144
P 7450 3700
F 0 "J8" H 7500 4217 50  0000 C CNN
F 1 "SMH-108-02-L-D (Pmod 2x8 F)" H 7500 4126 50  0000 C CNN
F 2 "For_SeeedStudio:SAMTEC-SMH-108-02-X-D" H 7450 3700 50  0001 C CNN
F 3 "~" H 7450 3700 50  0001 C CNN
F 4 "SMH-108-02-L-D" H 7450 3700 50  0001 C CNN "MPN"
F 5 "https://www.mouser.fr/ProductDetail/Samtec/SMH-108-02-L-D?qs=%252BZP6%2F%252BtExtAyrMiVCu9Apg%3D%3D" H 7450 3700 50  0001 C CNN "URL"
	1    7450 3700
	-1   0    0    1   
$EndComp
Text GLabel 7150 3500 0    50   Input ~ 0
PMOD-5
Text GLabel 7150 3600 0    50   Input ~ 0
PMOD-7
Text GLabel 7150 3700 0    50   Input ~ 0
PMOD-9
Text GLabel 7150 3800 0    50   Input ~ 0
PMOD-11
Text GLabel 7650 3800 2    50   Input ~ 0
PMOD-12
Text GLabel 7650 3500 2    50   Input ~ 0
PMOD-6
Text GLabel 7650 3600 2    50   Input ~ 0
PMOD-8
Text GLabel 7650 3700 2    50   Input ~ 0
PMOD-10
$Comp
L power:GND #PWR0151
U 1 1 634673C0
P 8150 3400
F 0 "#PWR0151" H 8150 3150 50  0001 C CNN
F 1 "GND" H 8155 3227 50  0000 C CNN
F 2 "" H 8150 3400 50  0001 C CNN
F 3 "" H 8150 3400 50  0001 C CNN
	1    8150 3400
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0152
U 1 1 634673C6
P 7950 3300
F 0 "#PWR0152" H 7950 3150 50  0001 C CNN
F 1 "+3V3" H 7965 3473 50  0000 C CNN
F 2 "" H 7950 3300 50  0001 C CNN
F 3 "" H 7950 3300 50  0001 C CNN
	1    7950 3300
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 634673D3
P 8150 3250
AR Path="/5F679B53/634673D3" Ref="C?"  Part="1" 
AR Path="/5F6B165A/634673D3" Ref="C?"  Part="1" 
AR Path="/61631F14/634673D3" Ref="C?"  Part="1" 
AR Path="/62CC4C0A/634673D3" Ref="C15"  Part="1" 
F 0 "C15" H 8175 3350 50  0000 L CNN
F 1 "100nF" H 8175 3150 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 8188 3100 50  0001 C CNN
F 3 "" H 8150 3250 50  0000 C CNN
F 4 "www.yageo.com" H 8150 3250 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 8150 3250 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 8150 3250 50  0001 C CNN "Mouser"
F 7 "?" H 8150 3250 50  0001 C CNN "Digikey"
F 8 "" H 8150 3250 50  0001 C CNN "LCSC"
F 9 "?" H 8150 3250 50  0001 C CNN "Koncar"
F 10 "TB" H 8150 3250 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    8150 3250
	1    0    0    -1  
$EndComp
Wire Wire Line
	7950 3300 8050 3300
Wire Wire Line
	8050 3300 8050 3100
Wire Wire Line
	8050 3100 8150 3100
Text GLabel 7650 3900 2    50   Input ~ 0
PMOD-14
Text GLabel 7650 4000 2    50   Input ~ 0
PMOD-16
Text GLabel 7150 3900 0    50   Input ~ 0
PMOD-13
Text GLabel 7150 4000 0    50   Input ~ 0
PMOD-15
Wire Notes Line
	6700 3850 8100 3850
Wire Notes Line
	8100 3850 8100 4050
Wire Notes Line
	8100 4050 6700 4050
Wire Notes Line
	6700 4050 6700 3850
Text Notes 8100 4050 0    50   ~ 0
Extra Pins
Wire Wire Line
	7150 3300 7650 3300
Wire Wire Line
	7650 3300 7950 3300
Connection ~ 7650 3300
Connection ~ 7950 3300
Wire Wire Line
	7150 3400 7650 3400
Wire Wire Line
	7650 3400 8150 3400
Connection ~ 7650 3400
Connection ~ 8150 3400
$EndSCHEMATC
