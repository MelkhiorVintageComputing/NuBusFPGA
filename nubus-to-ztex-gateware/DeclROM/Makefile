AS=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-as
OBJCOPY=/home/dolbeau/Retro68/build/toolchain/bin/m68k-apple-macos-objcopy

NS816DECLROMDIR=/home/dolbeau/ns816-declrom
NUBUS_CHECKSUM=${NS816DECLROMDIR}/nubus_checksum
PROCESS_ROM=${NS816DECLROMDIR}/process_rom

APPLEINCS=${NS816DECLROMDIR}/atrap.inc ${NS816DECLROMDIR}/declrom.inc ${NS816DECLROMDIR}/globals.inc

all: vid_decl_rom.bin vid_decl_rom.srec

vid_decl_rom.o: vid_decl_rom.s ${APPLEINCS}
	${AS} -march=68020 -mcpu=68020 -I${NS816DECLROMDIR} $< -o $@ -a > vid_decl_rom.l

vid_decl_rom.srec: vid_decl_rom.o
	${OBJCOPY} $< $@ --input-target=elf32-m68k --output-target=srec	

vid_decl_rom.raw: vid_decl_rom.o
	${OBJCOPY} $< $@ --input-target=elf32-m68k --output-target=binary

vid_decl_rom.bin: vid_decl_rom.raw
	${NUBUS_CHECKSUM} --input_file $< --output_file $@ --output_size 4096
