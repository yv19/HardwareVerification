bind AHBVGA VGA_assertions u_VGA_assertions (
    .HCLK(ahbvga_if.HCLK), 
    .HRESETn(ahbvga_if.HRESETn), 
    .HADDR(ahbvga_if.dut_cb.HADDR), 
    .HWDATA(ahbvga_if.dut_cb.HWDATA), 
    .HREADY(ahbvga_if.dut_cb.HREADY), 
    .HWRITE(ahbvga_if.dut_cb.HWRITE), 
    .HTRANS(ahbvga_if.dut_cb.HTRANS), 
    .HSEL(ahbvga_if.dut_cb.HSEL), 
    .VSYNC(ahbvga_if.VSYNC),
    .HSYNC(ahbvga_if.HSYNC),
    .HREADYOUT(ahbvga_if.HREADYOUT),
    .RGB(ahbvga_if.RGB),
    .HRDATA(ahbvga_if.HRDATA)
    );


`define DUT_IF ahbvga_if.dut_cb

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