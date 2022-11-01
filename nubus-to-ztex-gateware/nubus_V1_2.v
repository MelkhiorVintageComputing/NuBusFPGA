/*
 * NuBus controller
 * 
 * Autor: Valeriya Pudova (hww.github.io)
 * Adapted by Romain Dolbeau <romain@dolbeau.org> for the NuBusFPGA
 * Copyright (c) 2021-2022
 */

/* This module is running on the FPGA */

module nubus
  #(
    // All slots area starts with address $FXXX XXXX
    parameter SLOTS_ADDRESS  = 'hF, 
    // All superslots starts at $9000 0000
    parameter SUPERSLOTS_ADDRESS = 'h9, 
    // Watch dog timer bits. Master controller will terminate transfer
    // after (2 ^ WDT_W) clocks
    parameter WDT_W = 8,
    // Local space of card start and end address. For example 0-5
    // makes local space address $00000000-$50000000
	// UNUSED in NuBusFPGA
    parameter LOCAL_SPACE_EXPOSED_TO_NUBUS = 0,
    parameter LOCAL_SPACE_START = 0,
    parameter LOCAL_SPACE_END = 5
    )

   (
    /* *** NuBus signals *** */
	/* those are connected to the FPGA */
    input 		  nub_clkn, // Clock (rising is driving edge, faling is sampling) 
    input 		  nub_resetn, // Reset
    input [ 3:0]  nub_idn, // Slot Identification
    // raw input
    input 		  nub_tm0n, // Transfer Mode
    input 		  nub_tm1n, // Transfer Mode
    input 		  nub_startn, // Start
    input 		  nub_rqstn, // Request
    input 		  nub_ackn, // Acknowledge
    // output to other part of the FPGA
    output 		  nub_tm0n_o, // Transfer Mode
    output 		  nub_tm1n_o, // Transfer Mode
    output 		  nub_startn_o, // Start
    output 		  nub_rqstn_o, // Request
    output 		  nub_ackn_o, // Acknowledge

	// NuBus90 (unimplemented)
	input 		  nub_clk2xn, 
 	input 		  nub_tm2n,
 	output 		  nub_tm2n_o,

	/* connected via the 74LVT245 */
    inout [31:0]  nub_adn, // Address/Data

	/* those are not used, and not even connected in the board */
    // inout 		  nub_pfwn, // Power Fail Warning
    // inout 		  nub_spn, // System Parity
    // inout 		  nub_spvn, // System Parity Valid

	/* those ared used but handled in directly in the Litex code */
    // output 		  nub_nmrqn, // Non-Master Request, handled in the Litex code

	/* those are used but connected only to the CPLD */
	/* we deal with the CPLD via 'arbcy_n' and 'grant' */
    // inout [ 3:0]  nub_arbn, // Arbitration
	
	 /* *** CPLD <-> FPGA signals, not in NuBus */
	output 		  arbcy_n, // request arbitration
	input 		  grant, // arbitration won
	output 		  tmoen, // output enable for tm0/1

	/* *** CPLD <-> FPGA signals, spare, currently unused */
	output 		  fpga_to_cpld_signal, // regular signal
	// inout 		  fpga_to_cpld_signal_2, // regular signal
	// inout 		  fpga_to_cpld_clk, // clk input on CPLD or regular signal

	/* FPGA -> drivers */
	output 		  NUBUS_AD_DIR, // direction for the LS245 (input/output for A/D lines)
	output 		  nubus_master_dir, // are we in master mode (to drive the proper signals)

    /* 'memory bus' signals; those are used to interface with the Wishbone to access the FPGA resources from NuBus */
    output 		  mem_valid,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output [ 3:0] mem_write,
    input 		  mem_ready,
    input [31:0]  mem_rdata,
    input 		  mem_error, // ignored
    input 		  mem_tryagain, // ignored
	
    /* 'processor bus' signals; those are used to interface with the Wishbone to access NuBus resources from the FPGA */
    input 		  cpu_valid,
    input [31:0]  cpu_addr,
    input [31:0]  cpu_wdata,
    input [ 3:0]  cpu_write,
    output 		  cpu_ready,
    output [31:0] cpu_rdata,
    input 		  cpu_lock,
    input 		  cpu_eclr, // ignored
    output [3:0]  cpu_errors, // ignored

	/* utilities signal from the NuBus stuff, currently unused */
    // Access to slot area
    output 		  mem_stdslot,
    // Access to superslot area ($sXXXXXXX where <s> is card id)
    output 		  mem_super,
    // Access to local memory on the card
    output 		  mem_local
  );

  `include "nubus.svh"

   // ==========================================================================
   // Colock and reset
   // ==========================================================================

   wire           nub_clk = ~nub_clkn;
   wire           nub_reset = ~nub_resetn;

   // ==========================================================================
   // Global signals 
   // ==========================================================================

   // ===== SLAVE =====
   //wire           slv_master;
   wire 		  slv_slave;     // output nubus_slave module; input internal               ; active during slave cycle
   wire 		  slv_tm1n;      // output nubus_slave module; input internal & nubus_membus
   wire 		  slv_tm0n;      // output nubus_slave module; input            nubus_membus
   wire 		  slv_ackcyn;    // output nubus_slave module; input                           nubus_driver
   wire 		  slv_myslotcy;  // output nubus_slave module; input internal &                nubus_driver
   wire unsigned [31:0] slv_addr;// output nubus_slave module; input            nubus_membus

   // ===== CPU ====
   wire unsigned [31:0] cpu_ad; // output nubus_master; input MUX to A/D lines 'nub_ad' (nub_ad then as an OE and an iverter to reach nub_adn)
   wire 				cpu_tm1n; // R(h)/W(l); output nubus_cpu; input nubus_driver & internal
   wire 				cpu_tm0n; // byte size(l); idem
   wire                 cpu_masterd; // ignored
   
   // ===== DRIVER =====
   wire 		  drv_tmoen; // output enable for tm0n/tm1n (== tmoen) by nubus_driver
   wire 		  drv_mstdn; // ??? only connected to driver as an output

   // ===== MASTER ===
   wire 		  mst_timeout; // timeout???; output nubus_master; input nubus_driver & nubus_slave
   wire 		  mst_arbcyn; // req. arb; output nubus_master; input internal & to CPLD & nubus_driver
   assign arbcy_n = mst_arbcyn;
   wire 		  mst_adrcyn; // during the address cycle for master; output nubus_master; input nubus_driver & nubus_cpubus
   wire 		  mst_lockedn; // for locked accesses (?); output nubus_master; input nubus_driver
   wire 		  mst_arbdn; // delay during arbitration; output nubus_master; input [NULL] ???
   wire 		  mst_busyn; // busy during transfer; output nubus_master; input [NULL] ???
   wire 		  mst_ownern; // master is bus owner; output nubus_master; input nubus_driver & internal
   wire 		  mst_dtacyn; // during the data cycle for master; output nubus_master; input nubus_driver & internal
   
   // ==========================================================================
   // Drive NuBus address-data line 
   // ==========================================================================

   // Should we be putting the address (instead of data) on the bus [see also nub_adoe]
   // yes during address cycle, or if we're reading (not writing) data
   // actually during write the CPU puts data in cpu_ad so also when writing
   // nub_adoe takes care of the enablement    
   wire 		  cpu_adsel = ~mst_adrcyn | ~mst_dtacyn;// & ~cpu_tm1n;
   // Select nubus address or data signals
   wire [31:0] nub_ad    =  cpu_adsel ? cpu_ad : mem_rdata;

   // Tri-state control for the A/D line
   // nub_adoe is the output enable, when 0 A/D lines are high-impedance
   // Slave: only drive the A/D lines to return data on a read (slave cycle with tm1n high)
   // Master: drives during (a) address cycle 
   //                       (b) data cycle when writing
   wire 	   nub_adoe =   slv_slave  & slv_tm1n /* SLAVE read of card */
			              | cpu_valid & ~mst_adrcyn /* MASTER address cycle*/
			              | ~mst_ownern & ~mst_dtacyn & ~cpu_tm1n /* MASTER data cycle, when writing*/
                       ;
   
   assign nub_adn  = nub_adoe ? ~nub_ad : 'bZ;
   /* for direction  */ 
   assign NUBUS_AD_DIR = ~nub_adoe;
   //assign nubus_master_dir = grant | ~mst_adrcyn | ~mst_arbdn | ~mst_ownern | ~mst_dtacyn;
   assign nubus_master_dir = ~mst_ownern;

   /* for slave access, enable the access during slv_myslotcy*/
   assign mem_valid = slv_myslotcy;

   // ==========================================================================
   // Slave FSM
   // ==========================================================================

   nubus_slave 
     #(
       .SLOTS_ADDRESS (SLOTS_ADDRESS), 
       .SUPERSLOTS_ADDRESS(SUPERSLOTS_ADDRESS),
       .SIMPLE_MAP(0),
	   // UNUSED in NuBusFPGA
       .LOCAL_SPACE_EXPOSED_TO_NUBUS(LOCAL_SPACE_EXPOSED_TO_NUBUS),
       .LOCAL_SPACE_START(LOCAL_SPACE_START),
       .LOCAL_SPACE_END(LOCAL_SPACE_END)
       )
   USlave
     (
      .nub_clkn(nub_clkn), // Clock
      .nub_resetn(nub_resetn), // Reset
      .nub_idn(nub_idn), // Card ID
      .nub_adn(nub_adn), // Address Data
      .nub_startn(nub_startn), // Transfer start
      .nub_ackn(nub_ackn), // Transfer end
      .nub_tm1n(nub_tm1n), // Transition mode 1 (Read/Write)
      .nub_tm0n(nub_tm0n),
      .mem_ready(mem_ready),
      .mst_timeout(mst_timeout),

      .slv_slave_o(slv_slave), // Slave mode
      .slv_tm1n_o(slv_tm1n), // Latched transition mode 1 (Read/Write)
      .slv_tm0n_o(slv_tm0n),
      .slv_ackcyn_o(slv_ackcyn), // Acknowlege
      .slv_addr_o(slv_addr), // Slave address
      .slv_stdslot_o(mem_stdslot), // Starndard slot
      .slv_super_o(mem_super), // Superslot
      .slv_local_o(mem_local), // Local area
      .slv_myslotcy_o(slv_myslotcy) // Any slot
      );
   
   // ==========================================================================
   // Master FSM
   // ==========================================================================

   nubus_master
    #(
      .WDT_W(WDT_W)
     ) 
     UMaster
     (
      .nub_clkn(nub_clkn), // Clock
      .nub_resetn(nub_resetn), // Reset
      .nub_rqstn(nub_rqstn), // Bus request
      .nub_startn(nub_startn), // Start transfer
      .nub_ackn(nub_ackn), // End of transfer
      .arb_grant(grant), // Grant access
      .cpu_lock(cpu_lock), // Address line
      .cpu_masterd(cpu_valid), // Master mode (delayed) // FIXME: ignoring cpu_masterd which is always 0 (see below)

      .mst_lockedn_o(mst_lockedn), // Locked or not tranfer
      .mst_arbdn_o(mst_arbdn),
      .mst_busyn_o(mst_busyn),
      .mst_ownern_o(mst_ownern), // Address or data transfer
      .mst_dtacyn_o(mst_dtacyn), // Data strobe
      .mst_adrcyn_o(mst_adrcyn), // Address strobe
      .mst_arbcyn_o(mst_arbcyn), // Arbiter enabled
      .mst_timeout_o(mst_timeout)
   );

   // ==========================================================================
   // Driver Nubus
   // ==========================================================================

   assign tmoen = drv_tmoen;
   
   nubus_driver UNDriver
     (
      .slv_ackcyn(slv_ackcyn), // Acknowlege
      .mst_arbcyn(mst_arbcyn), // Arbiter enabled
      .mst_adrcyn(mst_adrcyn), // Address strobe
      .mst_dtacyn(mst_dtacyn), // Data strobe
      .mst_ownern(mst_ownern), // Master is owner of the bus
      .mst_lockedn(mst_lockedn), // Locked or not transfer
      .mst_tm1n(cpu_tm1n), // Address lines
      .mst_tm0n(cpu_tm0n), // Address lines
      .mst_timeout(mst_timeout),
      .mis_errorn(TMN_COMPLETE),
      .nub_tm0n_o(nub_tm0n_o), // Transfer mode
      .nub_tm1n_o(nub_tm1n_o), // Transfer mode
      .nub_ackn_o(nub_ackn_o), // Achnowlege
      .nub_startn_o(nub_startn_o), // Transfer start
      .nub_rqstn_o(nub_rqstn_o), // Bus request
      .nub_rqstoen_o(fpga_to_cpld_signal), // Bus request enable
      .drv_tmoen_o(drv_tmoen), // Transfer mode enable
      .drv_mstdn_o(drv_mstdn) // Guess: Slave sends /ACK. Master responds with /MSTDN, which allows slave to clear /ACK and listen for next transaction.
      );

   // ==========================================================================
   // CPU Interface
   // ==========================================================================

   assign cpu_rdata = ~nub_adn;
   assign cpu_ready = ~nub_ackn & nub_startn & ~mst_ownern; // if mst_ownern is inactive (high), then we're seeing the ACK from the previous slave transaction that we were waiting on

   nubus_cpubus UCPUBus
     (
      .nub_clkn(nub_clkn),
      .nub_resetn(nub_resetn),
      .mst_adrcyn(mst_adrcyn),
      .cpu_valid(cpu_valid),
      .cpu_write(cpu_write),
      .cpu_addr(cpu_addr),
      .cpu_wdata(cpu_wdata),
      .cpu_ad_o(cpu_ad),
      .cpu_tm1n_o(cpu_tm1n),
      .cpu_tm0n_o(cpu_tm0n),
      .cpu_error_o(cpu_errors),
      .cpu_masterd_o(cpu_masterd) // FIXME, set to 0 in Xibus nubus_cpubus
      );

   // ==========================================================================
   // Memory Interface
   // ==========================================================================
   
   nubus_membus UMemBus 
     (
      .nub_clkn(nub_clkn), // Clock
      .nub_resetn(nub_resetn), // Reset
      .nub_adn(nub_adn),

      .slv_tm1n(slv_tm1n),
      .slv_tm0n(slv_tm0n),
      .slv_myslotcy(slv_myslotcy),
      .slv_addr(slv_addr),

      .mem_addr_o(mem_addr),
      .mem_write_o(mem_write),
      .mem_wdata_o(mem_wdata) 
      );
   

endmodule

