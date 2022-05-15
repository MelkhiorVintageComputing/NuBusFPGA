OUTPUT_ARCH( "riscv" )
SECTIONS
{
  . = 0xF0910000;
  .text : { *(.text) }
}
