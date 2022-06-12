package vexriscv.demo

// CG6 Plugin is:
// ./gen_plugin -n CG6 -i data_bitmanip.txt -i data_bitmanip_ZbbOnly.txt -I SH2ADD -I MINU -I MAXU -I REV8 -I CMOV -I CMIX -I FSR -I SEXTdotB >| CG6.scala

import vexriscv.plugin._
import vexriscv.{VexRiscv, VexRiscvConfig, plugin}
import spinal.core._
import vexriscv.ip.InstructionCacheConfig

import spinal.lib._
import spinal.lib.sim.Phase
import vexriscv.ip.{DataCacheConfig, InstructionCacheConfig}
import vexriscv.plugin._

object GenGoblinAccel { // extends App {
  def main(args: Array[String]) {
    val report = SpinalVerilog{
    val config = VexRiscvConfig(
      plugins = List(
        new IBusCachedPlugin(
	  resetVector = 0x70910000, // beginning of ROM
          relaxedPcCalculation = false,
          prediction = STATIC,
          config = InstructionCacheConfig(
            cacheSize = 512,
            bytePerLine = 32,
            wayCount = 1,
            addressWidth = 32,
            cpuDataWidth = 32,
            memDataWidth = 32,
            catchIllegalAccess = false,
            catchAccessFault = false,
            asyncTagMemory = false,
            twoCycleRam = false,
            twoCycleCache = true
          )
        ),
//	new DBusSimplePlugin(
//          catchAddressMisaligned = false,
//          catchAccessFault = false
//	),
        new DBusCachedPlugin(
          config = new DataCacheConfig(
            cacheSize         = 512,
            bytePerLine       = 32,
            wayCount          = 2,
            addressWidth      = 32,
            cpuDataWidth      = 128,
            memDataWidth      = 128,
            catchAccessError  = false,
            catchIllegal      = false,
            catchUnaligned    = false,
	    pendingMax        = 8, // 64
	    withWriteAggregation = true // required if memDataWidth > 32
          ),
          dBusCmdMasterPipe = false, // prohibited if memDataWidth > 32
	  dBusCmdSlavePipe = true,
          dBusRspSlavePipe = true
	),
        new StaticMemoryTranslatorPlugin(
	  // only cache the sdram memory
	  ioRange = addr => ((addr(31 downto 28) =/= 0x8) & // SDRAM
                             (addr(31 downto 12) =/= 0xF0902) & // SRAM
                             (addr(31 downto 16) =/= 0xF091) // ROM
                            )
        ),
        new DecoderSimplePlugin(
          catchIllegalInstruction = false
        ),
        new RegFilePlugin(	
          regFileReadyKind = plugin.SYNC,
          zeroBoot = false
        ),
        new IntAluPlugin,
        new SrcPlugin(
          separatedAddSub = false,
          executeInsertion = true
        ),
        //new LightShifterPlugin,
        new MulPlugin,
	new FullBarrelShifterPlugin,
	//new BitManipZbaPlugin(earlyInjection = false), // sh.add
	//new BitManipZbbPlugin(earlyInjection = false), // zero-ext, min/max, others
	//new BitManipZbtPlugin(earlyInjection = false), // cmov, cmix, funnel
	new CG6Plugin(earlyInjection = false),
        new HazardSimplePlugin(
          bypassExecute           = true,
          bypassMemory            = true,
          bypassWriteBack         = true,
          bypassWriteBackBuffer   = true,
          pessimisticUseSrc       = false,
          pessimisticWriteRegFile = false,
          pessimisticAddressMatch = false
        ),
        new BranchPlugin(
          earlyBranch = false,
          catchAddressMisaligned = false
        ),
        new YamlPlugin("cpu0.yaml")
      )
    )
    
    val cpu = new VexRiscv(config)

      cpu.rework {
        for (plugin <- config.plugins) plugin match {
          case plugin: IBusSimplePlugin => {
            plugin.iBus.setAsDirectionLess() //Unset IO properties of iBus
            master(plugin.iBus.toWishbone()).setName("iBusWishbone")
          }
          case plugin: IBusCachedPlugin => {
            plugin.iBus.setAsDirectionLess()
            master(plugin.iBus.toWishbone()).setName("iBusWishbone")
          }
          case plugin: DBusSimplePlugin => {
            plugin.dBus.setAsDirectionLess()
            master(plugin.dBus.toWishbone()).setName("dBusWishbone")
          }
          case plugin: DBusCachedPlugin => {
            plugin.dBus.setAsDirectionLess()
            master(plugin.dBus.toWishbone()).setName("dBusWishbone")
          }
          case _ =>
        }
      }

      cpu
      }
//report.printPruned()
      }
}
