AS=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-as
CC=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-gcc
LD=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-ld
STRIP=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-strip
OBJCOPY=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-objcopy
HOSTCC=gcc
HOSTCFLAGS=-O2

ARCHFLAGS=-march=68020 -mcpu=68020
CFLAGS=-O2 -mpcrel

NS816DECLROMDIR=./ns816-declrom
NUBUS_CHECKSUM=${NS816DECLROMDIR}/nubus_checksum
PROCESS_ROM=${NS816DECLROMDIR}/process_rom

APPLEINCS=${NS816DECLROMDIR}/atrap.inc ${NS816DECLROMDIR}/declrom.inc ${NS816DECLROMDIR}/globals.inc

HRES=1920
VRES=1080

CSRC_VIDEO=NuBusFPGADrvr_OpenClose.c NuBusFPGADrvr_Ctrl.c NuBusFPGADrvr_Status.c NuBusFPGAPrimaryInit_Primary.c NuBusFPGAPrimaryInit_RamInit.c NuBusFPGASecondaryInit_Secondary.c
CSRC_RAMDSK=NuBusFPGARAMDskDrvr_OpenClose.c NuBusFPGARAMDskDrvr_Ctrl.c NuBusFPGARAMDskDrvr_Prime.c NuBusFPGARAMDskDrvr_Status.c myrle.c
CSRC=${CSRC_VIDEO} ${CSRC_RAMDSK}
CSRC_ASM=${CSRC:.c=.s}

GEN_ASM=VidRomDef.s VidRomDir.s VidRomName.s VidRomRes.s VidRomRsrcDir.s

all: vid_decl_rom.bin

gen_mode: gen_mode.c
	$(HOSTCC) -Wall ${HOSTCFLAGS} $^ -o $@

${GEN_ASM}: gen_mode
	./gen_mode ${HRES} ${VRES}

$(NUBUS_CHECKSUM): ${NS816DECLROMDIR}/nubus_checksum.cc ${NS816DECLROMDIR}/nubus_crc.cc
	g++ -std=c++11 $^ -lglog -lgflags -labsl_strings -o $@

vid_decl_rom.o: vid_decl_rom.s NuBusFPGADrvr.s NuBusFPGARAMDskDrvr.s ${APPLEINCS} DepVideo.inc ${GEN_ASM}
	rm -f res.inc
	echo -e "HRES=${HRES}\nVRES=${VRES}\n" | tee res.inc
	${AS} ${ARCHFLAGS} -I${NS816DECLROMDIR} $< -o $@ -a > vid_decl_rom.l

myrle.o: myrle.c
	${CC} ${ARCHFLAGS} ${CFLAGS} $< -c -o $@ -DSKIP_MAIN

dump_cpr.s: dump_cpr.c
	${CC} ${ARCHFLAGS} ${CFLAGS} $< -S -o $@ -DSKIP_MAIN
	sed -i -e 's/^\([^a-zA-Z0-9_]*\.globl.*\)/# --- \1/' $@
	sed -i -e 's/\.\(L[0-9][0-9]*\)/.dump_cpr_\1/g' $@

%.o: %.c NuBusFPGADrvr.h
	${CC} ${CFLAGS} $< -c -o $@ -DHRES=${HRES} -DVRES=${VRES}

vid_decl_rom.elf: linker.ld vid_decl_rom.o ${CSRC:.c=.o} # linker script must be first
	${LD} -o $@ -T $^

vid_decl_rom.raw: vid_decl_rom.elf
	${OBJCOPY} $^ $@ --input-target=elf32-m68k --output-target=binary

vid_decl_rom.bin: vid_decl_rom.raw $(NUBUS_CHECKSUM)
	${NUBUS_CHECKSUM} --input_file $< --output_file $@ --output_size 32768
	dd if=dump.cpr of=vid_decl_rom.bin bs=1 conv=notrunc

clean:
	rm -f res.inc ${CSRC_ASM} *.o vid_decl_rom.srec vid_decl_rom.raw vid_decl_rom.dir vid_decl_rom.l VidRom*.s

append_romdir: append_romdir.c
	${HOSTCC} $< -o $@
