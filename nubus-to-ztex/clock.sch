EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 9 9
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	3950 2750 3950 2450
$Comp
L power:GND #PWR0136
U 1 1 64D5A010
P 3175 2750
F 0 "#PWR0136" H 3175 2500 50  0001 C CNN
F 1 "GND" H 3180 2577 50  0000 C CNN
F 2 "" H 3175 2750 50  0001 C CNN
F 3 "" H 3175 2750 50  0001 C CNN
	1    3175 2750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0137
U 1 1 64D5AF8F
P 3950 3350
F 0 "#PWR0137" H 3950 3100 50  0001 C CNN
F 1 "GND" H 3955 3177 50  0000 C CNN
F 2 "" H 3950 3350 50  0001 C CNN
F 3 "" H 3950 3350 50  0001 C CNN
	1    3950 3350
	1    0    0    -1  
$EndComp
Text GLabel 4550 3050 2    50   Input Italic 0
CLK_54_000
NoConn ~ 3650 3050
$Comp
L power:+3V3 #PWR0138
U 1 1 64EA4B87
P 3175 2450
F 0 "#PWR0138" H 3175 2300 50  0001 C CNN
F 1 "+3V3" H 3190 2623 50  0000 C CNN
F 2 "" H 3175 2450 50  0001 C CNN
F 3 "" H 3175 2450 50  0001 C CNN
	1    3175 2450
	1    0    0    -1  
$EndComp
$Comp
L Device:C C?
U 1 1 64F8FAD7
P 3425 2600
AR Path="/5F679B53/64F8FAD7" Ref="C?"  Part="1" 
AR Path="/5F6B165A/64F8FAD7" Ref="C?"  Part="1" 
AR Path="/612D28DD/64F8FAD7" Ref="C?"  Part="1" 
AR Path="/61B62C00/64F8FAD7" Ref="C?"  Part="1" 
AR Path="/64F8CFB4/64F8FAD7" Ref="C13"  Part="1" 
F 0 "C13" H 3450 2700 50  0000 L CNN
F 1 "10nF" H 3450 2500 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 3463 2450 50  0001 C CNN
F 3 "" H 3425 2600 50  0000 C CNN
F 4 "www.yageo.com" H 3425 2600 50  0001 C CNN "MNF1_URL"
F 5 "0603B103K500NT" H 3425 2600 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB103" H 3425 2600 50  0001 C CNN "Mouser"
F 7 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_FH-Guangdong-Fenghua-Advanced-Tech-0603B103K500NT_C57112.html" H 3425 2600 50  0001 C CNN "URL"
	1    3425 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3950 2450 3425 2450
$Comp
L Device:C C?
U 1 1 64F9279B
P 3175 2600
AR Path="/618F532C/64F9279B" Ref="C?"  Part="1" 
AR Path="/618E8C75/64F9279B" Ref="C?"  Part="1" 
AR Path="/64F8CFB4/64F9279B" Ref="C11"  Part="1" 
F 0 "C11" H 3200 2700 50  0000 L CNN
F 1 "100nF" H 3200 2500 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 3213 2450 50  0001 C CNN
F 3 "" H 3175 2600 50  0000 C CNN
F 4 "www.yageo.com" H 3175 2600 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R9BB104" H 3175 2600 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 3175 2600 50  0001 C CNN "Mouser"
F 7 "?" H 3175 2600 50  0001 C CNN "Digikey"
F 8 "" H 3175 2600 50  0001 C CNN "LCSC"
F 9 "?" H 3175 2600 50  0001 C CNN "Koncar"
F 10 "TB" H 3175 2600 50  0001 C CNN "Side"
F 11 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R9BB104_C14663.html" H 3175 2600 50  0001 C CNN "URL"
	1    3175 2600
	1    0    0    -1  
$EndComp
Wire Wire Line
	3425 2450 3175 2450
Connection ~ 3425 2450
Connection ~ 3175 2450
Wire Wire Line
	3425 2750 3175 2750
Connection ~ 3175 2750
$Comp
L Device:R R?
U 1 1 65008AD6
P 4400 3050
AR Path="/5F6B165A/65008AD6" Ref="R?"  Part="1" 
AR Path="/5F679B53/65008AD6" Ref="R?"  Part="1" 
AR Path="/5F69F4EF/65008AD6" Ref="R?"  Part="1" 
AR Path="/60D72F2C/65008AD6" Ref="R?"  Part="1" 
AR Path="/619A5A47/65008AD6" Ref="R?"  Part="1" 
AR Path="/61B604DE/65008AD6" Ref="R?"  Part="1" 
AR Path="/64F8CFB4/65008AD6" Ref="R8"  Part="1" 
F 0 "R8" V 4480 3050 50  0000 C CNN
F 1 "27" V 4400 3050 50  0000 C CNN
F 2 "Resistor_SMD:R_0603_1608Metric" V 4330 3050 50  0001 C CNN
F 3 "" H 4400 3050 50  0000 C CNN
F 4 "0603WAF270JT5E" V 4400 3050 50  0001 C CNN "MPN"
F 5 "ERJ-3EKF27R0V" V 4400 2450 50  0001 C CNN "MPN-ALT"
F 6 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-0603WAF270JT5E_C25190.html" V 4400 3050 50  0001 C CNN "URL"
	1    4400 3050
	0    1    1    0   
$EndComp
$Comp
L Oscillator:ASE-xxxMHz X1
U 1 1 641BE3FE
P 3950 3050
F 0 "X1" H 4200 3225 50  0000 L CNN
F 1 "ASE-xxxMHz" H 4175 2875 50  0000 L CNN
F 2 "Oscillator:Oscillator_SMD_Abracon_ASE-4Pin_3.2x2.5mm" H 4650 2700 50  0001 C CNN
F 3 "http://www.abracon.com/Oscillators/ASV.pdf" H 3850 3050 50  0001 C CNN
F 4 "SX3M54.000M20F30TNN" H 3950 3050 50  0001 C CNN "MPN"
F 5 "https://www.lcsc.com/product-detail/Oscillators_Shenzhen-SCTF-Elec-SX3M54-000M20F30TNN_C2901593.html" H 3950 3050 50  0001 C CNN "URL"
	1    3950 3050
	1    0    0    -1  
$EndComp
$EndSCHEMATC
