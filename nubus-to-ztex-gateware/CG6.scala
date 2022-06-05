// WARNING: this is auto-generated code!
// See https://github.com/rdolbeau/VexRiscvBPluginGenerator/
package vexriscv.plugin
import spinal.core._
import vexriscv.{Stageable, DecoderService, VexRiscv}
object CG6Plugin {
	object CG6CtrlminmaxEnum extends SpinalEnum(binarySequential) {
		 val CTRL_MAXU, CTRL_MINU = newElement()
	}
	object CG6CtrlsignextendEnum extends SpinalEnum(binarySequential) {
		 val CTRL_SEXTdotB, CTRL_ZEXTdotH = newElement()
	}
	object CG6CtrlternaryEnum extends SpinalEnum(binarySequential) {
		 val CTRL_CMIX, CTRL_CMOV, CTRL_FSR = newElement()
	}
	object CG6CtrlEnum extends SpinalEnum(binarySequential) {
		 val CTRL_SH2ADD, CTRL_minmax, CTRL_signextend, CTRL_ternary, CTRL_REV8 = newElement()
	}
	object CG6Ctrlminmax extends Stageable(CG6CtrlminmaxEnum())
	object CG6Ctrlsignextend extends Stageable(CG6CtrlsignextendEnum())
	object CG6Ctrlternary extends Stageable(CG6CtrlternaryEnum())
	object CG6Ctrl extends Stageable(CG6CtrlEnum())
// Prologue

   // function implementing the semantic of 32-bits generalized reverse
   def fun_grev( a:Bits, b:Bits ) : Bits = {
       val x1  = ((b&B"32'x00000001")===B"32'x00000001") ? (((a  & B"32'x55555555") |<< 1) | ((a  & B"32'xAAAAAAAA") |>> 1)) | a
       val x2  = ((b&B"32'x00000002")===B"32'x00000002") ? (((x1 & B"32'x33333333") |<< 2) | ((x1 & B"32'xCCCCCCCC") |>> 2)) | x1
       val x4  = ((b&B"32'x00000004")===B"32'x00000004") ? (((x2 & B"32'x0F0F0F0F") |<< 4) | ((x2 & B"32'xF0F0F0F0") |>> 4)) | x2
       val x8  = ((b&B"32'x00000008")===B"32'x00000008") ? (((x4 & B"32'x00FF00FF") |<< 8) | ((x4 & B"32'xFF00FF00") |>> 8)) | x4
       val x16 = ((b&B"32'x00000010")===B"32'x00000010") ? (((x8 & B"32'x0000FFFF") |<<16) | ((x8 & B"32'xFFFF0000") |>>16)) | x8
       x16 // return value
   }
   // function implementing the semantic of 32-bits generalized OR-combine
   def fun_gorc( a:Bits, b:Bits ) : Bits = {
       val x1  = ((b&B"32'x00000001")===B"32'x00000001") ? (a  | ((a  & B"32'x55555555") |<< 1) | ((a  & B"32'xAAAAAAAA") |>> 1)) | a
       val x2  = ((b&B"32'x00000002")===B"32'x00000002") ? (x1 | ((x1 & B"32'x33333333") |<< 2) | ((x1 & B"32'xCCCCCCCC") |>> 2)) | x1
       val x4  = ((b&B"32'x00000004")===B"32'x00000004") ? (x2 | ((x2 & B"32'x0F0F0F0F") |<< 4) | ((x2 & B"32'xF0F0F0F0") |>> 4)) | x2
       val x8  = ((b&B"32'x00000008")===B"32'x00000008") ? (x4 | ((x4 & B"32'x00FF00FF") |<< 8) | ((x4 & B"32'xFF00FF00") |>> 8)) | x4
       val x16 = ((b&B"32'x00000010")===B"32'x00000010") ? (x8 | ((x8 & B"32'x0000FFFF") |<<16) | ((x8 & B"32'xFFFF0000") |>>16)) | x8
       x16 // return value
   }

