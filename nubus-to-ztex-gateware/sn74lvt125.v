module sn74lvt145_quarter
  (
   input 	   oe_n,
   input 	   in,
   output      out
   );

   assign out = oe_n ? 'bZ : in;
   
endmodule // sn74lvt145_quarter


