`timescale 1 ns / 1 ps

module nubus_slave_tb ();

`include "nubus_tb.svh"

   parameter TEST_CARD_ID    = 'hc;
   parameter TEST_ADDR = 'hFc000000;
   parameter TEST_DATA = 'h87654321;
   parameter [1:0]  MEMORY_WAIT_CLOCKS = 1;   
   parameter DEBUG_NUBUS_START = 0;
   parameter ROM_ADDR =  'hFcFFF000;
   parameter PING_ADDR = 'hFcB00000;
   
   // Clock (rising is driving edge, faling is sampling) 
   tri1                bd_clk48; 
   
   // Slot Identification
   tri1 [3:0]          nub_idn; 
   // Clock (rising is driving edge, faling is sampling) 
   tri1                nub_clkn; 
   // Clock 90 (rising is driving edge, faling is sampling) 
   tri1                nub_clk2xn; 
   // Reset [Open Collector]
   tri1                nub_resetn; 
   // Power Fail Warning [Control]
   //tri1                nub_pfwn;
   // Address/Data [Address/Data]
   tri1 [31:0]         nub_adn;
   // Transfer Mode [Control]
   tri1                nub_tm0n;
   tri1                nub_tm1n;
   tri1                nub_tm2n;
   // Start [Control]
   tri1                nub_startn;
   // Request [Open Collector]
   tri1                nub_rqstn;
   // Acknowledge [Control]
   tri1                nub_ackn;
   // Arbitration [Open Collector]
   tri1 [3:0]          nub_arbn;
   // Non-Master Request [Open Collector]
   tri1                nub_nmrqn;
   // System Parity [Address/Data]
   //tri1                nub_spn;
   // System Parity Valid [Address/Data]
   //tri1                nub_spvn;

   tri1 [1:0] 		   leds;
   
   tri 			   unused0, tmoen, unused1, unused2;
   tri 			   arbcy_n;
   tri 			   grant;
   tri 			   nubus_oe, nubus_ad_dir;
   tri			   reset_n_3v3, clk_n_3v3, tm0_n_3v3, tm1_n_3v3, start_n_3v3, ack_n_3v3, rqst_n_3v3;
   tri [3:0] 		   id_n_3v3;
   tri [31:0] 		   ad_n_3v3;
   tri [3:0] 		   arb_o_n;
   tri 			   tm0_o_n, tm1_o_n, tmx_oe_n;
   tri 			   start_o_n, start_oe_n;
   tri 			   ack_o_n, ack_oe_n;
   tri 			   rqst_o_n;
   
   
   tri 			   clk2x_n_3v3;
   tri 			   tm2_n_3v3, tm2_o_n, tm2_oe_n;
   
  

   assign nub_idn = ~ TEST_CARD_ID;
   //assign nub_arbn = 'b1111;

   // actually 74lvt245, same digital function
   sn74fct245 shifters_b0(.data_5v(nub_adn[ 7: 0]),
			  .data_3v3(ad_n_3v3[ 7: 0]),
			  .nubus_oe(nubus_oe),
			  .nubus_ad_dir(nubus_ad_dir));
   sn74fct245 shifters_b1(.data_5v(nub_adn[15: 8]),
			  .data_3v3(ad_n_3v3[15: 8]),
			  .nubus_oe(nubus_oe),
			  .nubus_ad_dir(nubus_ad_dir));
   sn74fct245 shifters_b2(.data_5v(nub_adn[23:16]),
			  .data_3v3(ad_n_3v3[23:16]),
			  .nubus_oe(nubus_oe),
			  .nubus_ad_dir(nubus_ad_dir));
   sn74fct245 shifters_b3(.data_5v(nub_adn[31:24]),
			  .data_3v3(ad_n_3v3[31:24]),
			  .nubus_oe(nubus_oe),
			  .nubus_ad_dir(nubus_ad_dir));
   
   tri1 			   nmrq_3v3_n;
   
   
   sn74lvt145_quarter driver_u1a(.oe_n(nmrq_3v3_n),
								 .in(0),
								 .out(nub_nmrqn));
   sn74lvt145_quarter driver_u1b(.oe_n(rqst_o_n),
								 .in(0),
								 .out(nub_rqstn));
   sn74lvt145_quarter driver_u1c(.oe_n(start_oe_n),
								 .in(start_o_n),
								 .out(nub_startn));
   sn74lvt145_quarter driver_u1d(.oe_n(ack_oe_n),
								 .in(ack_o_n),
								 .out(nub_ackn));

   sn74lvt145_quarter driver_u3a(.oe_n(arb_o_n[0]),
								 .in(0),
								 .out(nub_arbn[0]));
   sn74lvt145_quarter driver_u3b(.oe_n(arb_o_n[1]),
								 .in(0),
								 .out(nub_arbn[1]));
   sn74lvt145_quarter driver_u3c(.oe_n(arb_o_n[3]),
								 .in(0),
								 .out(nub_arbn[3]));
   sn74lvt145_quarter driver_u3d(.oe_n(arb_o_n[2]),
								 .in(0),
								 .out(nub_arbn[2]));
   
   sn74lvt145_quarter driver_u2a(.oe_n(tmx_oe_n),
								  .in(tm1_o_n),
								  .out(nub_tm1n));
   sn74lvt145_quarter driver_u2b(.oe_n(tmx_oe_n),
								  .in(tm0_o_n),
								  .out(nub_tm0n));
   sn74lvt145_quarter driver_u2c(.oe_n(tm2_oe_n),
								  .in(tm2_o_n),
								  .out(nub_tm2n));
   
   sn74cb3t3125 shifters_u4(.oe_n('h0),
			    .A({start_n_3v3, ack_n_3v3, clk_n_3v3, rqst_n_3v3 }),
			    .B({nub_startn,  nub_ackn,  nub_clkn,  nub_rqstn }));
   sn74cb3t3125 shifters_u13(.oe_n('h0),
			     .A({reset_n_3v3, tm2_n_3v3, tm0_n_3v3, tm1_n_3v3}),
			     .B({nub_resetn,  nub_tm2n,  nub_tm0n,  nub_tm1n }));

   assign clk2x_n_3v3 = nub_clk2n;

   ztex213_nubus_V1_2 UNuBus (
			      // NuBus lines only
			      .clk48(bd_clk48),
			      .clk_3v3_n(clk_n_3v3),
			      .reset_3v3_n(reset_n_3v3),
			      .nubus_clk2x_n(clk2x_n_3v3),
			      .user_led0(leds[0]),
			      .user_led1(leds[1]),
			      .user_led2(leds[2]),
			      .user_led3(leds[3]),
			      .nubus_tm2_n(tm2_n_3v3),
			      .id_3v3_n(id_n_3v3),
			      .ad_3v3_n(ad_n_3v3),
			      .tm0_3v3_n(tm0_n_3v3),
			      .tm1_3v3_n(tm1_n_3v3),
			      .tm0_o_n(tm0_o_n),
			      .tm1_o_n(tm1_o_n),
			      .tmx_oe_n(tmx_oe_n),
			      .start_3v3_n(start_n_3v3),
			      .start_o_n(start_o_n),
			      .start_oe_n(start_oe_n),
			      .rqst_3v3_n(rqst_n_3v3),
			      .rqst_o_n(rqst_o_n),
			      .nmrq_3v3_n(nmrq_n_3v3), // output only, direct to driver
			      .ack_3v3_n(ack_n_3v3),
			      .ack_o_n(ack_o_n),
			      .ack_oe_n(ack_oe_n),
			      .arb_n_3v3(arb_n_3v3),
			      .arb_o_n(arb_o_n),
			      .nubus_ad_dir(nubus_ad_dir),
			      .nubus_oe(nubus_oe),
			      .clk2x_3v3_n(clk2x_n_3v3),
			      .tm2_3v3_n(tm2_n_3v3),
			      .tm2_o_n(tm2_o_n),
			      .tm2_oe_n(tm2_oe_n)
			      );
   

   // State machine of test bench
   reg         tst_clkn;
   reg         tst_clk2xn;
   reg         tst_clk48;
   reg         tst_resetn;
   reg         tst_startn;
   reg         tst_ackn;    // half clkn delayed ackn
   reg [1:0]   tst_tmn;
   reg [1:0]   tst_statusn;
   reg [31:0]  tst_addrn;
   reg [31:0]  tst_wdatan;
   reg [31:0]  tst_rdatan;
   reg         tst_rqstn;

   reg 		   mastermode_start;
   reg 		   mastermode_tmack;
   
   assign nub_clkn     = tst_clkn;
   assign nub_clk2xn   = tst_clk2xn;
   assign bd_clk48     = tst_clk48;
   assign nub_resetn   = tst_resetn;
   assign nub_rqstn    = tst_rqstn;
   // Drive NuBus signals
   assign nub_startn   =                mastermode_start  ? 'bZ: tst_startn;   
   assign nub_tm0n     = (tst_startn & ~mastermode_tmack) ? 'bZ : tst_tmn[0];
   assign nub_tm1n     = (tst_startn & ~mastermode_tmack) ? 'bZ : tst_tmn[1];
   assign nub_ackn     = (tst_startn & ~mastermode_tmack) ? 'bZ : tst_ackn;
   
   // Drive NuBus address/data lines
   wire [31:0] tst_adn = tst_startn ? tst_wdatan : tst_addrn;
   wire tst_nuboen     = (tst_startn & tst_tmn[1]) | mastermode_start;
   assign nub_adn      = tst_nuboen ? 'bZ : tst_adn;
   
   // Inverted verions of registers 
   wire [31:0] tst_rdata = ~tst_rdatan;
   wire [31:0] tst_addr  = ~tst_addrn;
    
   initial begin
      $display ("Start virtual master (vm) writes and reads to/from NuBus slave memory module");
      $dumpfile("nubus_slave_tb.vcd");
      $dumpvars;
	  #1;

	  mastermode_start <= 0;
	  mastermode_tmack <= 0;

      tst_clkn   <= 1;
      tst_resetn <= 0;
      tst_rqstn  <= 'bz;
      tst_addrn  <= 'hFFFFFFFF;
      tst_wdatan <= 'hFFFFFFFF;
      tst_rdatan <= 'hFFFFFFFF;
      tst_startn <= 1;
      tst_statusn<= TMN_TRY_AGAIN_LATER;
      tst_tmn    <= TMN_NOP;
	  
      @ (posedge nub_clkn);
      @ (posedge nub_clkn);
        tst_resetn <= 1;
        
      #2000;

      @ (posedge nub_clkn);
         $display ("%g: %b", $time, nub_startn);
         
      $display  ("WORD ---------------------------");
      write_word(TMADN_WR_WORD,   TEST_ADDR+0, TEST_DATA);
      read_word (TMADN_RD_WORD,   TEST_ADDR+0);
      check_word(TMADN_RD_WORD,   TEST_DATA);
      $display  ("HALF 0 -------------------------");
      write_word(TMADN_WR_HALF_0, TEST_ADDR+4, TEST_DATA);
      read_word (TMADN_RD_HALF_0, TEST_ADDR+4);
      check_word(TMADN_RD_HALF_0, TEST_DATA);
      $display  ("HALF 1 -------------------------");
      write_word(TMADN_WR_HALF_1, TEST_ADDR+8, TEST_DATA);
      read_word (TMADN_RD_HALF_1, TEST_ADDR+8);
      check_word(TMADN_RD_HALF_1, TEST_DATA);

      $display  ("BYTE 0 -------------------------");
      write_word(TMADN_WR_BYTE_0,  TEST_ADDR+12, TEST_DATA);
      read_word (TMADN_RD_BYTE_0,  TEST_ADDR+12);
      check_word(TMADN_RD_BYTE_0,  TEST_DATA);
      $display  ("BYTE 1 -------------------------");
      write_word(TMADN_WR_BYTE_1,  TEST_ADDR+16, TEST_DATA);
      read_word (TMADN_RD_BYTE_1,  TEST_ADDR+16);
      check_word(TMADN_RD_BYTE_1,  TEST_DATA);
      $display  ("BYTE 2 -------------------------");
      write_word(TMADN_WR_BYTE_2,  TEST_ADDR+20, TEST_DATA);
      read_word (TMADN_RD_BYTE_2,  TEST_ADDR+20);
      check_word(TMADN_RD_BYTE_2,  TEST_DATA);
      $display  ("BYTE 3 -------------------------");
      write_word(TMADN_WR_BYTE_3,  TEST_ADDR+24, TEST_DATA);
      read_word (TMADN_RD_BYTE_3,  TEST_ADDR+24);
      check_word(TMADN_RD_BYTE_3,  TEST_DATA);

	  // $display  ("BLOCK2  -------------------------");
      // read_block2 (TMADN_RD_BLOCK,  TEST_ADDR);

	  #500

	  // Check Rom
      $display  ("ROM ---------------------------");
      read_word (TMADN_RD_WORD,   ROM_ADDR+4092);
      read_word (TMADN_RD_WORD,   ROM_ADDR+4088);
      read_word (TMADN_RD_WORD,   ROM_ADDR+4084);
      read_word (TMADN_RD_WORD,   ROM_ADDR+4080);
	  
      read_word (TMADN_RD_WORD,   ROM_ADDR+0);
      read_word (TMADN_RD_WORD,   ROM_ADDR+4);
      read_word (TMADN_RD_WORD,   ROM_ADDR+8);
      read_word (TMADN_RD_WORD,   ROM_ADDR+12);
	  
      #1000;

	  // check PingMaster
      $display  ("PING ---------------------------");
      write_word(TMADN_WR_WORD,   PING_ADDR+0, 'h00C0FFEE);
	  read_word (TMADN_RD_WORD,   PING_ADDR+0);
      write_word(TMADN_WR_WORD,   PING_ADDR+4, 'h00096240);
      //read_word (TMADN_RD_WORD,   ROM_ADDR+0);

	  mastermode_start <= 1;
	  mastermode_tmack <= 0;
	  tst_ackn <= 1;
	  
	  @ (negedge nub_startn);
	  #1
      $display  ("GOT START ---------------------------");
      $display ("%g  (received ) address: $%h", $time, ~nub_adn);
	  @ (negedge nub_clkn);
	  #1
	  @ (negedge nub_clkn);
	  #1
	  @ (negedge nub_clkn);
	  #1
      $display ("%g  (received ) data: $%h", $time, ~nub_adn);
	  @ (posedge nub_clkn);
	  mastermode_tmack <= 1;
	  tst_ackn <= 0;
	  tst_tmn <= TMN_COMPLETE;
	  
	  @ (posedge nub_clkn);
	  mastermode_start <= 0;
	  mastermode_tmack <= 0;
	  
	  #2000;
	  

      $finish;
   end


   // ======================================================
   // Write task
   // ======================================================

   task write_word;
      input [3:0]  tmadn;
      input [31:0] addr;
      input [31:0] data;
      begin
         @ (posedge nub_clkn);
         tst_wdatan     <= ~data;
         tst_addrn[31:2] <= ~addr[31:2];
         tst_addrn[ 1:0] <= tmadn[1:0]; 
         tst_tmn        <= tmadn[3:2];
         tst_startn     <= 0;
		 tst_ackn       <= 1;
         //tst_statusn    <= TMN_TRY_AGAIN_LATER;
         @ (posedge nub_clkn);
         tst_startn     <= 1;
         tst_ackn       <= nub_ackn;
         do begin
            @ (negedge nub_clkn);
            tst_ackn    <= nub_ackn;
            tst_statusn <= { nub_tm1n, nub_tm0n };
            //@ (posedge nub_clkn);
         end while (tst_ackn) ;
         $display ("%g  (write) address: $%h tm: $%h data: $%h stat: %s", $time, addr, tmadn, data, get_status_str(tst_statusn));
      end
   endtask

   // ======================================================
   // Read task
   // ======================================================

   task read_word;
      input [3:0]  tmadn;
      input [31:0] addr;
      begin
         @ (posedge nub_clkn);
         tst_tmn         <= tmadn[3:2];
         tst_addrn[ 1:0] <= tmadn[1:0];
         tst_addrn[31:2] <= ~addr[31:2];
         tst_startn  <= 0;
		 tst_ackn       <= 1;
         //tst_statusn <= TMN_TRY_AGAIN_LATER;
         @ (posedge nub_clkn);
         tst_startn  <= 1;
         tst_ackn    <= nub_ackn;
         do begin
            @ (negedge nub_clkn);
            tst_rdatan  <= nub_adn;
            tst_ackn    <= nub_ackn;
            tst_statusn <= { nub_tm1n, nub_tm0n };
            //@ (posedge nub_clkn);
         end while (tst_ackn) ;
         $display ("%g  (read ) address: $%h tm: $%h data: $%h stat: %s", $time, addr, tmadn, tst_rdata, get_status_str(tst_statusn));
      end
   endtask

   // ======================================================
   // Verify data writen to memory with read from
   // asume memory befor write was $00000000
   // ======================================================

   task check_word
     (
      input [3:0]  tm,
      input [31:0] data_wr
      );
      reg [31:0]   expected;
      begin
         expected = (data_wr & get_mask(tm));
         if (tst_rdata == expected)
           $display (":) PASSED");
         else
           $display (":( FAILED expected: $%h found: $%h", expected, tst_rdata);
         $display("  ");         
      end
   endtask // verify

   // ======================================================
   // Read block2 task
   // Currently unsupported (introduced with Q700/Q900, not in the NTC)
   // ======================================================

   task read_block2;
      input [3:0]  tmadn;
      input [31:0] addr;
      begin
         @ (posedge nub_clkn);
         tst_tmn         <= tmadn[3:2];
         tst_addrn[ 1:0] <= tmadn[1:0];
		 tst_addrn[ 2:2] <= 1; // this indicates size 2
         tst_addrn[31:3] <= ~addr[31:3];
         tst_startn  <= 0;
         //tst_statusn <= TMN_TRY_AGAIN_LATER;
         @ (posedge nub_clkn);
         tst_startn  <= 1;
         tst_ackn    <= nub_ackn;
         do begin
            @ (negedge nub_clkn);
            tst_rdatan  <= nub_adn;
            tst_ackn    <= nub_ackn;
            tst_statusn <= { nub_tm1n, nub_tm0n };
            //@ (posedge nub_clkn);
         end while (tst_statusn[0]) ;
         $display ("%g  (block0/2) address: $%h tm: $%h data: $%h stat: %s", $time, addr, tmadn, tst_rdata, get_status_str(tst_statusn));
         do begin
            @ (negedge nub_clkn);
            tst_rdatan  <= nub_adn;
            tst_ackn    <= nub_ackn;
            tst_statusn <= { nub_tm1n, nub_tm0n };
            //@ (posedge nub_clkn);
         end while (tst_ackn) ;
         $display ("%g  (block1/2) address: $%h tm: $%h data: $%h stat: %s", $time, addr, tmadn, tst_rdata, get_status_str(tst_statusn));
      end
   endtask // read block2
   
   // ======================================================
   // Clock generators
   // ======================================================
   
   always begin
      tst_clkn <= 1;
      #75.075;
      tst_clkn <= 0;
      if (DEBUG_NUBUS_START) begin
         if (~nub_startn) 
            $display ("%g  (NuBus Start) /ad: $%h {/tmadn}: %b%b%b%b", $time, nub_adn, nub_tm1n, nub_tm0n, nub_adn[1], nub_adn[0]);
      end
      #25.025;
   end
   always begin
      tst_clk2xn <= 0;
      #25.025;
      tst_clk2xn <= 1;
      #25.025;
   end

   always begin
      tst_clk48 <= 0;
      #10.41666666;
      tst_clk48 <= 1;
      #10.41666666;
   end

endmodule
