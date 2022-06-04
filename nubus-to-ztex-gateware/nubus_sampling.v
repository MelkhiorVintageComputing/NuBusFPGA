/*
 * NuBus sampling
 * 
 * Romain Dolbeau <romain@dolbeau.org> for the NuBusFPGA
 * Copyright (c) 2021022
 */

/* This module is running on the FPGA */

module nubus_sampling
   (
    /* *** NuBus signals *** */
	/* those are connected to the FPGA */
	/* connected via the CPLD */
    input 		  nub_clkn, // Clock (rising is driving edge, faling is sampling) 
    input 		  nub_resetn, // Reset
    //input [ 3:0]  nub_idn, // Slot Identification
    input 		  nub_tm0n, // Transfer Mode
    input 		  nub_tm1n, // Transfer Mode
    input 		  nub_startn, // Start
    input 		  nub_rqstn, // Request
    input 		  nub_ackn, // Acknowledge

	// connected via the CPLD but NuBus90 (unimplemented)
	//input 		  nub_clk2xn, 
 	//inout 		  nub_tm2n,

	/* connected via the 74LVT245 */
    input [31:0]  nub_adn, // Address/Data

	/* those are not used, and not even connected in the board */
    // inout 		  nub_pfwn, // Power Fail Warning
    // inout 		  nub_spn, // System Parity
    // inout 		  nub_spvn, // System Parity Valid

	/* those ared used but handled in directly in the Litex code */
    // output 		  nub_nmrqn, // Non-Master Request, handled in the Litex code

	/* those are used but connected only to the CPLD */
	/* we deal with the CPLD via 'arbcy_n' and 'grant' */
    // inout [ 3:0]  nub_arbn, // Arbitration

	output 		  tm0,
	output 		  tm1,
	output 		  start,
	output        rqst,
	output 		  ack,
	output [31:0] ad,

	output [3:0]  sel,
	output 		  block,
	output        busy
	);
   	 
   reg 			  reg_tm0n, reg_tm1n;
   reg 			  reg_startn;
   reg 			  reg_rqstn;
   reg 			  reg_ackn;
   reg [31:0] 	  reg_adn;
   reg 			  reg_busy;
   
			  
   always @(negedge nub_clkn) begin: proc_sampling
	  if (~nub_resetn) begin
		 reg_tm0n <= 1;
		 reg_tm1n <= 1;
		 reg_startn <= 1;
		 reg_rqstn <= 1;
		 reg_ackn <= 1;
		 reg_adn <= 0;
		 reg_busy <= 0;
	  end else begin
		 reg_tm0n <= nub_tm0n;
		 reg_tm1n <= nub_tm1n;
		 reg_startn <= nub_startn;
		 reg_rqstn <= nub_rqstn;
		 reg_ackn <= nub_ackn;
		 reg_adn <= nub_adn;
		 reg_busy <= ~reg_busy & nub_ackn & ~nub_startn /* beginning of transaction */
			   	   |  reg_busy & nub_ackn &  nub_resetn; /* hold during cycle */
	  end
   end

   assign tm0 = ~reg_tm0n;
   assign tm1 = ~reg_tm1n;
   assign start = ~reg_startn;
   assign rqst = ~reg_rqstn;
   assign ack = ~reg_ackn;
   assign ad = ~reg_adn;
   assign busy = reg_busy;

   // write selector for Wishbone
   assign sel[3] =   ~reg_tm1n & ~reg_adn[1] & ~reg_adn[0] & ~reg_tm0n /* Byte 3 */
                   | ~reg_tm1n & ~reg_adn[1] & ~reg_adn[0] &  reg_tm0n /* Half 1 */
                   | ~reg_tm1n &  reg_adn[1] &  reg_adn[0] &  reg_tm0n /* Word */
                   ;
   assign sel[2] =   ~reg_tm1n & ~reg_adn[1] &  reg_adn[0] & ~reg_tm0n /* Byte 2 */
                   | ~reg_tm1n & ~reg_adn[1] & ~reg_adn[0] &  reg_tm0n /* Half 1 */
                   | ~reg_tm1n &  reg_adn[1] &  reg_adn[0] &  reg_tm0n /* Word */
                   ;
   assign sel[1] =   ~reg_tm1n &  reg_adn[1] & ~reg_adn[0] & ~reg_tm0n /* Byte 1 */
                   | ~reg_tm1n &  reg_adn[1] & ~reg_adn[0] &  reg_tm0n /* Half 0 */
                   | ~reg_tm1n &  reg_adn[1] &  reg_adn[0] &  reg_tm0n /* Word */
                   ;
   assign sel[0] =   ~reg_tm1n &  reg_adn[1] &  reg_adn[0] & ~reg_tm0n /* Byte 0 */
                   | ~reg_tm1n &  reg_adn[1] & ~reg_adn[0] &  reg_tm0n /* Half 0 */
                   | ~reg_tm1n &  reg_adn[1] &  reg_adn[0] &  reg_tm0n /* Word */
                   ;

   assign block = ~reg_adn[1] & reg_adn[0] & reg_tm0n; // 1x block write or 1x block read
   
endmodule
