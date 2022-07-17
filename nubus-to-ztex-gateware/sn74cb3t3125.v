module sn74cb3t3125
  (
   input [3:0] 	   oe_n,
   inout [3:0]	   A,
   input [3:0]     B
   );

   wire [3:0] 	   tA;
   wire [3:0] 	   tB; 	   

   /*
   assign A[0] = oe_n[0] ? 'bZ : tA[0];
   assign A[1] = oe_n[1] ? 'bZ : tA[1];
   assign A[2] = oe_n[2] ? 'bZ : tA[2];
   assign A[3] = oe_n[3] ? 'bZ : tA[3];
   assign B[0] = oe_n[0] ? 'bZ : tB[0];
   assign B[1] = oe_n[1] ? 'bZ : tB[1];
   assign B[2] = oe_n[2] ? 'bZ : tB[2];
   assign B[3] = oe_n[3] ? 'bZ : tB[3];

   assign tA[0] = A[0] === 'bZ ? B[0] : 'bZ;
   assign tA[1] = A[1] === 'bZ ? B[1] : 'bZ;
   assign tA[2] = A[2] === 'bZ ? B[2] : 'bZ;
   assign tA[3] = A[3] === 'bZ ? B[3] : 'bZ;
   assign tB[0] = B[0] === 'bZ ? A[0] : 'bZ;
   assign tB[1] = B[1] === 'bZ ? A[1] : 'bZ;
   assign tB[2] = B[2] === 'bZ ? A[2] : 'bZ;
   assign tB[3] = B[3] === 'bZ ? A[3] : 'bZ;
    */

   assign A[0] = oe_n[0] ? 'bZ : B[0];
   assign A[1] = oe_n[1] ? 'bZ : B[1];
   assign A[3] = oe_n[2] ? 'bZ : B[2];
   assign A[3] = oe_n[3] ? 'bZ : B[3];
   
   
endmodule // sn74cb3t3125
