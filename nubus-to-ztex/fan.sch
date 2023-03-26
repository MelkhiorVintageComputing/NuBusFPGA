EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 6 9
Title "nubus-to-ztex extra conenctors (fan, ...)"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x03_Male J7
U 1 1 60E1E49E
P 4400 4750
F 0 "J7" H 4506 5028 50  0000 C CNN
F 1 "640456-3 (Fan)" H 4506 4937 50  0000 C CNN
F 2 "Connector_Molex:Molex_KK-254_AE-6410-03A_1x03_P2.54mm_Vertical" H 4400 4750 50  0001 C CNN
F 3 "~" H 4400 4750 50  0001 C CNN
F 4 "22-27-2031" H 4400 4750 50  0001 C CNN "MPN-ALT"
F 5 "Molex" H 4400 4750 50  0001 C CNN "Manufacturer-ALT"
F 6 "https://www.mouser.fr/ProductDetail/Molex/22-27-2031?qs=%2Fha2pyFadugXOaGYK9vaczm7nZ04txhJn3OGcnGWT3U=" H 4400 4750 50  0001 C CNN "URL-ALT"
F 7 "640456-3" H 4400 4750 50  0001 C CNN "MPN"
F 8 "TE Connectivity" H 4400 4750 50  0001 C CNN "Manufacturer"
F 9 "https://www.lcsc.com/product-detail/Wire-To-Board-Wire-To-Wire-Connector_TE-Connectivity-640456-3_C86503.html" H 4400 4750 50  0001 C CNN "URL"
F 10 "DNP" H 4400 4750 50  0000 C CNN "DNP"
	1    4400 4750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 60E1EC2C
P 4600 4650
F 0 "#PWR0107" H 4600 4400 50  0001 C CNN
F 1 "GND" V 4605 4522 50  0000 R CNN
F 2 "" H 4600 4650 50  0001 C CNN
F 3 "" H 4600 4650 50  0001 C CNN
	1    4600 4650
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR0108
U 1 1 60E1ED6C
P 4600 4750
F 0 "#PWR0108" H 4600 4600 50  0001 C CNN
F 1 "+5V" V 4615 4878 50  0000 L CNN
F 2 "" H 4600 4750 50  0001 C CNN
F 3 "" H 4600 4750 50  0001 C CNN
	1    4600 4750
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0109
U 1 1 60E1FA97
P 4600 4850
F 0 "#PWR0109" H 4600 4600 50  0001 C CNN
F 1 "GND" V 4605 4722 50  0000 R CNN
F 2 "" H 4600 4850 50  0001 C CNN
F 3 "" H 4600 4850 50  0001 C CNN
	1    4600 4850
	0    -1   -1   0   
$EndComp
$Comp
L Device:C C?
U 1 1 60E24715
P 5150 4800
AR Path="/5F69F4EF/60E24715" Ref="C?"  Part="1" 
AR Path="/5F6B165A/60E24715" Ref="C?"  Part="1" 
AR Path="/61B99D2C/60E24715" Ref="C28"  Part="1" 
F 0 "C28" H 5175 4900 50  0000 L CNN
F 1 "47uF 10V 1206" H 5175 4700 50  0000 L CNN
F 2 "Capacitor_SMD:C_1206_3216Metric" H 5188 4650 50  0001 C CNN
F 3 "" H 5150 4800 50  0000 C CNN
F 4 "C2012X5R1A476MTJ00E" H 5150 4800 50  0001 C CNN "MPN-ALT"
F 5 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_TDK-C2012X5R1A476MTJ00E_C76636.html" H 5150 4800 50  0001 C CNN "URL-ALT"
F 6 "CL31A476MPHNNNE" H 5150 4800 50  0001 C CNN "MPN"
F 7 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Samsung-Electro-Mechanics-CL31A476MPHNNNE_C96123.html" H 5150 4800 50  0001 C CNN "URL"
	1    5150 4800
	1    0    0    -1  
$EndComp
Wire Wire Line
	4600 4750 5150 4750
Wire Wire Line
	5150 4750 5150 4650
Connection ~ 4600 4750
Wire Wire Line
	4600 4850 5150 4850
Wire Wire Line
	5150 4850 5150 4950
Connection ~ 4600 4850
Text Notes 3950 4750 0    50   ~ 0
5V Fan
$EndSCHEMATC
