bind AHBVGA_DLS_WRAPPER VGA_assertions u_VGA_assertions (
    .HCLK(comp_vga_intf.HCLK), 
    .HRESETn(comp_vga_intf.HRESETn), 
    .HADDR(comp_vga_intf.dut_cb.HADDR), 
    .HWDATA(comp_vga_intf.dut_cb.HWDATA), 
    .HREADY(comp_vga_intf.dut_cb.HREADY), 
    .HWRITE(comp_vga_intf.dut_cb.HWRITE), 
    .HTRANS(comp_vga_intf.dut_cb.HTRANS), 
    .HSEL(comp_vga_intf.dut_cb.HSEL), 
    .VSYNC(comp_vga_intf.VSYNC),
    .HSYNC(comp_vga_intf.HSYNC),
    .HREADYOUT(comp_vga_intf.HREADYOUT),
    .RGB(comp_vga_intf.RGB),
    .HRDATA(comp_vga_intf.HRDATA)
    );


`define DUT_IF comp_vga_intf.dut_cb

module VGA_assertions(
    input logic HCLK,
    input logic HRESETn,
    input logic [31:0] HADDR,
    input logic [31:0] HWDATA,
    input logic HREADY,
    input logic HWRITE,
    input logic [1:0] HTRANS,
    input logic HSEL,
    // Inputs to monitor
    input logic [31:0] HRDATA,
    input logic HREADYOUT,
    input logic HSYNC,
    input logic VSYNC,
    input logic [7:0] RGB
);

    logic [31:0] HSYNC_COUNTER;
    logic SEL_HI;

    assign SEL_HI = HREADY && HTRANS == 2'd2 && HWRITE && HADDR == 32'h50000000 && HSEL;
    
    // Set Registers from address phase  
    always @(negedge VSYNC, negedge HRESETn)
    begin
        HSYNC_COUNTER <= 0;
    end

    always @(negedge HSYNC) begin
        HSYNC_COUNTER <= HSYNC_COUNTER + 1;
    end

    // // 525 HSYNCS in 1 VSYNC
    // VSYNC_HSYNC_test: assert property(
    //                             @(negedge HCLK) disable iff(!HRESETn)
    //                                 VSYNC ##1 !VSYNC |-> VSYNC ##1 !VSYNC |-> HSYNC_COUNTER == 525
    //                             );
////
    // Test to show that there are 800 pixels between 2 HSYNCS
    Pixel_Count_Hsync: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                    (SEL_HI && HSYNC)[*1] ##1 SEL_HI && !HSYNC |-> SEL_HI[*799*2] |-> (SEL_HI && HSYNC)[*1] |-> ##1 !HSYNC && SEL_HI |-> !HSYNC
    );

    // Test for the horizontal sync pulse
    Hor_Sync_Pulse: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                    SEL_HI && HSYNC ##1 SEL_HI ##1 SEL_HI && !HSYNC |-> (SEL_HI && !HSYNC)[*96*2] |-> ##2 HSYNC
    );

    // Test for the horizontal sync pulse
    Hor_Front_Porch: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                    !HSYNC && SEL_HI ##1 SEL_HI ##1 HSYNC && SEL_HI |-> (SEL_HI && HSYNC)[*48*2] |-> ##2 (RGB == 8'h1c || RGB == 8'h0)
    );

    // // Test to show there are 524 HSYNCS between 2 VSYNCS
    // HSYNC_Count: assert property(
    //                             @(negedge HCLK) disable iff(!HRESETn)
    //                                 VSYNC ##2 !VSYNC |-> ##(2*2) VSYNC |-> ##[1:$] !VSYNC |-> HSYNC_COUNTER == 32'd524
    // );
////
    // // Between 2 HSYNC Sync Pulse
    // HSYNC_test1: assert property(
    //                             @(posedge HCLK) disable iff(!HRESETn)
    //                                 SEL_HI |=> HSYNC && SEL_HI ##1 SEL_HI ##1 SEL_HI && !HSYNC |-> SEL_HI[*95*2] |-> !HSYNC ##2 HSYNC
    // );



endmodule