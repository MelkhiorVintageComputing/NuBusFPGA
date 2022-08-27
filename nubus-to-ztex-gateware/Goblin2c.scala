// WARNING: this is auto-generated code!
// See https://github.com/rdolbeau/VexRiscvBPluginGenerator/
package vexriscv.plugin
import spinal.core._
import vexriscv.{Stageable, DecoderService, VexRiscv}
object Goblin2cPlugin {
	object Goblin2cCtrlEnum extends SpinalEnum(binarySequential) {
		 val CTRL_UFMA8VxV = newElement()
	}
	object Goblin2cCtrl extends Stageable(Goblin2cCtrlEnum())
// Prologue

	def fun_ufma8vxv(rs1: Bits, rs2: Bits, rs3: Bits, low: Bool) : Bits = {
	    val al = low ? rs2( 7 downto  0) | rs2(31 downto 24)
		
	    val h0 = (rs1( 7 downto  0).asUInt * al.asUInt).asBits
	    val h1 = (rs1(15 downto  8).asUInt * al.asUInt).asBits
	    val h2 = (rs1(23 downto 16).asUInt * al.asUInt).asBits
	    val h3 = (rs1(31 downto 24).asUInt * al.asUInt).asBits
		
	    //rs3 ## h3(15 downto  8) ## h2(15 downto  8) ## h1(15 downto  8) ## h0(15 downto  8) // return value

		//var r0 = ((h0 ## B"8'x00").asUInt + h0.asUInt + h0(15 downto 7).asUInt).asBits
		//var r1 = ((h1 ## B"8'x00").asUInt + h1.asUInt + h1(15 downto 7).asUInt).asBits
		//var r2 = ((h2 ## B"8'x00").asUInt + h2.asUInt + h2(15 downto 7).asUInt).asBits
		//var r3 = ((h3 ## B"8'x00").asUInt + h3.asUInt + h3(15 downto 7).asUInt).asBits

	    //rs3 ## r3(23 downto 16) ## r2(23 downto 16) ## r1(23 downto 16) ## r0(23 downto 16) // return value

		rs3 ## h3 ## h2 ## h1 ## h0
	}

	def fun_ufma8vxv2(input: Bits) : Bits = {
		//val rs3 = input(63 downto 32)
		val rs3 = input(95 downto 64)
		val h3 = input(63 downto 48)
		val h2 = input(47 downto 32)
		val h1 = input(31 downto 16)
		val h0 = input(15 downto  0)

		var r0 = ((h0 ## B"8'x00").asUInt + h0.asUInt + h0(15 downto 7).asUInt).asBits
		var r1 = ((h1 ## B"8'x00").asUInt + h1.asUInt + h1(15 downto 7).asUInt).asBits
		var r2 = ((h2 ## B"8'x00").asUInt + h2.asUInt + h2(15 downto 7).asUInt).asBits
		var r3 = ((h3 ## B"8'x00").asUInt + h3.asUInt + h3(15 downto 7).asUInt).asBits
		
	    //val f0 = (input( 7 downto  0).asUInt +| rs3( 7 downto  0).asUInt).asBits.resize(8)
	    //val f1 = (input(15 downto  8).asUInt +| rs3(15 downto  8).asUInt).asBits.resize(8)
	    //val f2 = (input(23 downto 16).asUInt +| rs3(23 downto 16).asUInt).asBits.resize(8)
	    //val f3 = (input(31 downto 24).asUInt +| rs3(31 downto 24).asUInt).asBits.resize(8)
		
	    val f0 = (r0(23 downto 16).asUInt +| rs3( 7 downto  0).asUInt).asBits.resize(8)
	    val f1 = (r1(23 downto 16).asUInt +| rs3(15 downto  8).asUInt).asBits.resize(8)
	    val f2 = (r2(23 downto 16).asUInt +| rs3(23 downto 16).asUInt).asBits.resize(8)
	    val f3 = (r3(23 downto 16).asUInt +| rs3(31 downto 24).asUInt).asBits.resize(8)
	
	    f3 ## f2 ## f1 ## f0 // return value
	}

// End prologue
} // object Plugin
class Goblin2cPlugin(earlyInjection : Boolean = true) extends Plugin[VexRiscv] {
	import Goblin2cPlugin._
	object IS_Goblin2c extends Stageable(Bool)
	object Goblin2c_FINAL_OUTPUT extends Stageable(Bits(32 bits))
	object Goblin2c_INTERMEDIATE_UFMA8VxV96 extends Stageable(Bits(96 bits))
	override def setup(pipeline: VexRiscv): Unit = {
		import pipeline.config._
		val immediateActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.IMI,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> False,
			BYPASSABLE_MEMORY_STAGE  -> Bool(earlyInjection),
			RS1_USE -> True,
			IS_Goblin2c -> True
			)
		val binaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> False,
			BYPASSABLE_MEMORY_STAGE  -> Bool(earlyInjection),
			RS1_USE -> True,
			RS2_USE -> True,
			IS_Goblin2c -> True
			)
		val unaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> False,
			BYPASSABLE_MEMORY_STAGE  -> Bool(earlyInjection),
			RS1_USE -> True,
			IS_Goblin2c -> True
			)
		val ternaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.RS,
			SRC3_CTRL                -> Src3CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> False,
			BYPASSABLE_MEMORY_STAGE  -> Bool(earlyInjection),
			RS1_USE -> True,
			RS2_USE -> True,
			RS3_USE -> True,
			IS_Goblin2c -> True
			)
		val immTernaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.IMI,
			SRC3_CTRL                -> Src3CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> False,
			BYPASSABLE_MEMORY_STAGE  -> Bool(earlyInjection),
			RS1_USE -> True,
			RS3_USE -> True,
			IS_Goblin2c -> True
			)
		def UFMA8VxV_KEY = M"11001-0----------000----01110111"
		val decoderService = pipeline.service(classOf[DecoderService])
		decoderService.addDefault(IS_Goblin2c, False)
		decoderService.add(List(
			UFMA8VxV_KEY	-> (ternaryActions ++ List(Goblin2cCtrl -> Goblin2cCtrlEnum.CTRL_UFMA8VxV))
		))
	} // override def setup
	override def build(pipeline: VexRiscv): Unit = {
		import pipeline._
		import pipeline.config._
		execute plug new Area{
			import execute._
			insert(Goblin2c_INTERMEDIATE_UFMA8VxV96) := fun_ufma8vxv(input(SRC1), input(SRC2), input(SRC3), (input(INSTRUCTION)(26).asUInt === 1)).asBits
		} // execute plug newArea
		memory plug new Area{
			import memory._
			insert(Goblin2c_FINAL_OUTPUT) := fun_ufma8vxv2(input(Goblin2c_INTERMEDIATE_UFMA8VxV96)).asBits
		} // memory plug newArea
		val injectionStage = if(earlyInjection) memory else writeBack
		injectionStage plug new Area {
			import injectionStage._
			when (arbitration.isValid && input(IS_Goblin2c)) {
				output(REGFILE_WRITE_DATA) := input(Goblin2c_FINAL_OUTPUT)
			} // when input is
		} // injectionStage plug newArea
	} // override def build
} // class Plugin
