OUTPUT_FORMAT("elf32-m68k");
ENTRY(DeclROMDir);

SECTIONS {
  .text : {
  	/* first the resource dir & related */
    *(.text.begin)
    *(.text .sdata .sdata.* .data .data.* .rodata .rodata.*)

	/* then various sections for the various bits of codes */
	PROVIDE(_sPInitRec = .);
	PROVIDE(entry_sPInitRec = (0x22000000 | ((_sPInitRec - _sRsrc_Board - 12) & 0xFFFFFF))); /* fixme; offset 12 hardwired */
	*(.text.primary_init)
	*(.text.primary)
    PROVIDE(_EndsPInitRec = .);
    PROVIDE(size_sPInitRec = _EndsPInitRec - _sPInitRec);
	
	PROVIDE(_sSInitRec = .);
	PROVIDE(entry_sSInitRec = (0x24000000 | ((_sSInitRec - _sRsrc_Board - 20) & 0xFFFFFF))); /* fixme; offset 20 hardwired */
	*(.text.secondary_init)
	*(.text.secondary)
    PROVIDE(_EndsSInitRec = .);
    PROVIDE(size_sSInitRec = _EndsSInitRec - _sSInitRec);
	
	PROVIDE(_GoboFBDrvrMacOS68020 = .);
	PROVIDE(entry_GoboFBDrvrMacOS68020 = (0x02000000 | ((_GoboFBDrvrMacOS68020 - _GoboFBDrvrDir) & 0xFFFFFF)));
	*(.text.fbdriver_init)
	*(.text.fbdriver)
    PROVIDE(_GoboFBEnd020Drvr = .);
	
	PROVIDE(_RAMDskDrvrMacOS68020 = .);
	PROVIDE(entry_RAMDskDrvrMacOS68020 = (0x02000000 | ((_RAMDskDrvrMacOS68020 - _RAMDskDrvrDir) & 0xFFFFFF)));
	*(.text.dskdriver_init)
	*(.text.dskdriver)
    PROVIDE(_RAMDskEnd020Drvr = .);
	
	PROVIDE(_SDCardDrvrMacOS68020 = .);
	PROVIDE(entry_SDCardDrvrMacOS68020 = (0x02000000 | ((_SDCardDrvrMacOS68020 - _SDCardDrvrDir) & 0xFFFFFF)));
	*(.text.sddriver_init)
	*(.text.sddriver)
    PROVIDE(_SDCardEnd020Drvr = .);

    /* and at the end the ROM block, missing only the CRC */
    . = ALIGN(4);
    *(.romblock)
    PROVIDE(ROMSize = .);
    PROVIDE(RsrcDirOffset = ((0-.)+20) & 0xFFFFFF);
  }
  /DISCARD/ : { *(*) }
}
