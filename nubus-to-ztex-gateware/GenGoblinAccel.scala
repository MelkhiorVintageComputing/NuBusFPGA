package vexriscv.demo

// CG6Plugin is:
// ./gen_plugin -n CG6 -i data_bitmanip.txt -i data_bitmanip_ZbbOnly.txt -I SH2ADD -I MINU -I MAXU -I REV8 -I CMOV -I CMIX -I FSR -I ZEXTdotH -I SEXTdotB >| CG6.scala
// Goblin Plugins are:
// ./gen_plugin -n Goblin -i data_Zpn.txt -I UKADD8 -I UKSUB8 >| Goblin.scala
// ./gen_plugin -n Goblin -i data_Zxrender_2cycles.txt -I UFMA8VxV >| Goblin2c.scala

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
	  resetVector = 0xF0910000l, // beginning of ROM (NuBus)
          //resetVector = 0x00410000l, // beginning of ROM (SBus)
          relaxedPcCalculation = false,
          prediction = STATIC,
          config = InstructionCacheConfig(
            cacheSize = 256,
            bytePerLine = 16,
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
            cacheSize         = 256,
            bytePerLine       = 16,
            wayCount          = 2,
            addressWidth      = 32,
            cpuDataWidth      = 128,
            memDataWidth      = 128,
            catchAccessError  = false,
            catchIllegal      = false,
            catchUnaligned    = false,
	    pendingMax        = 8, // 64 ; irrelevant? only for SMP?
	    withWriteAggregation = true // required if memDataWidth > 32
          ),
          dBusCmdMasterPipe = false, // prohibited if memDataWidth > 32
	  dBusCmdSlavePipe = true,
          dBusRspSlavePipe = true
	),
        new StaticMemoryTranslatorPlugin(
	  // only cache the sdram memory
          // NuBus
	  ioRange = addr => ((addr(31 downto 28) =/= 0x8) & // SDRAM
                             (addr(31 downto 12) =/= 0xF0902) & // SRAM
                             (addr(31 downto 16) =/= 0xF091) // ROM
                            )
          // SBus
          //ioRange = addr => ((addr(31 downto 28) =/= 0x8) & // SDRAM
          //                   (addr(31 downto 16) =/= 0x0042) & // SRAM
          //                   (addr(31 downto 16) =/= 0x0041) // ROM
          //                  )
        ),
        new DecoderSimplePlugin(
          catchIllegalInstruction = false
        ),
        new RegFileOddEvenPlugin(
          regFileReadyKind = plugin.ASYNC, // FIXME why is even-odd failing with SYNC??? (and what's the difference...)
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
	new CG6Plugin(earlyInjection = false), // full-custom list
	new GoblinPlugin(earlyInjection = false), // full-custom list
	new Goblin2cPlugin(earlyInjection = false), // full-custom list
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
