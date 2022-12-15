`timescale 1ns/1ps
module vga_top_test(

);
logic clk;

// AHBLite VGA Peripheral
interface AHBVGA_if ( 
    input HCLK, HRESETn
);
    logic [31:0] HADDR;
    logic [31:0] HWDATA;
    logic HREADY;
    logic HWRITE;
    logic [1:0] HTRANS;
    logic HSEL;
    logic [31:0] HRDATA;
    logic HREADYOUT;
    logic HSYNC;
    logic VSYNC;
    logic [7:0] RGB;

    assign HCLK = clk;
    // assign HRESETn = ~rst;

    // driver clocking block
    clocking driver_cb @(posedge clk);
        output HADDR;
        output HWDATA;
        output HREADY;
        output HWRITE;
        output HTRANS;
        output HSEL;
    endclocking

    /////////////////////////
    modport DUT( input HCLK, HRESETn, HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL,
                output HRDATA, HREADYOUT, VSYNC, HSYNC, RGB);

    modport TEST( input HCLK, HRDATA, HREADYOUT, VSYNC, HSYNC, RGB,
            output HRESETn, HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL);

    modport generator ( input HCLK, VSYNC, HSYNC,
                output HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL, HRESETn);

    modport monitor ( input HCLK, VSYNC, HSYNC, RGB, HRESETn );
endinterface

AHBVGA_if ahbvga_if(
    .clk(clk)
);

// VGA Monitor
VGA_Monitor_test uVGA_Monitor_test( ahbvga_if );

// VGA stimulus
VGA_Stimulus uVGA_Stimulus( ahbvga_if );

// AHBLite VGA Peripheral
AHBVGA uAHBVGA ( ahbvga_if );

// Instantiate the Monitor to Check that the GPIO output and Ideal Model are the same
initial
begin
    clk=0;
    forever
    begin
        #20 clk=1;
        #20 clk=0;
    end
end
endmodule