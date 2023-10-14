# A FPGA on a NuBus card...

## Goal

The goal of this repository is to be able to interface a modern (2021 era) [FPGA](https://en.wikipedia.org/wiki/Field-programmable_gate_array) with a [NuBus](https://en.wikipedia.org/wiki/NuBus) host, specifically Apple's [Macintosh II](https://en.wikipedia.org/wiki/Macintosh_II_family) and [Macintosh Quadra](https://en.wikipedia.org/wiki/Macintosh_Quadra). NuBus was widely used by Apple and a little by others (such as NeXT), but was progressively displaced by PCI from the mid-90s onward, and is thoroughly obsolete.

So unless you're a retrocomputing enthusiast with such a machine, this is useless. If you are such an enthusiast, then maybe the ability to connect a modern LCD monitor using a digital interface to an old Macintosh might be of interest to you.

This project was 'spun off' the [SBusFPGA](https://github.com/rdolbeau/SBusFPGA), a similar project for the SBus used in Sun's SPARCstation.

## Current status

First prototype is working in a Quadra 650, running MacOS 8.1. It implements a single-screen-resolution, windowboxed multi-resolution, depth-switchable (1/2/4/8/16/32 bits) framebuffer over DVI-in-HDMI-connector (will work with any HDMI-compliant monitor). The framebuffer can be used as secondary/primary/only framebuffer in the machine running OS8.1. Qemu tests indicate this should work with 7.1 & 7.5/7.6 as well. An alternate HDMI PHY also supports audio, enabled as a 8/16 bits, mono/stereo, 44.1 kHz output component in MacOS.

Some basic acceleration now exists for 8/16/32 bits, doing rectangle screen-to-screen blits and pattern rectangle fills. 1/2/4 bits also has some acceleration, but only for byte-aligned cases.

There's also a basic RAM Disk using the 248 MiB of SDRAM not used by the framebuffer. The driver can use either synchronous direct access to the memory by the CPU, or asynchronous using DMA (using 16-bytes blocks). Frustratingly, the direct access methode seems faster.

## The hardware

Directory 'nubus-to-ztex'

The (now obsolete) V1.0 custom board is a NuBus-compliant (I hope...) board, designed to receive a [ZTex USB-FPGA Module 2.13](https://www.ztex.de/usb-fpga-2/usb-fpga-2.13.e.html) as a daughterboard. The ZTex module contains the actual FPGA (Artix-7), some RAM, programming hardware, etc. The NuBus board contains level-shifters & drivers ICs to interface between the NuBus signals and the FPGA, a CPLD handling some level-shifting & the bus mastering arbitration, a serial header, two user Leds, 14 debug Leds tied to specific NuBus or CPLD/FPGA signals, a JTAG header, a USB micro-B connector, a VGA chip & connector, and a HDMI chip & connector. It supports every NuBus feature except the optional parity (i.e. it can do both slave and master modes). The V1.0 board is in commit 3f3371a. The CPLD solution works but is annoying as it requires older Xilinx software (ISE 14.7) and dedicated JTAG programmer to use.

The current board is V1.2. It drops the CPLD and VGA port. Bus arbitration is now done inside the FPGA. It gains a micro-sd slot, and a custom expansion connector that is based (and compatible with, with more signals) PMod. It supports the same accelerated HDMI framebuffer and RAM Disk. Optionally, The Declaration Rom can be stored in a Flash NOR chip connected ot the PMOd expansion connector (easier for working on embedded driver in the DeclRom). The ROM can alternately be stored in a sector of the config flash from the ZTex board.

The new (July 2023) [ZTex USB-FPGA Module 2.12](https://www.ztex.de/usb-fpga-2/usb-fpga-2.12.e.html) should be compatible with all *FPGA, but has not yet been tested.

The PCBs were designed with Kicad 5.1


## The gateware (Migen)

Directory 'sbus-to-ztex-gateware'

The gateware is written in the Migen language, choosen because that's what [Litex](https://github.com/enjoy-digital/litex/) uses.
It implements a simple CPU-less Litex SoC built around a Wishbone bus, with a custom bridge between the NuBus and the Wishbone.

A Declaration ROM, a SDRAM controller ([litedram](https://github.com/enjoy-digital/litedram) to the on-board DDR3), and the 'Goblin' multi-depth framebuffer can be connected to that bus. Other devices could be added, see the SBusFPGA or the [Common](https://github.com/rdolbeau/VintageBusFPGA_Common) directory, but the software support is missing; vintage System 7/MacOS 8 are not as welcoming to new devices as modern NetBSD. Theoretically, quite a bit of code originally written to support the SBusFPGA in NetBSD/sparc could be reused for similar devices in NetBSD/mac68k, but it has not happened yet.

The SDRAM has its own custom DMA controller, using native Litedram interface to the memory, and some FIFO to/from the NuBus. A custom MacOS driver exposes it as a volatile drive. Driver can use synchronous direct accesses from the CPU (using the NuBus's superslot area), or asynchronous (interrupt-driven) DMA transfers using NuBus 1x block transfers.

## The software

The Declaration ROM is in the subdirectory VintageBusFPGA_Common/DeclROM and includes the driver needed for the unaccelerated framebuffer and the RAM Disk. It needs the [Retro68](https://github.com/autc04/Retro68) toolchain to build.

The code for the NuBusFPGAInit (which should be renamed and enables acceleration) is in NuBusFPGAInit/, and will need a CodeWarrior INIT project to build, on a real Macintosh or an emulated one using e.g. Qemu. It enables graphic acceleration.

The code for the Audio component (which enables audio support over HDMI) is in NuBusFPGAHDMIAudio/.

## FAQ

* Can the framebuffer change resolution ?
 No and yes. No, it cannot change the resolution outputed through the HDMI connector by software. That is currently 'gatewired' into the FPGA configuration, so the board needs a new bitstream to change resolution. Yes, you can change the resolution in System 7 / MacOS 8 by software, but the new resolution is 'windowbowed' in the middle of the screen (e.g. it can display 640x480 surrounded by lots of black pixels in the middle of a Full HD LCD).
 This is a 'gateware' (configuration of the FPGA) limitation. Changing the output resolution requires changing the pixel clock, which is possible but not easy to do. There is currently no plan to remove that limitation, but the gateware is open-source and contributions are welcome :-)

* Is USB supported ?
 No. There is a USB connector, but it is currently useless. The gateware could include a USB OHCI host device, and that is supported in the SBusFPGA under NetBSD. However, no Apple OS running on a 68k Mac has any support for USB, so it would require an entire USB stack to be ported, which is a huge undertaking. Also, NuBus is quite a slow bus even by early 2000s standard, and USB OHCI does a lot of DMA all the time, which would use up most if not all (or maybe more than all!) the available bandwidth. There might be some support in NetBSD/mac68k eventually just to test feasibility, but it even there it's unlikely to be useful.

* Is micro-sd supported ?
 Not yet. Hopefully at some point the micro-sd card will be usable as permanent storage in System 7/MacOS 8, but so far it's not working.

* Where is the ROM stored ?
 By default the Declaration ROM is stored inside the FPGA bitstream, so the bitstream must be regenerated for every ROM change. It is possible to store it in a [SPI](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) Flash NOR chip instead, connected via the expansion connector ([PMod](https://digilent.com/reference/pmod/start)-like) at the back of the NuBusFPGA. My own PMod featuring a SPI Flash NOR and an I2C temperature monitoris available in the [VintageBusFPGA_Common](https://github.com/rdolbeau/VintageBusFPGA_Common) repository, along with an adapter board to program the SPI FLash NOR through the SPI interface of a Raspberry Pi and [flashrom](https://www.flashrom.org/Flashrom).

* Is I2C supported ?
 No. Like USB, I2C doesn't have support in System 7/MacOS 8. It's a lot simpler than USB though. Reading values from a lm75-compatible temperature monitor from System 7/MacOS 8 might be doable, but isn't currently planned. Support for NetBSD/mac68k should be reasonably easy to add as it's already supported in NetBSD/sparc for the SBusFPGA, and unlike USB there's no issue with bandwidth-hungry DMA.

* How about adding Ethernet ?
 Software is the issue. Ethernet is supported by the gateware infrastructure, and a prototype design to add Fast Ethernet via RMII through the expansion connector is available. However, there is currently no software support for it. There's some documentation from Apple, and there's [an example driver available](http://www.mactcp.org.nz/ethernet.html), but the System 7/MacOS 8 driver for LiteEth is still to be written.

* Why slow NuBus, when PDS is so much faster ?
 NuBus is well documented, and electrically quite isolated from the rest of the machine. Safer to play with than PDS which is directly connected to the CPU. And the connector for it it still in general use and easy to get. And NuBus is available on multiple generations of machines.
 My primary machine for this is a Quadra 650, with a 68040 and the associated PDS. Unfortunately, the connector for that PDS is near impossible to get nowadadays ([specifications are there](https://tinkerdifferent.com/resources/specifications-for-the-quadra-pds-connector.124/)). '030 PDS uses 120-pins DIN 41612, similar to bur larger than NuBus' 96-pins. They are also available, but less common. But there is a catch - although sharing a connector board-side, the IIsi, SE/30 and IIfx pinouts are slightly different. And the LCIII is completely different.
 Also - [IIsiFPGA](https://github.com/rdolbeau/IIsiFPGA) :-)
