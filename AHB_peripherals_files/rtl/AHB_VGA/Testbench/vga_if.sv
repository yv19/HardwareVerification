`ifndef INTF
`define INTF

interface vga_intf(input logic HCLK, HRESETn);
  
  //declaring the signals
  // Outputs from driver
  logic [31:0] HADDR;
  logic [31:0] HWDATA;
  logic HREADY;
  logic HWRITE;
  logic [1:0] HTRANS;
  logic HSEL;
  // Inputs to monitor
  logic [31:0] HRDATA;
  logic HREADYOUT;
  logic HSYNC;
  logic VSYNC;
  logic [7:0] RGB;

  logic SEL_HI;

  assign SEL_HI = HREADY && HTRANS == 2'd2 && HWRITE && HADDR == 32'h50000000 && HSEL;
  
  //driver clocking block
  clocking driver_cb @(posedge HCLK);
    default input #1 output #1;
    output HADDR;
    output HWDATA;
    output HREADY;
    output HWRITE;
    output HTRANS;
    output HSEL;
    input VSYNC;
  endclocking

  //dut clocking block
  clocking dut_cb @(posedge HCLK);
    default input #1 output #1;
    input HADDR;
    input HWDATA;
    input HREADY;
    input HWRITE;
    input HTRANS;
    input HSEL;
  endclocking
  
  // monitor clocking block
  clocking monitor_cb @(posedge HCLK);
    default input #1 output #1;
    input HSYNC;
    input VSYNC;
    input RGB;
  endclocking

  // monitor clocking block
  clocking scoreboard_cb @(posedge HCLK);
    default input #1 output #1;
    input VSYNC;
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb, input HCLK, HRESETn);

  //DUT modport
  modport DUT  (clocking dut_cb, input HCLK, HRESETn, output HRDATA, HREADYOUT, HSYNC ,VSYNC , RGB );
  // output RGB, output HSYNC, output VSYNC
  // Temporary monitor
  modport MONITOR ( clocking monitor_cb, input HCLK, HRESETn );
  
  //monitor modport  
  modport SCOREBOARD (clocking scoreboard_cb, input HCLK, HRESETn);

  // Temporary monitor
  modport TEMP_MONITOR ( input HCLK, VSYNC, HSYNC, RGB, HRESETn );

endinterface

`endif