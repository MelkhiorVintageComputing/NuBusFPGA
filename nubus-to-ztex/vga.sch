EESchema Schematic File Version 4
LIBS:nubus-to-ztex-cache
EELAYER 26 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 7 10
Title "nubus-to-ztex VGA"
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 8000 4900 0    50   Input ~ 0
SHIELD
$Comp
L power:GND #PWR0131
U 1 1 61988E37
P 8000 5200
F 0 "#PWR0131" H 8000 4950 50  0001 C CNN
F 1 "GND" H 8005 5027 50  0000 C CNN
F 2 "" H 8000 5200 50  0001 C CNN
F 3 "" H 8000 5200 50  0001 C CNN
	1    8000 5200
	1    0    0    -1  
$EndComp
Wire Wire Line
	8250 5200 8000 5200
Wire Wire Line
	8250 4900 8000 4900
$Comp
L Device:C C39
U 1 1 619889C3
P 8250 5050
F 0 "C39" H 8365 5096 50  0000 L CNN
F 1 "1 uF (250+V)" H 8365 5005 50  0000 L CNN
F 2 "Capacitor_THT:CP_Radial_D6.3mm_P2.50mm" H 8288 4900 50  0001 C CNN
F 3 "~" H 8250 5050 50  0001 C CNN
F 4 "860021373002" H 8250 5050 50  0001 C CNN "MPN-ALT"
F 5 "https://www2.mouser.com/ProductDetail/Wurth-Elektronik/860021373002?qs=0KOYDY2FL28tNXbPyU6hsg%3D%3D" H 8250 5050 50  0001 C CNN "URL-ALT"
F 6 "KM010M400E110A" H 8250 5050 50  0001 C CNN "MPN"
F 7 "https://lcsc.com/product-detail/Aluminum-Electrolytic-Capacitors-Leaded_Capxon-International-Elec-KM010M400E110A_C59365.html" H 8250 5050 50  0001 C CNN "URL"
	1    8250 5050
	1    0    0    -1  
$EndComp
Connection ~ 8000 5200
$Comp
L Device:R R33
U 1 1 61988921
P 8000 5050
F 0 "R33" H 8070 5096 50  0000 L CNN
F 1 "1M" H 8070 5005 50  0000 L CNN
F 2 "Resistor_SMD:R_1210_3225Metric" V 7930 5050 50  0001 C CNN
F 3 "~" H 8000 5050 50  0001 C CNN
F 4 "RC1210FR-071ML" H 8000 5050 50  0001 C CNN "MPN-ALT"
F 5 "https://lcsc.com/product-detail/Chip-Resistor-Surface-Mount_YAGEO-RC1210FR-071ML_C470029.html" H 8000 5050 50  0001 C CNN "URL-ALT"
F 6 "1210W2F1004T5E" H 8000 5050 50  0001 C CNN "MPN"
F 7 "https://www.lcsc.com/product-detail/Chip-Resistor-Surface-Mount_UNI-ROYAL-Uniroyal-Elec-1210W2F1004T5E_C620664.html" H 8000 5050 50  0001 C CNN "URL"
	1    8000 5050
	1    0    0    -1  
$EndComp
$EndSCHEMATC
