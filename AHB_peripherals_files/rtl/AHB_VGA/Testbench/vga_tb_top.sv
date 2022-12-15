// `include "random_test.sv"
`include "vga_if.sv"
module tbench_top;
  
  //clock and reset signal declaration
  bit HCLK;
  bit HRESETn;

  event resetvga;

  logic DLS_ERROR;
  
  //clock generation
  always #5 HCLK = ~HCLK;

  //HRESETn Generation
  initial begin
    HRESETn = 1;
    #5 HRESETn = 0;
    #5 HRESETn =1;
  end
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  vga_intf intf(HCLK, HRESETn);
  vga_intf intf_copy(HCLK, HRESETn);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(intf, intf_copy);

  AHBVGA_DLS_WRAPPER uAHBVGA_DLS_WRAPPER ( intf, intf_copy, DLS_ERROR);

  // VGA Monitor (for debugging purposes)
  VGA_Monitor_test uVGA_Monitor_test( intf );
  
  //enabling the wave dump
  // initial begin 
  //   $dumpfile("dump.vcd"); $dumpvars;
  // end
endmodule