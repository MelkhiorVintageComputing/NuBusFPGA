/*
 * NuBus controller
 * 
 * Autor: Valeriya Pudova (hww.github.io)
 */

module nubus
  #(
    // All slots area starts with addrss $FXXX XXXX
    parameter SLOTS_ADDRESS  = 'hF, 
    // All superslots starts at $9000 0000
    parameter SUPERSLOTS_ADDRESS = 'h9, 
    // Watch dog timer bits. Master controller will terminate transfer
    // after (2 ^ WDT_W) clocks
    parameter WDT_W = 8,
    // Local space of card start and end addres. For example 0-5
    // makes local space address $00000000-$50000000
    parameter LOCAL_SPACE_EXPOSED_TO_NUBUS = 0,
    parameter LOCAL_SPACE_START = 0,
    parameter LOCAL_SPACE_END = 5,
    // Generate parity without ECC memory
    parameter NON_ECC_PARITY = 0
    )

   (
    /* NuBus signals */

    input 		  nub_clkn, // Clock (rising is driving edge, faling is sampling) 
    input 		  nub_resetn, // Reset
    input [ 3:0]  nub_idn, // Slot Identificatjon

    // inout 		  nub_pfwn, // Power Fail Warning
    inout [31:0]  nub_adn, // Address/Data
    inout 		  nub_tm0n, // Transfer Mode
    inout 		  nub_tm1n, // Transfer Mode
    inout 		  nub_startn, // Start
    inout 		  nub_rqstn, // Request
    inout 		  nub_ackn, // Acknowledge
    // inout [ 3:0]  nub_arbn, // Arbitration
	output 		  arb,
	input 		  grant,
	output 		  tmoen,
	output 		  NUBUS_AD_DIR, 

    inout 		  nub_nmrqn, // Non-Master Request
    // inout 		  nub_spn, // System Parity
    // inout 		  nub_spvn, // System Parity Valid

    /* Memory bus signals connected to a memory, accesible by nubus or processor */

    output 		  mem_valid,
    output [31:0] mem_addr,
    output [31:0] mem_wdata,
    output [ 3:0] mem_write,
    input 		  mem_ready,
    input [31:0]  mem_rdata,
    input 		  mem_error,
    input 		  mem_tryagain,

    // Access to slot area
    output 		  mem_stdslot,
    // Access to superslot area ($sXXXXXXX where <s> is card id)
    output 		  mem_super,
    // Access to local memory on the card
    output 		  mem_local,

	// NuBus90 (unimplemented)
	input         nub_clk2xn,
 	inout         nub_tm2n  
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

   wire           slv_master, slv_slave, slv_tm1n, slv_tm0n, slv_ackcyn, slv_myslotcy;
   wire unsigned [31:0] slv_addr;
   wire           drv_tmoen, drv_mstdn;

   wire 		  mst_timeout;
   
   // ==========================================================================
   // Drive NuBus address-data line 
   // ==========================================================================

   // Select nubus data signals
   wire [31:0] nub_ad    = mem_rdata;

   // When 1 - drive the NuBus AD lines 
   wire        nub_adoe  =   slv_slave  & slv_tm1n
               /*SLAVE read of card*/
                       ;
   // Output to nubus the 
   assign nub_adn  = nub_adoe ? ~nub_ad : 'bZ;

   assign mem_valid = slv_myslotcy;
   
   assign NUBUS_AD_DIR = ~nub_adoe;

   // ==========================================================================
   // Parity checking
   // ==========================================================================

   //wire        parity   = ~^nub_adn;
   //wire        nub_noparity = NON_ECC_PARITY & ~nub_adoe & ~nub_spvn & nub_spn == parity;

   //assign nub_spn  = NON_ECC_PARITY &  nub_adoe ? parity : 'bZ;
   //assign nub_spvn = NON_ECC_PARITY &  nub_adoe ? 0 : 'bZ;

   // ==========================================================================
   // Slave FSM
   // ==========================================================================

   nubus_slave 
     #(
       .SLOTS_ADDRESS (SLOTS_ADDRESS), 
       .SUPERSLOTS_ADDRESS(SUPERSLOTS_ADDRESS),
       .SIMPLE_MAP(0),
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
      .mst_timeout(0),

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
   // Driver Nubus
   // ==========================================================================

   assign tmoen = drv_tmoen;
   
   nubus_driver UNDriver
     (
      .slv_ackcyn(slv_ackcyn), // Achnowlege
      .mst_arbcyn(1), // Arbiter enabled
      .mst_adrcyn(1), // Address strobe
      .mst_dtacyn(1), // Data strobe
      .mst_ownern(1), // Master is owner of the bus
      .mst_lockedn(1), // Locked or not transfer
      .mst_tm1n(1), // Address ines
      .mst_tm0n(1), // Address ines
      .mst_timeout(0),
      .mis_errorn(TMN_COMPLETE),
      .nub_tm0n_o(nub_tm0n), // Transfer mode
      .nub_tm1n_o(nub_tm1n), // Transfer mode
      .nub_ackn_o(nub_ackn), // Achnowlege
      .nub_startn_o(nub_startn), // Transfer start
      .nub_rqstn_o(nub_rqstn), // Bus request
      .nub_rqstoen_o(nub_qstoen), // Bus request enable
      .drv_tmoen_o(drv_tmoen), // Transfer mode enable
      .drv_mstdn_o(drv_mstdn) // Guess: Slave sends /ACK. Master responds with /MSTDN, which allows slave to clear /ACK and listen for next transaction.
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

