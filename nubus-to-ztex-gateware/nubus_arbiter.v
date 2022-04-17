/*
 * Nubus Arbitration logic
 *
 * ARB is responsible for doing the NuBus arbitration logic. Upon
 * detecting any higher priority ARB<3:0> value, it will defer its
 * generation of lower ARB<3:0> bits.
 * The GRANT signal must be timed externally to determine proper
 * NuBus constraints.
 * This version uses a new technique to minimize skews.
 * 
 * Modified from the XiBus version to support external drivers in the NuBusFPGA
 */

module nubus_arbiter 
   (
    input [3:0]  idn, // ID of this card
    input [3:0]  arbn, // NuBus arbiter's lines (input)
    output [3:0] arbon, // NuBus arbiter's lines (control)
    input 		 arbcyn, // enable arbitter
    output 		 grant   // Grant access
    );

   wire          arb2oen, arb1oen, arb0oen;
   wire          arb3, arb2, arb1, arb0;
   wire          grantn;

   assign arbon[3] = ~arb3;
   assign arbon[2] = ~arb2;
   assign arbon[1] = ~arb1;
   assign arbon[0] = ~arb0;

   // ------------------------------------------

   assign arb3 = ~arbcyn & ~idn[3];

   assign arb2oen = idn[3] & ~arbn[3];

   // ------------------------------------------

   assign arb2 = ~arbcyn & ~arb2oen & ~idn[2];

   assign arb1oen = idn[3] & ~arbn[3] |
                    idn[2] & ~arbn[2];

   // ------------------------------------------

   assign arb1 = ~arbcyn & ~arb1oen & ~idn[1];

   assign arb0oen = idn[3] & ~arbn[3] |
                    idn[2] & ~arbn[2] |
                    idn[1] & ~arbn[1];

   // ------------------------------------------

   assign arb0 = ~arbcyn & ~arb0oen & ~idn[0];

   assign grantn = idn[3] & ~arbn[3] |
                   idn[2] & ~arbn[2] |
                   idn[1] & ~arbn[1] |
                   idn[0] & ~arbn[0];

   assign grant = ~arbcyn &  ~grantn;

endmodule
