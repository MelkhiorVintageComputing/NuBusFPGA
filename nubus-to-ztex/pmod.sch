EESchema Schematic File Version 4
LIBS:nubus-to-ztex-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 9 9
Title "sbus-to-ztex blinkey stuff"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector_Generic:Conn_02x06_Odd_Even J9
U 1 1 618B4A38
P 5650 3400
F 0 "J9" H 5700 3817 50  0000 C CNN
F 1 "Conn_02x06_Odd_Even" H 5700 3726 50  0000 C CNN
F 2 "For_SeeedStudio:PinSocket_2x06_P2.54mm_Horizontal_For_SeeedStudio" H 5650 3400 50  0001 C CNN
F 3 "~" H 5650 3400 50  0001 C CNN
F 4 "A2541HWR-2x6P" H 5650 3400 50  0001 C CNN "MPN"
F 5 "https://lcsc.com/product-detail/Pin-Header-Female-Header_Changjiang-Connectors-A2541HWR-2x6P_C239357.html" H 5650 3400 50  0001 C CNN "URL"
	1    5650 3400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 3200 5950 3200
Wire Wire Line
	5950 3200 6250 3200
Connection ~ 5950 3200
Wire Wire Line
	5450 3300 5950 3300
Wire Wire Line
	5950 3300 6450 3300
Connection ~ 5950 3300
$Comp
L power:GND #PWR0129
U 1 1 618B4A45
P 6450 3300
F 0 "#PWR0129" H 6450 3050 50  0001 C CNN
F 1 "GND" H 6455 3127 50  0000 C CNN
F 2 "" H 6450 3300 50  0001 C CNN
F 3 "" H 6450 3300 50  0001 C CNN
	1    6450 3300
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0130
U 1 1 618B4A4B
P 6250 3200
F 0 "#PWR0130" H 6250 3050 50  0001 C CNN
F 1 "+3V3" H 6265 3373 50  0000 C CNN
F 2 "" H 6250 3200 50  0001 C CNN
F 3 "" H 6250 3200 50  0001 C CNN
	1    6250 3200
	1    0    0    -1  
$EndComp
Text GLabel 5950 3700 2    50   Input ~ 0
PMOD-12
Text GLabel 5450 3400 0    50   Input ~ 0
PMOD-5
Text GLabel 5950 3400 2    50   Input ~ 0
PMOD-6
Text GLabel 5450 3500 0    50   Input ~ 0
PMOD-7
Text GLabel 5950 3500 2    50   Input ~ 0
PMOD-8
Text GLabel 5450 3600 0    50   Input ~ 0
PMOD-9
Text GLabel 5950 3600 2    50   Input ~ 0
PMOD-10
Text GLabel 5450 3700 0    50   Input ~ 0
PMOD-11
$Comp
L Device:C C?
U 1 1 618B4A60
P 6450 3150
AR Path="/5F679B53/618B4A60" Ref="C?"  Part="1" 
AR Path="/5F6B165A/618B4A60" Ref="C?"  Part="1" 
AR Path="/61631F14/618B4A60" Ref="C41"  Part="1" 
AR Path="/62CC4C0A/618B4A60" Ref="C12"  Part="1" 
F 0 "C12" H 6475 3250 50  0000 L CNN
F 1 "100nF" H 6475 3050 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 6488 3000 50  0001 C CNN
F 3 "" H 6450 3150 50  0000 C CNN
F 4 "www.yageo.com" H 6450 3150 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 6450 3150 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 6450 3150 50  0001 C CNN "Mouser"
F 7 "?" H 6450 3150 50  0001 C CNN "Digikey"
F 8 "?" H 6450 3150 50  0001 C CNN "LCSC"
F 9 "?" H 6450 3150 50  0001 C CNN "Koncar"
F 10 "TB" H 6450 3150 50  0001 C CNN "Side"
	1    6450 3150
	1    0    0    -1  
$EndComp
Connection ~ 6450 3300
Wire Wire Line
	6250 3200 6350 3200
Wire Wire Line
	6350 3200 6350 3000
Wire Wire Line
	6350 3000 6450 3000
Connection ~ 6250 3200
$EndSCHEMATC
