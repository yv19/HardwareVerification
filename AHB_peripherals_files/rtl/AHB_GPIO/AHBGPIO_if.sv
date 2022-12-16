`ifndef GPIO_INTF
`define GPIO_INTF

interface gpio_intf(input logic HCLK, HRESETn);
  logic [31:0] HADDR;
  logic [1:0] HTRANS;
  logic [31:0] HWDATA;
  logic HWRITE;
  logic HSEL;
  logic HREADY;
  logic [16:0] GPIOIN;
  logic PARITYSEL;
	
	//Output
  logic HREADYOUT;
  logic [31:0] HRDATA;
  logic [16:0] GPIOOUT;
  logic PARITYERR;
  
  //driver modport
  modport DRIVER  ( input HCLK, HRESETn, output HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL, GPIOIN, PARITYSEL );

  //DUT modport
  modport DUT  (input HCLK, HRESETn, HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL, GPIOIN, PARITYSEL, output HRDATA, HREADYOUT, GPIOOUT, PARITYERR);
  
  // Temporary monitor
  modport MONITOR ( input HCLK, HRESETn, HRDATA, HREADYOUT, GPIOOUT, PARITYERR );
  
  //monitor modport  
  modport SCOREBOARD (input HCLK, HRESETn);

endinterface

`endif