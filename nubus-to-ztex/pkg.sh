#!/bin/bash

GERBER_FILES="
nubus-to-ztex-B_Cu.gbr
nubus-to-ztex-B_Mask.gbr
nubus-to-ztex-B_Paste.gbr
nubus-to-ztex-B_SilkS.gbr
nubus-to-ztex-Edge_Cuts.gbr
nubus-to-ztex-F_Cu.gbr
nubus-to-ztex-F_Mask.gbr
nubus-to-ztex-F_Paste.gbr
nubus-to-ztex-F_SilkS.gbr
nubus-to-ztex-In1_Cu.gbr
nubus-to-ztex-In2_Cu.gbr"

POS_FILES="nubus-to-ztex-top.pos"
# nubus-to-ztex-bottom.pos

DRL_FILES="nubus-to-ztex-NPTH.drl nubus-to-ztex-PTH.drl nubus-to-ztex-PTH-drl_map.ps nubus-to-ztex-NPTH-drl_map.ps"

FILES="${GERBER_FILES} ${POS_FILES} ${DRL_FILES} top.pdf nubus-to-ztex.d356 nubus-to-ztex.csv"
# bottom.pdf

echo $FILES

KICAD_PCB=nubus-to-ztex.kicad_pcb

ABORT=no
for F in $FILES; do 
    if test \! -f $F || test $KICAD_PCB -nt $F; then
	echo "Regenerate file $F"
	ABORT=yes
    fi
done

if test $ABORT == "yes"; then
    exit -1;
fi

zip nubus-to-ztex.zip $FILES top.jpg bottom.jpg
