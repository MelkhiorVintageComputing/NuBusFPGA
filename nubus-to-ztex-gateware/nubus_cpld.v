module nubus_cpld
  (
   // Control
   input  nubus_oe, // disable all 5v drivers
   input  tmoen, // tm output enable
   input  nubus_master_dir, // direction of signals, i.e. are we in master mode

   // NuBus (input to CPLD)
   input  [3:0] id_n_5v,    // ID of this card
   input  reset_n_5v, // reset from NuBus, forwarded
   input  clk_n_5v, // clk from NuBus
   input  clk2x_n_5v, // clk from NuBus90

   // Spares
   input  fpga_to_cpld_clk, // unused (extra line from FPGA to CPLD, pin is a clk input)
   inout  fpga_to_cpld_signal, // unused (extra line from FPGA to CPLD)
   inout  fpga_to_cpld_signal_2, // unused (extra line from FPGA to CPLD)

   // NuBus (output to FPGA)
   output [3:0] id_n_3v3, // nubus ID of this card to FPGA
   output reset_n_3v3, // nubus reset to FPGA
   output clk_n_3v3, // nubus clk to FPGA
   output clk2x_n_3v3, // nubus90 clk to FPGA
   
   // NuBus Arbiter
   input  arb, // enable arbitter
   input  [3:0] arb_n_5v,   // NuBus arbiter's lines
   output [3:0] arb_o_n,   // NuBus arbiter's control lines
   output grant,   // Grant access

   // Cycle Control (NuBus two-way)
   inout  tm0_n_3v3, // nubus tm0 to/from FPGA
   input  tm0_n_5v, // tm0 from/to NuBus
   output tm0_o_n, // start from NuBus
   
   inout  tm1_n_3v3, // nubus tm1 to/from FPGA
   input  tm1_n_5v, // tm1 from/to NuBus
   output tm1_o_n, // start from NuBus
   output tmx_oe_n, // start from NuBus
   
   inout  tm2_n_3v3, // nubus tm2 to/from FPGA
   input  tm2_n_5v, // tm2 from/to NuBus
   output tm2_o_n, // start from NuBus
   output tm2_oe_n, // start from NuBus
   
   inout  start_n_3v3, // start to/from FPGA
   input  start_n_5v, // start from NuBus
   output start_o_n, // start from NuBus
   output start_oe_n, // start from NuBus
   
   
   inout  ack_n_3v3, // ack from/to FPGA
   inout  ack_n_5v, // ack from NuBus
   output ack_o_n, // ack to NuBus
   output ack_oe_n, // ack OE NuBus

   // Master Request (OC)
   input  rqst_n_5v,  // rqst from NuBus; needs monitoring before driving
   inout  rqst_n_3v3, // rqst from/to FPGA; needs monitoring before driving?; needed? or is arb enough?
   output rqst_o_n // rqst to NuBus
   );
	
   // placeholder to make pretend we use the signals
   assign fpga_to_cpld_signal_2 = fpga_to_cpld_signal ^ fpga_to_cpld_clk;
   // placeholders
   assign clk2x_n_3v3 = clk2x_n_5v;
   assign tm2_n_3v3 = tm2_n_5v;
	assign tm2_o_n = 0;
	assign tm2_oe_n = 1;
   
   // clock and pure in -> out pass_through are always on
   assign clk_n_3v3 = clk_n_5v;
   assign id_n_3v3 = id_n_5v;
   assign reset_n_3v3 = reset_n_5v;
   
   // ~nubus_master_dir-controlled signals
   //assign start_o_5v  = nubus_oe ? 'bZ : ( nubus_master_dir ? start_n_3v3 : 'bZ); // master out
   assign start_o_n   = nubus_oe ?   1 : ( nubus_master_dir ? start_n_3v3 : 1); // master out
   assign start_oe_n  = nubus_oe ?   1 : ( nubus_master_dir ? 0 : 1); // master out
   assign start_n_3v3 = nubus_oe ? 'bZ : (~nubus_master_dir ? start_n_5v  : 'bZ); // master in
   
   // rqst_o_n is always driven (the 74lvt125 wired as open collector will convert 1 to Z) and is active low
   assign rqst_o_n   = nubus_oe ?   1 : ( nubus_master_dir ? rqst_n_3v3 :  1); // master out
   assign rqst_n_3v3 = nubus_oe ? 'bZ : (~nubus_master_dir ? rqst_n_5v : 'bZ); // master in
	
   //assign ack_o_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? ack_n_3v3 : 'bZ); // slave out/in
   assign ack_o_n    = nubus_oe ?   1 : ((nubus_master_dir ^ ~tmoen) ? ack_n_3v3 : 1); // slave out/in
   assign ack_oe_n   = nubus_oe ?   1 : ((nubus_master_dir ^ ~tmoen) ? 0 : 1); // slave out/in
   assign ack_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? ack_n_5v  : 'bZ); // slave out/in
   
   //assign tm0_n_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? tm0_n_3v3  : 'bZ); // slave out/in
   //assign tm1_n_5v   = nubus_oe ? 'bZ : ((nubus_master_dir ^ ~tmoen) ? tm1_n_3v3  : 'bZ); // slave out/in
   assign tm0_o_n    = nubus_oe ?   1 : ((nubus_master_dir ^ ~tmoen) ? tm0_n_3v3 : 1); // slave out/in
   assign tm1_o_n    = nubus_oe ?   1 : ((nubus_master_dir ^ ~tmoen) ? tm1_n_3v3 : 1); // slave out/in
   assign tmx_oe_n   = nubus_oe ?   1 : ((nubus_master_dir ^ ~tmoen) ? 0 : 1); // slave out/in
   assign tm0_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? tm0_n_5v   : 'bZ); // slave in/out
   assign tm1_n_3v3  = nubus_oe ? 'bZ : ((nubus_master_dir ^  tmoen) ? tm1_n_5v   : 'bZ); // slave in/out

   nubus_arbiter UArbiter
     (
      .idn(id_n_5v),
      .arbn(arb_n_5v),
      .arbon(arb_o_n),
      .arbcyn(arb),
      .grant(grant)
      );
   
endmodule // nubus_cpld
