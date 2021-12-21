module sn74fct245
  (
   input 	   nubus_oe,
   input 	   nubus_ad_dir,
   inout [7:0] data_3v3, // on B
   inout [7:0] data_5v // on A
   );

   assign data_3v3 = nubus_oe ? 'bZZZZZZZZ : ( nubus_ad_dir ? data_5v  : 'bZZZZZZZZ);
   assign data_5v  = nubus_oe ? 'bZZZZZZZZ : (~nubus_ad_dir ? data_3v3 : 'bZZZZZZZZ);
   
endmodule // sn74fct245

