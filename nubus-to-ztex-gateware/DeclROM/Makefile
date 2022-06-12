AS=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-as
CC=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-gcc
OBJCOPY=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-objcopy
HOSTCC=gcc

NS816DECLROMDIR=/home/dolbeau/ns816-declrom
NUBUS_CHECKSUM=${NS816DECLROMDIR}/nubus_checksum
PROCESS_ROM=${NS816DECLROMDIR}/process_rom

APPLEINCS=${NS816DECLROMDIR}/atrap.inc ${NS816DECLROMDIR}/declrom.inc ${NS816DECLROMDIR}/globals.inc

HRES=1920
VRES=1080

CSRC_VIDEO=NuBusFPGADrvr_OpenClose.c NuBusFPGADrvr_Ctrl.c NuBusFPGADrvr_Status.c NuBusFPGAPrimaryInit_Primary.c NuBusFPGASecondaryInit_Secondary.c
CSRC_RAMDSK=NuBusFPGARAMDskDrvr_OpenClose.c NuBusFPGARAMDskDrvr_Ctrl.c NuBusFPGARAMDskDrvr_Prime.c NuBusFPGARAMDskDrvr_Status.c myrle.c
CSRC=${CSRC_VIDEO} ${CSRC_RAMDSK}
CSRC_ASM=${CSRC:.c=.s}

all: vid_decl_rom.bin vid_decl_rom.srec

vid_decl_rom.o: vid_decl_rom.s NuBusFPGAPrimaryInit.s NuBusFPGAPrimaryInit_Primary.s NuBusFPGASecondaryInit.s NuBusFPGASecondaryInit_Secondary.s NuBusFPGADrvr.s ${APPLEINCS} ${CSRC_ASM} DepVideo.inc
	rm -f res.inc
	echo -e "HRES=${HRES}\nVRES=${VRES}\n" | tee res.inc
	${AS} -march=68020 -mcpu=68020 -I${NS816DECLROMDIR} $< -o $@ -a > vid_decl_rom.l

NuBusFPGADrvr_OpenClose.s: NuBusFPGADrvr_OpenClose.c NuBusFPGADrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.OpenClose_\1/g' $@

NuBusFPGADrvr_Ctrl.s: NuBusFPGADrvr_Ctrl.c NuBusFPGADrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.Ctrl_\1/g' $@

NuBusFPGADrvr_Status.s: NuBusFPGADrvr_Status.c NuBusFPGADrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.Status_\1/g' $@


NuBusFPGARAMDskDrvr_OpenClose.s: NuBusFPGARAMDskDrvr_OpenClose.c NuBusFPGARAMDskDrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.RDOpenClose_\1/g' $@

NuBusFPGARAMDskDrvr_Prime.s: NuBusFPGARAMDskDrvr_Prime.c NuBusFPGARAMDskDrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.RDPrime_\1/g' $@

NuBusFPGARAMDskDrvr_Ctrl.s: NuBusFPGARAMDskDrvr_Ctrl.c NuBusFPGARAMDskDrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.RDCtrl_\1/g' $@

NuBusFPGARAMDskDrvr_Status.s: NuBusFPGARAMDskDrvr_Status.c NuBusFPGARAMDskDrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.RDStatus_\1/g' $@

myrle.s: myrle.c
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DSKIP_MAIN
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.myrle_\1/g' $@

dump_cpr.s: dump_cpr.c
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DSKIP_MAIN
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.dump_cpr_\1/g' $@


NuBusFPGAPrimaryInit_Primary.s: NuBusFPGAPrimaryInit_Primary.c NuBusFPGADrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.PIPrimary_\1/g' $@

NuBusFPGASecondaryInit_Secondary.s: NuBusFPGASecondaryInit_Secondary.c NuBusFPGADrvr.h
	${CC} -march=68020 -mcpu=68020 -O2 $< -S -o $@ -DHRES=${HRES} -DVRES=${VRES}
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.PISecondary_\1/g' $@

vid_decl_rom.srec: vid_decl_rom.o
	${OBJCOPY} $^ $@ --input-target=elf32-m68k --output-target=srec	

vid_decl_rom.raw: vid_decl_rom.o
	${OBJCOPY} $^ $@ --input-target=elf32-m68k --output-target=binary

vid_decl_rom.dir: vid_decl_rom.raw append_romdir
	cp $< $@
	./append_romdir $@

vid_decl_rom.bin: vid_decl_rom.dir
	${NUBUS_CHECKSUM} --input_file $< --output_file $@ --output_size 32768

clean:
	rm -f res.inc ${CSRC_ASM} *.o vid_decl_rom.srec vid_decl_rom.raw vid_decl_rom.dir vid_decl_rom.l

append_romdir: append_romdir.c
	${HOSTCC} $< -o $@