   // helper function for the implementation of the generalized shuffles
   def fun_shuffle32_stage(src:Bits, maskL:Bits, maskR:Bits, N:Int) : Bits = {
       val x = src & ~(maskL | maskR)
       val x2 = x | ((src |<< N) & maskL) | ((src |>> N) & maskR);
       x2 // return value
   }
   // function implementing the semantic of 32-bits generalized shuffle
   def fun_shfl32(a:Bits, b:Bits) : Bits = {
       val x = a;
       val x1 = ((b&B"32'x00000008")===B"32'x00000008") ? fun_shuffle32_stage(x , B"32'x00FF0000", B"32'x0000FF00", 8) | x;
       val x2 = ((b&B"32'x00000004")===B"32'x00000004") ? fun_shuffle32_stage(x1, B"32'x0F000F00", B"32'x00F000F0", 4) | x1;
       val x3 = ((b&B"32'x00000002")===B"32'x00000002") ? fun_shuffle32_stage(x2, B"32'x30303030", B"32'x0C0C0C0C", 2) | x2;
       val x4 = ((b&B"32'x00000001")===B"32'x00000001") ? fun_shuffle32_stage(x3, B"32'x44444444", B"32'x22222222", 1) | x3;
       x4 // return value
   }
   // function implementing the semantic of 32-bits generalized unshuffle
   def fun_unshfl32(a:Bits, b:Bits) : Bits = {
      val x = a;
      val x1 = ((b&B"32'x00000001")===B"32'x00000001") ? fun_shuffle32_stage(x , B"32'x44444444", B"32'x22222222", 1) | x;
      val x2 = ((b&B"32'x00000002")===B"32'x00000002") ? fun_shuffle32_stage(x1, B"32'x30303030", B"32'x0C0C0C0C", 2) | x1;
      val x3 = ((b&B"32'x00000004")===B"32'x00000004") ? fun_shuffle32_stage(x2, B"32'x0F000F00", B"32'x00F000F0", 4) | x2;
      val x4 = ((b&B"32'x00000008")===B"32'x00000008") ? fun_shuffle32_stage(x3, B"32'x00FF0000", B"32'x0000FF00", 8) | x3;
      x4 // return value
   }


