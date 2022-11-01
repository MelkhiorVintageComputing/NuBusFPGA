module nubus_cpldinfpga
  (
   // Control
   input  nubus_oe, // disable all 5v drivers
   input  tmoen, // tm output enable
   input  nubus_master_dir, // direction of signals, i.e. are we in master mode

   // Spares
   input  rqst_oe_n, // rqstoen (extra line from FPGA to CPLD)

   // NuBus 
   input [3:0] id_n_3v3, // nubus ID of this card to FPGA
   
   // NuBus Arbiter
   input  arbcy_n, // enable arbitter
   input  [3:0] arb_n_3v3,   // NuBus arbiter's lines
   output [3:0] arb_o_n,   // NuBus arbiter's control lines
   output grant,   // Grant access

   // Cycle Control (NuBus two-way)
   input  tm0_n_3v3, // nubus tm0 to/from FPGA
   output tm0_o_n, // start from NuBus
   
   input  tm1_n_3v3, // nubus tm1 to/from FPGA
   output tm1_o_n, // start from NuBus
   output tmx_oe_n, // start from NuBus
   
   input  tm2_n_3v3, // nubus tm2 to/from FPGA
   output tm2_o_n, // start from NuBus
   output tm2_oe_n, // start from NuBus
   
   input  start_n_3v3, // start to/from FPGA
   output start_o_n, // start from NuBus
   output start_oe_n, // start from NuBus
   
   input  ack_n_3v3, // ack from/to FPGA
   output ack_o_n, // ack to NuBus
   output ack_oe_n, // ack OE NuBus

   // Master Request (OC)
   input  rqst_n_3v3, // rqst from/to FPGA
   output rqst_o_n // rqst to NuBus
   );
	
   // placeholders
   assign tm2_o_n = 0;
   assign tm2_oe_n = 1;
   
   // ~nubus_master_dir-controlled signals
   assign start_o_n   = nubus_oe ?   1 : ( nubus_master_dir ? start_n_3v3 : 1); // master out
   assign start_oe_n  = nubus_oe ?   1 : ( nubus_master_dir ? 0 : 1); // master out
   
   // rqst_o_n is always driven (the 74lvt125 wired as open collector will convert 1 to Z) and is active low
   assign rqst_o_n   = nubus_oe ?   1 : (~rqst_oe_n ? rqst_n_3v3 :  1); // master out
   
   assign ack_o_n    = nubus_oe ?   1 : (( ~tmoen) ? ack_n_3v3 : 1); // slave out/in
   assign ack_oe_n   = nubus_oe ?   1 : (( ~tmoen) ? 0 : 1); // slave out/in
   
   assign tm0_o_n    = nubus_oe ?   1 : (( ~tmoen) ? tm0_n_3v3 : 1); // slave out/in
   assign tm1_o_n    = nubus_oe ?   1 : (( ~tmoen) ? tm1_n_3v3 : 1); // slave out/in
   assign tmx_oe_n   = nubus_oe ?   1 : (( ~tmoen) ? 0 : 1); // slave out/in

   nubus_arbiter UArbiter
     (
      .idn(id_n_3v3),
      .arbn(arb_n_3v3),
      .arbon(arb_o_n),
      .arbcyn(arbcy_n),
      .grant(grant)
      );
   
endmodule // nubus_cpld
