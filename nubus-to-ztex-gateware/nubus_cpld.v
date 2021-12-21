module nubus_cpld
  (
   input fpga_to_cpld_clk, // unused (extra line from FPGA to CPLD, pin is a clk input)
	input fpga_to_cpld_signal, // unused (extra line from FPGA to CPLD)
   input fpga_to_cpld_signal_2, // unused (extra line from FPGA to CPLD)
   input tmoen,
   input [3:0] id_n_5v,    // ID of this card
   inout [3:0] arb_n_5v,   // NuBus arbiter's lines
   input       arb, // enable arbitter
   output      grant,   // Grant access
   input reset_n_5v, // reset from NuBus, forwarded
   input nubus_oe, // disable all 5v drivers
   output reset_n_3v3, // nubus reset to FPGA
   input nubus_master_dir, // direction of signals, i.e. are we in master mode
   output clk_n_3v3, // nubus clk to FPGA
   output [3:0] id_n_3v3, // nubus ID of this card to FPGA
   inout tm0_n_3v3, // nubus tm0 to/from FPGA
   inout tm1_n_3v3, // nubus tm1 to/from FPGA
   inout tm0_n_5v, // tm0 from/to NuBus
   inout tm1_n_5v, // tm1 from/to NuBus
   input clk_n_5v, // clk from NuBus
   inout start_n_3v3, // start to/from FPGA
   inout ack_n_3v3, // ack from/to FPGA
   inout start_n_5v, // start from/to NuBus
   inout ack_n_5v, // ack to/from NuBus
	inout rqst_n_5v,
	inout rqst_n_3v3
   );

   // clock and pure in -> out pass_through are always on
   assign clk_n_3v3 = clk_n_5v;
   assign id_n_3v3 = id_n_5v;
   assign reset_n_3v3 = reset_n_5v;

   // nubus_master_dir-controlled signals, Z when nubus_oe is off
   assign start_n_5v = nubus_oe ? 'bZ : ( nubus_master_dir ? start_n_3v3 : 'bZ); // master out
   assign start_n_3v3 = nubus_oe ? 'bZ : (~nubus_master_dir ? start_n_5v : 'bZ); // master in
	
   assign rqst_n_5v = nubus_oe ? 'bZ : ( nubus_master_dir ? rqst_n_3v3 : 'bZ); // master out
   assign rqst_n_3v3 = nubus_oe ? 'bZ : (~nubus_master_dir ? rqst_n_5v : 'bZ); // master in
	
   assign ack_n_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? ack_n_3v3  : 'bZ); // slave out/in
   assign tm0_n_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? tm0_n_3v3  : 'bZ); // slave out/in
   assign tm1_n_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? tm1_n_3v3  : 'bZ); // slave out/in
   assign ack_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? ack_n_5v   : 'bZ); // slave out/in
   assign tm0_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? tm0_n_5v   : 'bZ); // slave in/out
   assign tm1_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? tm1_n_5v   : 'bZ); // slave in/out

   nubus_arbiter UArbiter
     (
      .idn(id_n_5v),
      .arbn(arb_n_5v),
      .arbcyn(arb),
      .grant(grant)
      );
   
endmodule // nubus_cpld
