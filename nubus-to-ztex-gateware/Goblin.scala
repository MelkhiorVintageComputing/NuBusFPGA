// WARNING: this is auto-generated code!
// See https://github.com/rdolbeau/VexRiscvBPluginGenerator/
package vexriscv.plugin
import spinal.core._
import vexriscv.{Stageable, DecoderService, VexRiscv}
object GoblinPlugin {
	object GoblinCtrlpdpikadd8Enum extends SpinalEnum(binarySequential) {
		 val CTRL_UKADD8, CTRL_UKSUB8 = newElement()
	}
	object GoblinCtrlEnum extends SpinalEnum(binarySequential) {
		 val CTRL_pdpikadd8 = newElement()
	}
	object GoblinCtrlpdpikadd8 extends Stageable(GoblinCtrlpdpikadd8Enum())
	object GoblinCtrl extends Stageable(GoblinCtrlEnum())
// Prologue

	def fun_add8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt + rs2( 7 downto  0).asUInt).asBits.resize(8)
	    val b1 = (rs1(15 downto  8).asUInt + rs2(15 downto  8).asUInt).asBits.resize(8)
	    val b2 = (rs1(23 downto 16).asUInt + rs2(23 downto 16).asUInt).asBits.resize(8)
	    val b3 = (rs1(31 downto 24).asUInt + rs2(31 downto 24).asUInt).asBits.resize(8)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_radd8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = ((rs1( 7) ## rs1( 7 downto  0)).asSInt + (rs2( 7) ## rs2( 7 downto  0)).asSInt).asBits.resize(9)
	    val b1 = ((rs1(15) ## rs1(15 downto  8)).asSInt + (rs2(15) ## rs2(15 downto  8)).asSInt).asBits.resize(9)
	    val b2 = ((rs1(23) ## rs1(23 downto 16)).asSInt + (rs2(23) ## rs2(23 downto 16)).asSInt).asBits.resize(9)
	    val b3 = ((rs1(31) ## rs1(31 downto 24)).asSInt + (rs2(31) ## rs2(31 downto 24)).asSInt).asBits.resize(9)

	    b3(8 downto 1) ## b2(8 downto 1) ## b1(8 downto 1) ## b0(8 downto 1) // return value
	}
	def fun_rsub8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = ((rs1( 7) ## rs1( 7 downto  0)).asSInt - (rs2( 7) ## rs2( 7 downto  0)).asSInt).asBits.resize(9)
	    val b1 = ((rs1(15) ## rs1(15 downto  8)).asSInt - (rs2(15) ## rs2(15 downto  8)).asSInt).asBits.resize(9)
	    val b2 = ((rs1(23) ## rs1(23 downto 16)).asSInt - (rs2(23) ## rs2(23 downto 16)).asSInt).asBits.resize(9)
	    val b3 = ((rs1(31) ## rs1(31 downto 24)).asSInt - (rs2(31) ## rs2(31 downto 24)).asSInt).asBits.resize(9)

	    b3(8 downto 1) ## b2(8 downto 1) ## b1(8 downto 1) ## b0(8 downto 1) // return value
	}
	
	def fun_add16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt + rs2(15 downto  0).asUInt).asBits.resize(16)
	    val h1 = (rs1(31 downto 16).asUInt + rs2(31 downto 16).asUInt).asBits.resize(16)

	    h1 ## h0 // return value
	}
	def fun_radd16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = ((rs1(15) ## rs1(15 downto  0)).asSInt + (rs2(15) ## rs2(15 downto  0)).asSInt).asBits.resize(17)
	    val h1 = ((rs1(31) ## rs1(31 downto 16)).asSInt + (rs2(31) ## rs2(31 downto 16)).asSInt).asBits.resize(17)

	    h1(16 downto 1) ## h0(16 downto 1) // return value
	}
	def fun_rsub16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = ((rs1(15) ## rs1(15 downto  0)).asSInt - (rs2(15) ## rs2(15 downto  0)).asSInt).asBits.resize(17)
	    val h1 = ((rs1(31) ## rs1(31 downto 16)).asSInt - (rs2(31) ## rs2(31 downto 16)).asSInt).asBits.resize(17)

	    h1(16 downto 1) ## h0(16 downto 1) // return value
	}
	
	def fun_radd32(rs1: Bits, rs2: Bits) : Bits = {
	    val s = ((rs1(31) ## rs1).asSInt + (rs2(31) ## rs2).asSInt).asBits.resize(33)

	    s(32 downto 1) // return value
	}
	def fun_rsub32(rs1: Bits, rs2: Bits) : Bits = {
	    val s = ((rs1(31) ## rs1).asSInt - (rs2(31) ## rs2).asSInt).asBits.resize(33)

	    s(32 downto 1) // return value
	}
	def fun_ave(rs1: Bits, rs2: Bits) : Bits = {
	    val inter = (1 + (rs1 ## B"1'b0").asUInt + (rs2 ## B"1'b0").asUInt).asBits.resize(33)

	    inter(32 downto 1) // return value
	}
	
	def fun_bitrev(rs1: Bits, rs2: Bits) : Bits = {
	    val msb = rs2(4 downto 0).asUInt
       	    val rs1r = rs1(0) ## rs1(1) ## rs1(2) ## rs1(3) ## rs1(4) ## rs1(5) ## rs1(6) ## rs1(7) ## rs1(8) ## rs1(9) ## rs1(10) ## rs1(11) ## rs1(12) ## rs1(13) ## rs1(14) ## rs1(15) ## rs1(16) ## rs1(17) ## rs1(18) ## rs1(19) ## rs1(20) ## rs1(21) ## rs1(22) ## rs1(23) ## rs1(24) ## rs1(25) ## rs1(26) ## rs1(27) ## rs1(28) ## rs1(29) ## rs1(30) ## rs1(31)
	    val rs1rs = rs1r |>> (31-msb)

	    rs1rs // return value
	}
	
	// this is trying to look like DOI 10.2478/jee-2015-0054
	def fun_clz_NLCi(x:Bits): Bits = {
	    val r2 = (~(x(0) | x(1) | x(2) | x(3)))
	    val r1 = (~(x(2) | x(3)))
	    val r0 = (~(x(3) | (x(1) & ~x(2))))
	    val r = r2 ## r1 ## r0
	    r // return value
        }
	def fun_clz_byte(in: Bits): Bits = {
	    val nlc1 = fun_clz_NLCi(in( 7 downto  4))
 	    val nlc0 = fun_clz_NLCi(in( 3 downto  0))
	    val x = ((nlc1(2).asUInt === 1) ? (4 + nlc0(1 downto 0).asUInt) | (nlc1(1 downto 0).asUInt))
	    val y = B"8'x08"
	    ((nlc0(2).asUInt === 1) && (nlc1(2).asUInt === 1)) ? y | x.asBits.resize(8) // return value
	}
	def fun_clrs8(rs1: Bits) : Bits = {
	    val b0 = rs1( 7 downto  0)
	    val b1 = rs1(15 downto  8)
	    val b2 = rs1(23 downto 16)
	    val b3 = rs1(31 downto 24)

	    val b0s = (b0(7).asUInt === 1) ? (~b0) | (b0)
	    val b1s = (b1(7).asUInt === 1) ? (~b1) | (b1)
	    val b2s = (b2(7).asUInt === 1) ? (~b2) | (b2)
	    val b3s = (b3(7).asUInt === 1) ? (~b3) | (b3)

	    val c0 = fun_clz_byte(b0s).asUInt - 1
	    val c1 = fun_clz_byte(b1s).asUInt - 1
	    val c2 = fun_clz_byte(b2s).asUInt - 1
	    val c3 = fun_clz_byte(b3s).asUInt - 1

	    c3.asBits.resize(8) ## c2.asBits.resize(8) ## c1.asBits.resize(8) ## c0.asBits.resize(8) // return value
	}
	def fun_clo8(rs1: Bits) : Bits = {
	    val b0 = rs1( 7 downto  0)
	    val b1 = rs1(15 downto  8)
	    val b2 = rs1(23 downto 16)
	    val b3 = rs1(31 downto 24)

	    val c0 = fun_clz_byte(~b0)
	    val c1 = fun_clz_byte(~b1)
	    val c2 = fun_clz_byte(~b2)
	    val c3 = fun_clz_byte(~b3)

	    c3 ## c2 ## c1 ## c0 // return value
	}
	def fun_clz8(rs1: Bits) : Bits = {
	    val b0 = rs1( 7 downto  0)
	    val b1 = rs1(15 downto  8)
	    val b2 = rs1(23 downto 16)
	    val b3 = rs1(31 downto 24)

	    val c0 = fun_clz_byte(b0)
	    val c1 = fun_clz_byte(b1)
	    val c2 = fun_clz_byte(b2)
	    val c3 = fun_clz_byte(b3)

	    c3 ## c2 ## c1 ## c0 // return value
	}
	
	def fun_swap8(rs1: Bits) : Bits = {
	    val b0 = rs1( 7 downto  0)
	    val b1 = rs1(15 downto  8)
	    val b2 = rs1(23 downto 16)
	    val b3 = rs1(31 downto 24)
	    
	    b2 ## b3 ## b0 ## b1 // return value
	}
	def fun_swap16(rs1: Bits) : Bits = {
	    val h0 = rs1(15 downto  0)
	    val h1 = rs1(31 downto 16)

	    h0 ## h1 // return value
	}
	

	def fun_cmpeq8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt === rs2( 7 downto  0).asUInt) ? B"8'xFF" | B"8'x00"
	    val b1 = (rs1(15 downto  8).asUInt === rs2(15 downto  8).asUInt) ? B"8'xFF" | B"8'x00"
	    val b2 = (rs1(23 downto 16).asUInt === rs2(23 downto 16).asUInt) ? B"8'xFF" | B"8'x00"
	    val b3 = (rs1(31 downto 24).asUInt === rs2(31 downto 24).asUInt) ? B"8'xFF" | B"8'x00"

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_cmpeq16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt === rs2(15 downto  0).asUInt) ? B"16'xFFFF" | B"16'x0000"
	    val h1 = (rs1(31 downto 16).asUInt === rs2(31 downto 16).asUInt) ? B"16'xFFFF" | B"16'x0000"

	    h1 ## h0 // return value
	}
	def fun_pkbbtt16(rs1: Bits, rs2: Bits, h:UInt, l:UInt) : Bits = {
	    val hr = (h === 0) ? rs1(15 downto 0) | rs1(31 downto 16)
	    val hl = (l === 0) ? rs2(15 downto 0) | rs2(31 downto 16)
	    
	    hr ## hl // return value
	}


	def fun_scmple8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt <= rs2( 7 downto  0).asSInt) ? B"8'xFF" | B"8'x00"
	    val b1 = (rs1(15 downto  8).asSInt <= rs2(15 downto  8).asSInt) ? B"8'xFF" | B"8'x00"
	    val b2 = (rs1(23 downto 16).asSInt <= rs2(23 downto 16).asSInt) ? B"8'xFF" | B"8'x00"
	    val b3 = (rs1(31 downto 24).asSInt <= rs2(31 downto 24).asSInt) ? B"8'xFF" | B"8'x00"

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_scmple16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asSInt <= rs2(15 downto  0).asSInt) ? B"16'xFFFF" | B"16'x0000"
	    val h1 = (rs1(31 downto 16).asSInt <= rs2(31 downto 16).asSInt) ? B"16'xFFFF" | B"16'x0000"

	    h1 ## h0 // return value
	}
	def fun_scmplt8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt < rs2( 7 downto  0).asSInt) ? B"8'xFF" | B"8'x00"
	    val b1 = (rs1(15 downto  8).asSInt < rs2(15 downto  8).asSInt) ? B"8'xFF" | B"8'x00"
	    val b2 = (rs1(23 downto 16).asSInt < rs2(23 downto 16).asSInt) ? B"8'xFF" | B"8'x00"
	    val b3 = (rs1(31 downto 24).asSInt < rs2(31 downto 24).asSInt) ? B"8'xFF" | B"8'x00"

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_scmplt16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asSInt < rs2(15 downto  0).asSInt) ? B"16'xFFFF" | B"16'x0000"
	    val h1 = (rs1(31 downto 16).asSInt < rs2(31 downto 16).asSInt) ? B"16'xFFFF" | B"16'x0000"

	    h1 ## h0 // return value
	}
	def fun_ucmple8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt <= rs2( 7 downto  0).asUInt) ? B"8'xFF" | B"8'x00"
	    val b1 = (rs1(15 downto  8).asUInt <= rs2(15 downto  8).asUInt) ? B"8'xFF" | B"8'x00"
	    val b2 = (rs1(23 downto 16).asUInt <= rs2(23 downto 16).asUInt) ? B"8'xFF" | B"8'x00"
	    val b3 = (rs1(31 downto 24).asUInt <= rs2(31 downto 24).asUInt) ? B"8'xFF" | B"8'x00"

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_ucmple16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt <= rs2(15 downto  0).asUInt) ? B"16'xFFFF" | B"16'x0000"
	    val h1 = (rs1(31 downto 16).asUInt <= rs2(31 downto 16).asUInt) ? B"16'xFFFF" | B"16'x0000"

	    h1 ## h0 // return value
	}
	def fun_ucmplt8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt < rs2( 7 downto  0).asUInt) ? B"8'xFF" | B"8'x00"
	    val b1 = (rs1(15 downto  8).asUInt < rs2(15 downto  8).asUInt) ? B"8'xFF" | B"8'x00"
	    val b2 = (rs1(23 downto 16).asUInt < rs2(23 downto 16).asUInt) ? B"8'xFF" | B"8'x00"
	    val b3 = (rs1(31 downto 24).asUInt < rs2(31 downto 24).asUInt) ? B"8'xFF" | B"8'x00"

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_ucmplt16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt < rs2(15 downto  0).asUInt) ? B"16'xFFFF" | B"16'x0000"
	    val h1 = (rs1(31 downto 16).asUInt < rs2(31 downto 16).asUInt) ? B"16'xFFFF" | B"16'x0000"

	    h1 ## h0 // return value
	}
	
	def fun_sll8(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(2 downto 0).asUInt
	    val b0 = rs1( 7 downto  0).asUInt |<< o
	    val b1 = rs1(15 downto  8).asUInt |<< o
	    val b2 = rs1(23 downto 16).asUInt |<< o
	    val b3 = rs1(31 downto 24).asUInt |<< o

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_srl8(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(2 downto 0).asUInt
	    val b0 = rs1( 7 downto  0).asUInt |>> o
	    val b1 = rs1(15 downto  8).asUInt |>> o
	    val b2 = rs1(23 downto 16).asUInt |>> o
	    val b3 = rs1(31 downto 24).asUInt |>> o

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_sra8(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(2 downto 0).asUInt
	    val b0 = rs1( 7 downto  0).asSInt |>> o
	    val b1 = rs1(15 downto  8).asSInt |>> o
	    val b2 = rs1(23 downto 16).asSInt |>> o
	    val b3 = rs1(31 downto 24).asSInt |>> o

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_sll16(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(3 downto 0).asUInt
	    val h0 = rs1(15 downto  0).asUInt |<< o
	    val h1 = rs1(31 downto 16).asUInt |<< o

	    h1 ## h0 // return value
	}
	def fun_srl16(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(3 downto 0).asUInt
	    val h0 = rs1(15 downto  0).asUInt |>> o
	    val h1 = rs1(31 downto 16).asUInt |>> o

	    h1 ## h0 // return value
	}
	def fun_sra16(rs1: Bits, rs2: Bits) : Bits = {
	    val o = rs2(3 downto 0).asUInt
	    val h0 = rs1(15 downto  0).asSInt |>> o
	    val h1 = rs1(31 downto 16).asSInt |>> o

	    h1 ## h0 // return value
	}
	
	def fun_smax8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt >= rs2( 7 downto  0).asSInt) ? rs1( 7 downto  0) | rs2( 7 downto  0)
	    val b1 = (rs1(15 downto  8).asSInt >= rs2(15 downto  8).asSInt) ? rs1(15 downto  8) | rs2(15 downto  8)
	    val b2 = (rs1(23 downto 16).asSInt >= rs2(23 downto 16).asSInt) ? rs1(23 downto 16) | rs2(23 downto 16)
	    val b3 = (rs1(31 downto 24).asSInt >= rs2(31 downto 24).asSInt) ? rs1(31 downto 24) | rs2(31 downto 24)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_smax16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asSInt >= rs2(15 downto  0).asSInt) ? rs1(15 downto  0) | rs2(15 downto  0)
	    val h1 = (rs1(31 downto 16).asSInt >= rs2(31 downto 16).asSInt) ? rs1(31 downto 16) | rs2(31 downto 16)

	    h1 ## h0 // return value
	}
	def fun_smin8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt <= rs2( 7 downto  0).asSInt) ? rs1( 7 downto  0) | rs2( 7 downto  0)
	    val b1 = (rs1(15 downto  8).asSInt <= rs2(15 downto  8).asSInt) ? rs1(15 downto  8) | rs2(15 downto  8)
	    val b2 = (rs1(23 downto 16).asSInt <= rs2(23 downto 16).asSInt) ? rs1(23 downto 16) | rs2(23 downto 16)
	    val b3 = (rs1(31 downto 24).asSInt <= rs2(31 downto 24).asSInt) ? rs1(31 downto 24) | rs2(31 downto 24)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_smin16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asSInt <= rs2(15 downto  0).asSInt) ? rs1(15 downto  0) | rs2(15 downto  0)
	    val h1 = (rs1(31 downto 16).asSInt <= rs2(31 downto 16).asSInt) ? rs1(31 downto 16) | rs2(31 downto 16)

	    h1 ## h0 // return value
	}
	def fun_umax8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt >= rs2( 7 downto  0).asUInt) ? rs1( 7 downto  0) | rs2( 7 downto  0)
	    val b1 = (rs1(15 downto  8).asUInt >= rs2(15 downto  8).asUInt) ? rs1(15 downto  8) | rs2(15 downto  8)
	    val b2 = (rs1(23 downto 16).asUInt >= rs2(23 downto 16).asUInt) ? rs1(23 downto 16) | rs2(23 downto 16)
	    val b3 = (rs1(31 downto 24).asUInt >= rs2(31 downto 24).asUInt) ? rs1(31 downto 24) | rs2(31 downto 24)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_umax16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt >= rs2(15 downto  0).asUInt) ? rs1(15 downto  0) | rs2(15 downto  0)
	    val h1 = (rs1(31 downto 16).asUInt >= rs2(31 downto 16).asUInt) ? rs1(31 downto 16) | rs2(31 downto 16)

	    h1 ## h0 // return value
	}
	def fun_umin8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt <= rs2( 7 downto  0).asUInt) ? rs1( 7 downto  0) | rs2( 7 downto  0)
	    val b1 = (rs1(15 downto  8).asUInt <= rs2(15 downto  8).asUInt) ? rs1(15 downto  8) | rs2(15 downto  8)
	    val b2 = (rs1(23 downto 16).asUInt <= rs2(23 downto 16).asUInt) ? rs1(23 downto 16) | rs2(23 downto 16)
	    val b3 = (rs1(31 downto 24).asUInt <= rs2(31 downto 24).asUInt) ? rs1(31 downto 24) | rs2(31 downto 24)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_umin16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt <= rs2(15 downto  0).asUInt) ? rs1(15 downto  0) | rs2(15 downto  0)
	    val h1 = (rs1(31 downto 16).asUInt <= rs2(31 downto 16).asUInt) ? rs1(31 downto 16) | rs2(31 downto 16)

	    h1 ## h0 // return value
	}

	def fun_sub8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt - rs2( 7 downto  0).asUInt).asBits.resize(8)
	    val b1 = (rs1(15 downto  8).asUInt - rs2(15 downto  8).asUInt).asBits.resize(8)
	    val b2 = (rs1(23 downto 16).asUInt - rs2(23 downto 16).asUInt).asBits.resize(8)
	    val b3 = (rs1(31 downto 24).asUInt - rs2(31 downto 24).asUInt).asBits.resize(8)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_sub16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = (rs1(15 downto  0).asUInt - rs2(15 downto  0).asUInt).asBits.resize(16)
	    val h1 = (rs1(31 downto 16).asUInt - rs2(31 downto 16).asUInt).asBits.resize(16)

	    h1 ## h0 // return value
	}

	def fun_uradd8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = ((B"1'b0" ## rs1( 7 downto  0)).asUInt + (B"1'b0" ## rs2( 7 downto  0)).asUInt).asBits.resize(9)
	    val b1 = ((B"1'b0" ## rs1(15 downto  8)).asUInt + (B"1'b0" ## rs2(15 downto  8)).asUInt).asBits.resize(9)
	    val b2 = ((B"1'b0" ## rs1(23 downto 16)).asUInt + (B"1'b0" ## rs2(23 downto 16)).asUInt).asBits.resize(9)
	    val b3 = ((B"1'b0" ## rs1(31 downto 24)).asUInt + (B"1'b0" ## rs2(31 downto 24)).asUInt).asBits.resize(9)

	    b3(8 downto 1) ## b2(8 downto 1) ## b1(8 downto 1) ## b0(8 downto 1) // return value
	}
	def fun_ursub8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = ((B"1'b0" ## rs1( 7 downto  0)).asUInt - (B"1'b0" ## rs2( 7 downto  0)).asUInt).asBits.resize(9)
	    val b1 = ((B"1'b0" ## rs1(15 downto  8)).asUInt - (B"1'b0" ## rs2(15 downto  8)).asUInt).asBits.resize(9)
	    val b2 = ((B"1'b0" ## rs1(23 downto 16)).asUInt - (B"1'b0" ## rs2(23 downto 16)).asUInt).asBits.resize(9)
	    val b3 = ((B"1'b0" ## rs1(31 downto 24)).asUInt - (B"1'b0" ## rs2(31 downto 24)).asUInt).asBits.resize(9)

	    b3(8 downto 1) ## b2(8 downto 1) ## b1(8 downto 1) ## b0(8 downto 1) // return value
	}
	def fun_uradd16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = ((B"1'b0" ## rs1(15 downto  0)).asUInt + (B"1'b0" ## rs2(15 downto  0)).asUInt).asBits.resize(17)
	    val h1 = ((B"1'b0" ## rs1(31 downto 16)).asUInt + (B"1'b0" ## rs2(31 downto 16)).asUInt).asBits.resize(17)

	    h1(16 downto 1) ## h0(16 downto 1) // return value
	}
	def fun_ursub16(rs1: Bits, rs2: Bits) : Bits = {
	    val h0 = ((B"1'b0" ## rs1(15 downto  0)).asUInt - (B"1'b0" ## rs2(15 downto  0)).asUInt).asBits.resize(17)
	    val h1 = ((B"1'b0" ## rs1(31 downto 16)).asUInt - (B"1'b0" ## rs2(31 downto 16)).asUInt).asBits.resize(17)

	    h1(16 downto 1) ## h0(16 downto 1) // return value
	}
	def fun_uradd32(rs1: Bits, rs2: Bits) : Bits = {
	    val s = ((B"1'b0" ## rs1).asUInt + (B"1'b0" ## rs2).asUInt).asBits.resize(33)

	    s(32 downto 1) // return value
	}
	def fun_ursub32(rs1: Bits, rs2: Bits) : Bits = {
	    val s = ((B"1'b0" ## rs1).asUInt - (B"1'b0" ## rs2).asUInt).asBits.resize(33)

	    s(32 downto 1) // return value
	}

	def fun_pbsada(rs1: Bits, rs2: Bits, rs3: Bits) : Bits = {
	    // zero-extend to handle as unsigned
	    val b0 = ((B"1'b0" ## rs1( 7 downto  0)).asSInt - (B"1'b0" ## rs2( 7 downto  0)).asSInt)
	    val b1 = ((B"1'b0" ## rs1(15 downto  8)).asSInt - (B"1'b0" ## rs2(15 downto  8)).asSInt)
	    val b2 = ((B"1'b0" ## rs1(23 downto 16)).asSInt - (B"1'b0" ## rs2(23 downto 16)).asSInt)
	    val b3 = ((B"1'b0" ## rs1(31 downto 24)).asSInt - (B"1'b0" ## rs2(31 downto 24)).asSInt)

	    val sum = rs3.asUInt + b0.abs + b1.abs + b2.abs + b3.abs

	    sum.asBits.resize(32) // return value
	}
	
	def fun_insb(rs1: Bits, rs2: Bits, rs3: Bits) : Bits = {
	    val idx = rs2(1 downto 0).asUInt
	    val b = rs1(7 downto 0)
	    val r = (idx).mux(
		0 -> rs3(31 downto  8) ## b,
		1 -> rs3(31 downto 16) ## b ## rs3( 7 downto  0),
		2 -> rs3(31 downto 24) ## b ## rs3(15 downto  0),
		3 ->                      b ## rs3(23 downto  0)
	    )
	    r // return value
	}

	def fun_smaqa(rs1: Bits, rs2: Bits, rs3: Bits) : Bits = {
	    val h0 = (rs1( 7 downto  0).asSInt * rs2( 7 downto  0).asSInt).resize(18)
	    val h1 = (rs1(15 downto  8).asSInt * rs2(15 downto  8).asSInt).resize(18)
	    val h2 = (rs1(23 downto 16).asSInt * rs2(23 downto 16).asSInt).resize(18)
	    val h3 = (rs1(31 downto 24).asSInt * rs2(31 downto 24).asSInt).resize(18)
	    val r = rs3.asSInt + (h0 + h1 + h2 + h3)

	    r.asBits.resize(32) // return value
	}
	def fun_umaqa(rs1: Bits, rs2: Bits, rs3: Bits) : Bits = {
	// 18 bits needed so that intermediate sums don't overflow
	    val h0 = (rs1( 7 downto  0).asUInt * rs2( 7 downto  0).asUInt).resize(18)
	    val h1 = (rs1(15 downto  8).asUInt * rs2(15 downto  8).asUInt).resize(18)
	    val h2 = (rs1(23 downto 16).asUInt * rs2(23 downto 16).asUInt).resize(18)
	    val h3 = (rs1(31 downto 24).asUInt * rs2(31 downto 24).asUInt).resize(18)
	    val r = rs3.asUInt + (h0 + h1 + h2 + h3)

	    r.asBits.resize(32) // return value
	}

	def fun_zunpkd8(rs1: Bits, ctrl: Bits) : Bits = {
		val r = (ctrl).mux(
			default    -> rs1(15 downto  8).resize(16) ## rs1( 7 downto  0).resize(16), // B"4'b0100"
			B"4'b0101" -> rs1(23 downto 16).resize(16) ## rs1( 7 downto  0).resize(16),
			B"4'b0110" -> rs1(31 downto 24).resize(16) ## rs1( 7 downto  0).resize(16),
			B"4'b0111" -> rs1(31 downto 24).resize(16) ## rs1(15 downto  8).resize(16),
			B"4'b1011" -> rs1(31 downto 24).resize(16) ## rs1(23 downto 16).resize(16)
		)
		r // return value
	}
	def fun_sunpkd8(rs1: Bits, ctrl: Bits) : Bits = {
		val r = (ctrl).mux(
			default    -> rs1(15 downto  8).asSInt.resize(16).asBits ## rs1( 7 downto  0).asSInt.resize(16).asBits, // B"4'b0100"
			B"4'b0101" -> rs1(23 downto 16).asSInt.resize(16).asBits ## rs1( 7 downto  0).asSInt.resize(16).asBits,
			B"4'b0110" -> rs1(31 downto 24).asSInt.resize(16).asBits ## rs1( 7 downto  0).asSInt.resize(16).asBits,
			B"4'b0111" -> rs1(31 downto 24).asSInt.resize(16).asBits ## rs1(15 downto  8).asSInt.resize(16).asBits,
			B"4'b1011" -> rs1(31 downto 24).asSInt.resize(16).asBits ## rs1(23 downto 16).asSInt.resize(16).asBits
		)
		r // return value
	}

// saturating, csr is missing
// it seems sat() (and its shortcut +| and -|) in SpinalHDL don't do what I need
// for unsigned substraction (no way to tell the difference between overflow
// and underflow unless going signed, I think)
   def fun_satsub8u(a: Bits, b: Bits) : Bits = {
   	   val s = (B"1'b0" ## a).asSInt -^ (B"1'b0" ## b).asSInt // -^ will keep 10 bits
	   // if sign bit set -> underflow, else if bit eight set -> overflow
	   val r = ((s(9).asUInt === 1) ? (B"8'x00") | ((s(8).asUInt === 1) ? (B"8'xFF") | (s(7 downto 0).asBits)))
	   
	   r // return value
   }

	def fun_kadd8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt +| rs2( 7 downto  0).asSInt).asBits.resize(8)
	    val b1 = (rs1(15 downto  8).asSInt +| rs2(15 downto  8).asSInt).asBits.resize(8)
	    val b2 = (rs1(23 downto 16).asSInt +| rs2(23 downto 16).asSInt).asBits.resize(8)
	    val b3 = (rs1(31 downto 24).asSInt +| rs2(31 downto 24).asSInt).asBits.resize(8)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_ukadd8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asUInt +| rs2( 7 downto  0).asUInt).asBits.resize(8)
	    val b1 = (rs1(15 downto  8).asUInt +| rs2(15 downto  8).asUInt).asBits.resize(8)
	    val b2 = (rs1(23 downto 16).asUInt +| rs2(23 downto 16).asUInt).asBits.resize(8)
	    val b3 = (rs1(31 downto 24).asUInt +| rs2(31 downto 24).asUInt).asBits.resize(8)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_ksub8(rs1: Bits, rs2: Bits) : Bits = {
	    val b0 = (rs1( 7 downto  0).asSInt -| rs2( 7 downto  0).asSInt).asBits.resize(8)
	    val b1 = (rs1(15 downto  8).asSInt -| rs2(15 downto  8).asSInt).asBits.resize(8)
	    val b2 = (rs1(23 downto 16).asSInt -| rs2(23 downto 16).asSInt).asBits.resize(8)
	    val b3 = (rs1(31 downto 24).asSInt -| rs2(31 downto 24).asSInt).asBits.resize(8)

	    b3 ## b2 ## b1 ## b0 // return value
	}
	def fun_uksub8(rs1: Bits, rs2: Bits) : Bits = {
		val b0 = fun_satsub8u(rs1( 7 downto  0), rs2( 7 downto  0)).asBits
		val b1 = fun_satsub8u(rs1(15 downto  8), rs2(15 downto  8)).asBits
		val b2 = fun_satsub8u(rs1(23 downto 16), rs2(23 downto 16)).asBits
		val b3 = fun_satsub8u(rs1(31 downto 24), rs2(31 downto 24)).asBits

	    b3 ## b2 ## b1 ## b0 // return value
	}

// End prologue
} // object Plugin
class GoblinPlugin(earlyInjection : Boolean = true) extends Plugin[VexRiscv] {
	import GoblinPlugin._
	object IS_Goblin extends Stageable(Bool)
	object Goblin_FINAL_OUTPUT extends Stageable(Bits(32 bits))
	override def setup(pipeline: VexRiscv): Unit = {
		import pipeline.config._
		val immediateActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.IMI,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			IS_Goblin -> True
			)
		val binaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			SRC2_CTRL                -> Src2CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			RS2_USE -> True,
			IS_Goblin -> True
			)
		val unaryActions = List[(Stageable[_ <: BaseType],Any)](
			SRC1_CTRL                -> Src1CtrlEnum.RS,
			REGFILE_WRITE_VALID      -> True,
			BYPASSABLE_EXECUTE_STAGE -> Bool(earlyInjection),
			BYPASSABLE_MEMORY_STAGE  -> True,
			RS1_USE -> True,
			IS_Goblin -> True
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
			IS_Goblin -> True
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
			IS_Goblin -> True
			)
		def UKADD8_KEY = M"0011100----------000-----1110111"
		def UKSUB8_KEY = M"0011101----------000-----1110111"
		val decoderService = pipeline.service(classOf[DecoderService])
		decoderService.addDefault(IS_Goblin, False)
		decoderService.add(List(
			UKADD8_KEY	-> (binaryActions ++ List(GoblinCtrl -> GoblinCtrlEnum.CTRL_pdpikadd8, GoblinCtrlpdpikadd8 -> GoblinCtrlpdpikadd8Enum.CTRL_UKADD8)),
			UKSUB8_KEY	-> (binaryActions ++ List(GoblinCtrl -> GoblinCtrlEnum.CTRL_pdpikadd8, GoblinCtrlpdpikadd8 -> GoblinCtrlpdpikadd8Enum.CTRL_UKSUB8))
		))
	} // override def setup
	override def build(pipeline: VexRiscv): Unit = {
		import pipeline._
		import pipeline.config._
		execute plug new Area{
			import execute._
			val val_pdpikadd8 = input(GoblinCtrlpdpikadd8).mux(
				GoblinCtrlpdpikadd8Enum.CTRL_UKADD8 -> fun_ukadd8(input(SRC1), input(SRC2)).asBits,
				GoblinCtrlpdpikadd8Enum.CTRL_UKSUB8 -> fun_uksub8(input(SRC1), input(SRC2)).asBits
			) // mux pdpikadd8
			insert(Goblin_FINAL_OUTPUT) := val_pdpikadd8.asBits
		} // execute plug newArea
		val injectionStage = if(earlyInjection) execute else memory
		injectionStage plug new Area {
			import injectionStage._
			when (arbitration.isValid && input(IS_Goblin)) {
				output(REGFILE_WRITE_DATA) := input(Goblin_FINAL_OUTPUT)
			} // when input is
		} // injectionStage plug newArea
	} // override def build
} // class Plugin
