module sn74cb3t3245
  (
   input  	   oe_n,
   output [7:0]	   A,
   input [7:0]     B
   );

   assign A[0] = oe_n ? 'bZ : B[0];
   assign A[1] = oe_n ? 'bZ : B[1];
   assign A[2] = oe_n ? 'bZ : B[2];
   assign A[3] = oe_n ? 'bZ : B[3];
   assign A[4] = oe_n ? 'bZ : B[4];
   assign A[5] = oe_n ? 'bZ : B[5];
   assign A[6] = oe_n ? 'bZ : B[6];
   assign A[7] = oe_n ? 'bZ : B[7];
   
   
endmodule // sn74cb3t3125
