# A FPGA on a NuBus card...

## Goal

The goal of this repository is to be able to interface a modern (2021 era) [FPGA](https://en.wikipedia.org/wiki/Field-programmable_gate_array) with a [NuBus](https://en.wikipedia.org/wiki/NuBus) host, specifically Apple's [Macintosh II](https://en.wikipedia.org/wiki/Macintosh_II_family) and [Macintosh Quadra](https://en.wikipedia.org/wiki/Macintosh_Quadra). NuBus was widely used by Apple and a little by others (such as NeXT), but was progressively displaced by PCI from the mid-90s onward, and is thoroughly obsolete.

So unless you're a retrocomputing enthusiast with such a machine, this is useless. If you are such an enthusiast, then maybe the ability to connect a modern LCD monitor using a digital interface to an old Macintosh might be of interest to you.

This project was 'spun off' the [SBusFPGA](https://github.com/rdolbeau/SBusFPGA), a similar project for the SBus used in Sun's SPARCstation.

## Current status

First prototype is working in a Quadra 650, running MacOS 8.1. It implements a single-screen-resolution, windowboxed multi-resolution, depth-switchable (1/2/4/8/16/32 bits) framebuffer over DVI-in-HDMI-connector (will work with any HDMI-compliant monitor). The framebuffer can be used as secondary/primary/only framebuffer in the machine running OS8.1. Qemu tests indicate this should work with 7.1 & 7.5/7.6 as well.

Some basic acceleration now exists for 8/16/32 bits, doing rectangle screen-to-screen blits and pattern rectangle fills. 1/2/4 bits also has some acceleration, but only for byte-aligned cases.

There's also a basic RAM Disk using the 248 MiB of SDRAM not used by the framebuffer. The driver can use either synchronous direct access to the memory bt the CPU, or asynchronous using DMA (using 16-bytes blocks). Frustratingly, the direct access methode seems faster.

## The hardware

Directory 'nubus-to-ztex'

The V1.0 custom board is a NuBus-compliant (I hope...) board, designed to receive a [ZTex USB-FPGA Module 2.13](https://www.ztex.de/usb-fpga-2/usb-fpga-2.13.e.html) as a daughterboard. The ZTex module contains the actual FPGA (Artix-7), some RAM, programming hardware, etc. The NuBus board contains level-shifters & drivers ICs to interface between the NuBus signals and the FPGA, a CPLD handling some level-shifting & the bus mastering arbitration, a serial header, two user Leds, 14 debug Leds tied to specific NuBus or CPLD/FPGA signals, a JTAG header, a USB micro-B connector, a VGA chip & connector, and a HDMI chip & connector. It supports every NuBus feature except the optional parity (i.e. it can do both slave and master modes).

The PCB was designed with Kicad 5.0


## The gateware (Migen)

Directory 'sbus-to-ztex-gateware'

The gateware is written in the Migen language, choosen because that's what [Litex](https://github.com/enjoy-digital/litex/) uses.
It implements a simple CPU-less Litex SoC built around a Wishbone bus, with a custom bridge between the NuBus and the Wishbone.

A Declaration ROM, a SDRAM controller ([litedram](https://github.com/enjoy-digital/litedram) to the on-board DDR3), and the 'Goblin' multi-depth framebuffer can be connected to that bus. Other devices could be added, see the SBusFPGA or the [Common](https://github.com/rdolbeau/VintageBusFPGA_Common) directory, but the software support is missing; vintage System 7/MacOS 8 are not as welcoming to new devices as modern NetBSD. Theoretically, quite a bit of code originally written to support the SBusFPGA in NetBSD/sparc could be reused for similar devices in NetBSD/mac68k, but it has not happened yet.

The SDRAM has its own custom DMA controller, using native Litedram interface to the memory, and some FIFO to/from the NuBus. A custom MacOS driver exposes it as a volatile drive. Driver can use synchronous direct accesses from the CPU (using the NuBus's superslot area), or asynchronous (interrupt-driven) DMA transfers using NuBus 1x block transfers.

## The software

The Declaration ROM is in the subdirectory DeclROM and includes the driver needed for the unaccelerated framebuffer and the RAM Disk. It needs the [Retro68](https://github.com/autc04/Retro68) toolchain to build.

The code for the NuBusFPGAInit (which should be renamed) is in NuBusFPGAInit/, and will need a CodeWarrior INIT project to build, on a real Macintosh or an emulated one using e.g. Qemu. It enables graphic acceleration.