   // this is trying to look like DOI 10.2478/jee-2015-0054
   def fun_clz_NLCi(x:Bits): Bits = {
       val r2 = (~(x(0) | x(1) | x(2) | x(3)))
       val r1 = (~(x(2) | x(3)))
       val r0 = (~(x(3) | (x(1) & ~x(2))))
       val r = r2 ## r1 ## r0
       r // return value
   }
   def fun_clz_BNE(a:Bits) : Bits = {
       val a01 = ~(a(0) & a(1))
       val a23 = ~(a(2) & a(3))

       val a45 = ~(a(4) & a(5))
       val a67 = ~(a(6) & a(7))

       val a0123 = ~(a01 | a23) // also r(2)
       val a4567 = ~(a45 | a67)

       val a56 = ~(a(5) & ~a(6))
       val a024 = (a(0) & a(2) & a(4)) // AND not NAND
       val a13 = ~(a(1) & a(3))
       val a12 = ~(a(1) & ~a(2))
       
       val r3 = ((a0123 & a4567)) // AND not NAND
       val r2 = (a0123)
       val r1 = (~(a01 | (~a23 & a45)))
       val r0 = (~((~((a56) & (a024))) & (~((a13) & (a12) & (a(0))))))

       val r = r3 ## r2 ## r1 ##r0
       
       r // return value
   }
   // For trailing count, count using use leading count on bit-reversed value
   def fun_cltz(ino:Bits, ctz:Bool) : Bits = {
       val inr = ino(0) ## ino(1) ## ino(2) ## ino(3) ## ino(4) ## ino(5) ## ino(6) ## ino(7) ## ino(8) ## ino(9) ## ino(10) ## ino(11) ## ino(12) ## ino(13) ## ino(14) ## ino(15) ## ino(16) ## ino(17) ## ino(18) ## ino(19) ## ino(20) ## ino(21) ## ino(22) ## ino(23) ## ino(24) ## ino(25) ## ino(26) ## ino(27) ## ino(28) ## ino(29) ## ino(30) ## ino(31)
	   val in = (ctz === True) ? (inr) | (ino)

       val nlc7 = fun_clz_NLCi(in(31 downto 28))
       val nlc6 = fun_clz_NLCi(in(27 downto 24))
       val nlc5 = fun_clz_NLCi(in(23 downto 20))
       val nlc4 = fun_clz_NLCi(in(19 downto 16))
       val nlc3 = fun_clz_NLCi(in(15 downto 12))
       val nlc2 = fun_clz_NLCi(in(11 downto  8))
       val nlc1 = fun_clz_NLCi(in( 7 downto  4))
       val nlc0 = fun_clz_NLCi(in( 3 downto  0))
       val a = nlc0(2) ## nlc1(2) ## nlc2(2) ## nlc3(2) ## nlc4(2) ## nlc5(2) ## nlc6(2) ## nlc7(2)
       val bne = fun_clz_BNE(a)
       
      val muxo = (bne(2 downto 0)).mux(
	  B"3'b000" -> nlc7(1 downto 0),
	  B"3'b001" -> nlc6(1 downto 0),
	  B"3'b010" -> nlc5(1 downto 0),
	  B"3'b011" -> nlc4(1 downto 0),
	  B"3'b100" -> nlc3(1 downto 0),
	  B"3'b101" -> nlc2(1 downto 0),
	  B"3'b110" -> nlc1(1 downto 0),
	  B"3'b111" -> nlc0(1 downto 0)
      )
      val r = (bne(3)) ?  B"6'b100000" | (B"1'b0" ## bne(2 downto 0) ## muxo(1 downto 0)) // 6 bits
      
      r.resize(32) // return value
   }

   // naive popcnt
   def fun_popcnt(in:Bits) : Bits = {
       val r = in(0).asBits.resize(6).asUInt + in(1).asBits.resize(6).asUInt + in(2).asBits.resize(6).asUInt + in(3).asBits.resize(6).asUInt +
	       in(4).asBits.resize(6).asUInt + in(5).asBits.resize(6).asUInt + in(6).asBits.resize(6).asUInt + in(7).asBits.resize(6).asUInt +
	       in(8).asBits.resize(6).asUInt + in(9).asBits.resize(6).asUInt + in(10).asBits.resize(6).asUInt + in(11).asBits.resize(6).asUInt +
	       in(12).asBits.resize(6).asUInt + in(13).asBits.resize(6).asUInt + in(14).asBits.resize(6).asUInt + in(15).asBits.resize(6).asUInt +
	       in(16).asBits.resize(6).asUInt + in(17).asBits.resize(6).asUInt + in(18).asBits.resize(6).asUInt + in(19).asBits.resize(6).asUInt +
	       in(20).asBits.resize(6).asUInt + in(21).asBits.resize(6).asUInt + in(22).asBits.resize(6).asUInt + in(23).asBits.resize(6).asUInt +
	       in(24).asBits.resize(6).asUInt + in(25).asBits.resize(6).asUInt + in(26).asBits.resize(6).asUInt + in(27).asBits.resize(6).asUInt +
	       in(28).asBits.resize(6).asUInt + in(29).asBits.resize(6).asUInt + in(30).asBits.resize(6).asUInt + in(31).asBits.resize(6).asUInt

       r.asBits.resize(32) // return value
   }

   //XPERMs
   def fun_xperm_n(rs1:Bits, rs2:Bits) : Bits = {
       val i0 = rs2(3 downto 0).asUInt
       val i1 = rs2(7 downto 4).asUInt
       val i2 = rs2(11 downto 8).asUInt
       val i3 = rs2(15 downto 12).asUInt
       val i4 = rs2(19 downto 16).asUInt
       val i5 = rs2(23 downto 20).asUInt
       val i6 = rs2(27 downto 24).asUInt
       val i7 = rs2(31 downto 28).asUInt
       val r0 = (i0).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r1 = (i1).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r2 = (i2).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r3 = (i3).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r4 = (i4).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r5 = (i5).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r6 = (i6).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       val r7 = (i7).mux(
          0 -> rs1(3 downto 0),
          1 -> rs1(7 downto 4),
          2 -> rs1(11 downto 8),
          3 -> rs1(15 downto 12),
          4 -> rs1(19 downto 16),
          5 -> rs1(23 downto 20),
          6 -> rs1(27 downto 24),
          7 -> rs1(31 downto 28),
          default -> B"4'b0000"
	  )
       r7 ## r6 ## r5 ## r4 ## r3 ## r2 ## r1 ## r0 // return value
   }
   def fun_xperm_b(rs1:Bits, rs2:Bits) : Bits = {
       val i0 = rs2(7 downto 0).asUInt;
       val i1 = rs2(15 downto 8).asUInt;
       val i2 = rs2(23 downto 16).asUInt;
       val i3 = rs2(31 downto 24).asUInt;
       val r0 = (i0).mux(
	   0 -> rs1(7 downto 0),
	   1 -> rs1(15 downto 8),
	   2 -> rs1(23 downto 16),
	   3 -> rs1(31 downto 24),
	   default -> B"8'b00000000"
	   )
       val r1 = (i1).mux(
	   0 -> rs1(7 downto 0),
	   1 -> rs1(15 downto 8),
	   2 -> rs1(23 downto 16),
	   3 -> rs1(31 downto 24),
	   default -> B"8'b00000000"
	   )
       val r2 = (i2).mux(
	   0 -> rs1(7 downto 0),
	   1 -> rs1(15 downto 8),
	   2 -> rs1(23 downto 16),
	   3 -> rs1(31 downto 24),
	   default -> B"8'b00000000"
	   )
       val r3 = (i3).mux(
	   0 -> rs1(7 downto 0),
	   1 -> rs1(15 downto 8),
	   2 -> rs1(23 downto 16),
	   3 -> rs1(31 downto 24),
	   default -> B"8'b00000000"
	   )
       r3 ## r2 ## r1 ## r0 // return value
   }
   def fun_xperm_h(rs1:Bits, rs2:Bits) : Bits = {
       val i0 = rs2(15 downto 0).asUInt;
       val i1 = rs2(31 downto 16).asUInt;
       val r0 = (i0).mux(
	   0 -> rs1(15 downto 0),
	   1 -> rs1(31 downto 16),
	   default -> B"16'x0000"
	   )
       val r1 = (i1).mux(
	   0 -> rs1(15 downto 0),
	   1 -> rs1(31 downto 16),
	   default -> B"16'x0000"
	   )
       r1 ## r0 // return value
   }

   def fun_fsl(rs1:Bits, rs3:Bits, rs2:Bits) : Bits = {
       val rawshamt = (rs2 & B"32'x0000003F").asUInt
       val shamt = (rawshamt >= 32) ? (rawshamt - 32) | (rawshamt)
       val A = (shamt === rawshamt) ? (rs1) | (rs3)
       val B = (shamt === rawshamt) ? (rs3) | (rs1)
       val r = (shamt === 0) ? (A) | ((A |<< shamt) | (B |>> (32-shamt))) 

       r // return value
   }

   def fun_fsr(rs1:Bits, rs3:Bits, rs2:Bits) : Bits = {
       val rawshamt = (rs2 & B"32'x0000003F").asUInt
       val shamt = (rawshamt >= 32) ? (rawshamt - 32) | (rawshamt)
       val A = (shamt === rawshamt) ? (rs1) | (rs3)
       val B = (shamt === rawshamt) ? (rs3) | (rs1)
       val r = (shamt === 0) ? (A) | ((A |>> shamt) | (B |<< (32-shamt))) 

       r // return value
   }

   def fun_bfp(rs1:Bits, rs2:Bits) : Bits = {       
       val off = rs2(20 downto 16).asUInt
       val rawlen = rs2(27 downto 24).asUInt
       val convlen = (rawlen === 0) ? (rawlen+16) | (rawlen)
       val len = ((convlen + off) > 32) ? (32 - off) | (convlen)
       val allones = B"16'xFFFF"
       val lenones = (allones |>> (16-len))
       //val one = B"17'x00001"
       //val lenones = (((one |<< len).asUInt) - 1).asBits;
       val mask = (lenones.resize(32) |<< off);
       val data = (rs2 & lenones.resize(32)) |<< off;
       
       val r = (rs1 & ~mask) | data

       r // return value
   }


   def fun_rev8(a:Bits) : Bits = {
   	   val r = a(7 downto 0) ## a(15 downto 8) ## a(23 downto 16) ## a(31 downto 24)

	   r // return value
   }
   def fun_orcb(a:Bits) : Bits = {
       val x1  = (a  | ((a  & B"32'x55555555") |<< 1) | ((a  & B"32'xAAAAAAAA") |>> 1))
       val x2  = (x1 | ((x1 & B"32'x33333333") |<< 2) | ((x1 & B"32'xCCCCCCCC") |>> 2))
       val x4  = (x2 | ((x2 & B"32'x0F0F0F0F") |<< 4) | ((x2 & B"32'xF0F0F0F0") |>> 4))
	   
       x4 // return value
   }
   def fun_revdotb(a:Bits) : Bits = {
   	   val r = a(24) ## a(25) ## a(26) ## a(27) ## a(28) ## a(29) ## a(30) ## a(31) ##
	   	   	   a(16) ## a(17) ## a(18) ## a(19) ## a(20) ## a(21) ## a(22) ## a(23) ##
			   a( 8) ## a( 9) ## a(10) ## a(11) ## a(12) ## a(13) ## a(14) ## a(15) ##
			   a( 0) ## a( 1) ## a( 2) ## a( 3) ## a( 4) ## a( 5) ## a( 6) ## a( 7)

   	   r // return value;
   }
   // helper function for the implementation of the generalized shuffles
   def fun_shuffle32bis_stage(src:Bits, maskL:Bits, maskR:Bits, N:Int) : Bits = {
       val x = src & ~(maskL | maskR)
       val x2 = x | ((src |<< N) & maskL) | ((src |>> N) & maskR);
       x2 // return value
   }
   def fun_zip(a:Bits) : Bits = {
       val x = a;
       val x1 = fun_shuffle32bis_stage(x , B"32'x00FF0000", B"32'x0000FF00", 8)
       val x2 = fun_shuffle32bis_stage(x1, B"32'x0F000F00", B"32'x00F000F0", 4)
       val x3 = fun_shuffle32bis_stage(x2, B"32'x30303030", B"32'x0C0C0C0C", 2)
       val x4 = fun_shuffle32bis_stage(x3, B"32'x44444444", B"32'x22222222", 1)
       x4 // return value
   }
   def fun_unzip(a:Bits) : Bits = {
      val x = a;
      val x1 = fun_shuffle32bis_stage(x , B"32'x44444444", B"32'x22222222", 1)
      val x2 = fun_shuffle32bis_stage(x1, B"32'x30303030", B"32'x0C0C0C0C", 2)
      val x3 = fun_shuffle32bis_stage(x2, B"32'x0F000F00", B"32'x00F000F0", 4)
      val x4 = fun_shuffle32bis_stage(x3, B"32'x00FF0000", B"32'x0000FF00", 8)
      x4 // return value
   }

// End prologue
} // object Plugin
class CG6Plugin(earlyInjection : Boolean = true) extends Plugin[VexRiscv] {
	import CG6Plugin._
	object IS_CG6 extends Stageable(Bool)
	object CG6_FINAL_OUTPUT extends Stageable(Bits(32 bits))
	override def setup(pipeline: VexRiscv): Unit = {
		import pipeline.config._
		val immediateActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.IMI,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			IS_CG6 -> True
			)
		val binaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			RS2_USE -> True,
			IS_CG6 -> True
			)
		val unaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			IS_CG6 -> True
			)
		val ternaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.RS,
			SRC3_CTRL                -> Src3CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			RS2_USE -> True,
			RS3_USE -> True,
			IS_CG6 -> True
			)
		val immTernaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.IMI,
			SRC3_CTRL                -> Src3CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			RS3_USE -> True,
			IS_CG6 -> True
			)
		def SH2ADD_KEY = M"0010000----------100-----0110011"
		def MINU_KEY = M"0000101----------101-----0110011"
		def MAXU_KEY = M"0000101----------111-----0110011"
		def SEXTdotB_KEY = M"011000000100-----001-----0010011"
		def CMIX_KEY = M"-----11----------001-----0110011"
		def CMOV_KEY = M"-----11----------101-----0110011"
		def FSR_KEY = M"-----10----------101-----0110011"
		def ZEXTdotH_KEY = M"000010000000-----100-----0110011"
		def REV8_KEY = M"011010011000-----101-----0010011"
		val decoderService = pipeline.service(classOf[DecoderService])
		decoderService.addDefault(IS_CG6, False)
		decoderService.add(List(
			SH2ADD_KEY	-> (binaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_SH2ADD)),
			MINU_KEY	-> (binaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_minmax, CG6Ctrlminmax -> CG6CtrlminmaxEnum.CTRL_MINU)),
			MAXU_KEY	-> (binaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_minmax, CG6Ctrlminmax -> CG6CtrlminmaxEnum.CTRL_MAXU)),
			SEXTdotB_KEY	-> (unaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_signextend, CG6Ctrlsignextend -> CG6CtrlsignextendEnum.CTRL_SEXTdotB)),
			ZEXTdotH_KEY	-> (unaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_signextend, CG6Ctrlsignextend -> CG6CtrlsignextendEnum.CTRL_ZEXTdotH)),
			CMIX_KEY	-> (ternaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_ternary, CG6Ctrlternary -> CG6CtrlternaryEnum.CTRL_CMIX)),
			CMOV_KEY	-> (ternaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_ternary, CG6Ctrlternary -> CG6CtrlternaryEnum.CTRL_CMOV)),
			FSR_KEY	-> (ternaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_ternary, CG6Ctrlternary -> CG6CtrlternaryEnum.CTRL_FSR)),
			REV8_KEY	-> (unaryActions ++ List(CG6Ctrl -> CG6CtrlEnum.CTRL_REV8))
		))
	} // override def setup
	override def build(pipeline: VexRiscv): Unit = {
		import pipeline._
		import pipeline.config._
		execute plug new Area{
			import execute._
			val val_minmax = input(CG6Ctrlminmax).mux(
				CG6CtrlminmaxEnum.CTRL_MAXU -> ((input(SRC1).asUInt > input(SRC2).asUInt) ? input(SRC1) | input(SRC2)).asBits,
				CG6CtrlminmaxEnum.CTRL_MINU -> ((input(SRC1).asUInt < input(SRC2).asUInt) ? input(SRC1) | input(SRC2)).asBits
			) // mux minmax
			val val_signextend = input(CG6Ctrlsignextend).mux(
				CG6CtrlsignextendEnum.CTRL_SEXTdotB -> (Bits(24 bits).setAllTo(input(SRC1)(7)) ## input(SRC1)(7 downto 0)).asBits,
				CG6CtrlsignextendEnum.CTRL_ZEXTdotH -> (B"16'x0000" ## input(SRC1)(15 downto 0)).asBits
			) // mux signextend
			val val_ternary = input(CG6Ctrlternary).mux(
				CG6CtrlternaryEnum.CTRL_CMIX -> ((input(SRC1) & input(SRC2)) | (input(SRC3) & ~input(SRC2))).asBits,
				CG6CtrlternaryEnum.CTRL_CMOV -> ((input(SRC2).asUInt =/= 0) ? input(SRC1) | input(SRC3)).asBits,
				CG6CtrlternaryEnum.CTRL_FSR -> fun_fsr(input(SRC1), input(SRC3), input(SRC2)).asBits
			) // mux ternary
			insert(CG6_FINAL_OUTPUT) := input(CG6Ctrl).mux(
				CG6CtrlEnum.CTRL_SH2ADD -> ((input(SRC1) |<< 2).asUInt + input(SRC2).asUInt).asBits,
				CG6CtrlEnum.CTRL_minmax -> val_minmax.asBits,
				CG6CtrlEnum.CTRL_signextend -> val_signextend.asBits,
				CG6CtrlEnum.CTRL_ternary -> val_ternary.asBits,
				CG6CtrlEnum.CTRL_REV8 -> fun_rev8(input(SRC1)).asBits
			) // primary mux
		} // execute plug newArea
		val injectionStage = if(earlyInjection) execute else memory
		injectionStage plug new Area {
			import injectionStage._
			when (arbitration.isValid && input(IS_CG6)) {
				output(REGFILE_WRITE_DATA) := input(CG6_FINAL_OUTPUT)
			} // when input is
		} // injectionStage plug newArea
	} // override def build
} // class Plugin
