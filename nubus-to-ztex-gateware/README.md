# Compiling

## Rom

Compiling the Declaration Rom (in DeclRom) requires the [Retro68](https://github.com/autc04/Retro68) toolchain.

The beginning of the Makefile in DeclROM/ needs to be adapted to point to the toolchain.

## Microcode for acceleration

Compiling the acceleration code for the Framebuffer requires a RISC-V toolchain.

The script blit_goblin_nubus.sh in VintageBusFPGA_Common/ needs to be adapted to point to the appropriate toolchain.

## Bitstream

Generating the bitstream requires Vivado, 2022 or newer should do. It also requires Litex, see for instance [Linux-on-Litex-VexRiscv](https://github.com/litex-hub/linux-on-litex-vexriscv).

You will need LItex working, and an usable Vivado in yout $PATH.

## Known issues

### dependencies

There's an interesting issue where you need the DeclRom to generate the bitstream (by defualt the Rom is emebedded in it), but you need CSR headers created during the generation of the bitstream to compile the Declaration Rom. A simple workaround is to create a Rom file with a kilobyte or two of fake data, generate the bitstream, then compile the declaration rom, then re-generate the bitsteam with the proper Rom.

### timings

While the main part of the design should be fine in terms of timings, some of the HDMI part isn't. At FullHD resolution (1920x1080 @ 60Hz)), It is 'normal' to have -0.808ns of WPWS, with 9 endpoints failing, in the hdmi5x_clk domain. It doesn't seem to affect the display. This is using the V1.2 54 MHz clock to Bank 34; using the primary 48 MHz clock instead (as in V1.0), the hdmi_clk is a 148.8 MHz instead of 148.5 and the WPPS is -0.811 instead (the 5x clock is at 744 Mhz instead of 742.5 MHz).
