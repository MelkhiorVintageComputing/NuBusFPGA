EESchema Schematic File Version 4
LIBS:nubus-to-ztex-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 8 8
Title "sbus-to-ztex sdcard"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L power:GND #PWR0124
U 1 1 58DA7C71
P 5450 5450
F 0 "#PWR0124" H 5450 5200 50  0001 C CNN
F 1 "GND" H 5450 5300 50  0000 C CNN
F 2 "" H 5450 5450 50  0000 C CNN
F 3 "" H 5450 5450 50  0000 C CNN
	1    5450 5450
	1    0    0    -1  
$EndComp
$Comp
L power:+3V3 #PWR0125
U 1 1 58DA7C72
P 5450 4600
F 0 "#PWR0125" H 5450 4450 50  0001 C CNN
F 1 "+3V3" H 5450 4740 50  0000 C CNN
F 2 "" H 5450 4600 50  0000 C CNN
F 3 "" H 5450 4600 50  0000 C CNN
	1    5450 4600
	1    0    0    -1  
$EndComp
Text GLabel 3600 5450 0    60   Input ~ 0
SD_D2
Text GLabel 3600 5550 0    60   Input ~ 0
SD_D3
Text GLabel 3600 5150 0    60   Input ~ 0
SD_CMD
Text GLabel 3600 4950 0    60   Input ~ 0
SD_CLK
Text GLabel 3600 5250 0    60   Input ~ 0
SD_D0
Text GLabel 3600 5350 0    60   Input ~ 0
SD_D1
$Comp
L Device:C C10
U 1 1 590C7447
P 5450 5150
F 0 "C10" H 5475 5250 50  0000 L CNN
F 1 "47uF 10V+" H 5475 5050 50  0000 L CNN
F 2 "Capacitor_SMD:C_0805_2012Metric" H 5488 5000 50  0001 C CNN
F 3 "" H 5450 5150 50  0000 C CNN
F 4 "GRM21BR60J476ME15L" H 5450 5150 50  0001 C CNN "MPN-ALT"
F 5 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Murata-Electronics-GRM21BR60J476ME15L_C77072.html" H 5450 5150 50  0001 C CNN "URL-ALT"
F 6 "GRM21BR61A476ME15K" H 5450 5150 50  0001 C CNN "MPN"
F 7 "https://www.lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_Murata-Electronics-GRM21BR61A476ME15K_C2292827.html" H 5450 5150 50  0001 C CNN "URL"
	1    5450 5150
	1    0    0    -1  
$EndComp
$Comp
L 47219-2001:47219-2001 J2
U 1 1 5F6F557B
P 4300 5250
F 0 "J2" H 4300 5817 50  0000 C CNN
F 1 "47219-2001" H 4300 5726 50  0000 C CNN
F 2 "MOLEX_47219-2001:MOLEX_47219-2001" H 4300 5250 50  0001 L BNN
F 3 "https://www.molex.com/webdocs/datasheets/pdf/en-us/0472192001_MEMORY_CARD_SOCKET.pdf" H 4300 5250 50  0001 L BNN
F 4 "47219-2001" H 4300 5250 50  0001 C CNN "MPN"
F 5 "https://eu.mouser.com/ProductDetail/Molex/47219-2001?qs=6kT3pPPHxnVaoXw6Dd7beQ%3D%3D" H 4300 5250 50  0001 C CNN "URL"
	1    4300 5250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5450 5450 5200 5450
Wire Wire Line
	5000 5450 5000 5350
Connection ~ 5000 5450
Wire Wire Line
	5000 5350 5000 5250
Connection ~ 5000 5350
Wire Wire Line
	5000 5250 5000 5150
Connection ~ 5000 5250
Wire Wire Line
	5000 5550 5000 5450
Wire Wire Line
	5450 5300 5450 5450
Connection ~ 5450 5450
Wire Wire Line
	5000 4950 5200 4950
Connection ~ 5450 4950
Wire Wire Line
	5450 4950 5450 5000
$Comp
L Device:C C?
U 1 1 60D77AD6
P 5200 5150
AR Path="/5F679B53/60D77AD6" Ref="C?"  Part="1" 
AR Path="/5F69F4EF/60D77AD6" Ref="C2"  Part="1" 
AR Path="/619D66B7/60D77AD6" Ref="C15"  Part="1" 
AR Path="/62D70B59/60D77AD6" Ref="C9"  Part="1" 
F 0 "C9" H 5225 5250 50  0000 L CNN
F 1 "100nF" H 5225 5050 50  0000 L CNN
F 2 "Capacitor_SMD:C_0603_1608Metric" H 5238 5000 50  0001 C CNN
F 3 "" H 5200 5150 50  0000 C CNN
F 4 "www.yageo.com" H 5200 5150 50  0001 C CNN "MNF1_URL"
F 5 "CC0603KRX7R8BB104" H 5200 5150 50  0001 C CNN "MPN"
F 6 "603-CC603KRX7R8BB104" H 5200 5150 50  0001 C CNN "Mouser"
F 7 "?" H 5200 5150 50  0001 C CNN "Digikey"
F 8 "?" H 5200 5150 50  0001 C CNN "LCSC"
F 9 "?" H 5200 5150 50  0001 C CNN "Koncar"
F 10 "TB" H 5200 5150 50  0001 C CNN "Side"
F 11 "https://lcsc.com/product-detail/Multilayer-Ceramic-Capacitors-MLCC-SMD-SMT_YAGEO-CC0603KRX7R8BB104_C92490.html" H 3000 6050 50  0001 C CNN "URL"
	1    5200 5150
	1    0    0    -1  
$EndComp
Wire Wire Line
	5200 5000 5200 4950
Connection ~ 5200 4950
Wire Wire Line
	5200 4950 5450 4950
Wire Wire Line
	5200 5300 5200 5450
Connection ~ 5200 5450
Wire Wire Line
	5200 5450 5000 5450
Wire Wire Line
	5450 4600 5450 4950
$EndSCHEMATC
