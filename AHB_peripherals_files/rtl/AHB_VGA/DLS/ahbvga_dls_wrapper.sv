`define COMP_VGA comp_vga_intf.dut_cb

module AHBVGA_DLS_WRAPPER(vga_intf comp_vga_intf);
    logic HSYNC; 
    logic VSYNC;
    logic [7:0] RGB;
    logic [31:0] HRDATA;
    logic HREADYOUT;
    logic HSYNC_copy;
    logic VSYNC_copy;
    logic [7:0] RGB_copy;
    logic [31:0] HRDATA_copy;
    logic HREADYOUT_copy;
    logic DLS_ERROR;

    // modify this to be "1" if we want to inject comparator fault
    localparam INJECTCOMPARATORFAULT = 1'b0;

    always @(*) begin
      comp_vga_intf.HRDATA <= HRDATA;
      comp_vga_intf.HREADYOUT <= HREADYOUT; 
      comp_vga_intf.HSYNC <= HSYNC;
      comp_vga_intf.VSYNC <= VSYNC;
      comp_vga_intf.RGB <= RGB; 
      comp_vga_intf.DLS_ERROR <= DLS_ERROR; 
    end
    
    // AHBLite VGA Peripheral
    AHBVGA uAHBVGA1 ( 
        .HCLK(comp_vga_intf.HCLK), 
        .HRESETn(comp_vga_intf.HRESETn), 
        .HADDR(`COMP_VGA.HADDR), 
        .HWDATA(`COMP_VGA.HWDATA), 
        .HREADY(`COMP_VGA.HREADY), 
        .HWRITE(`COMP_VGA.HWRITE), 
        .HTRANS(`COMP_VGA.HTRANS), 
        .HSEL(`COMP_VGA.HSEL), 
        .HRDATA(HRDATA), 
        .HREADYOUT(HREADYOUT), 
        .HSYNC(HSYNC), 
        .VSYNC(VSYNC), 
        .RGB(RGB)
     );

    // AHBLite VGA Peripheral copy
    AHBVGA uAHBVGA_copy ( 
        .HCLK(comp_vga_intf.HCLK), 
        .HRESETn(comp_vga_intf.HRESETn), 
        .HADDR(`COMP_VGA.HADDR), 
        .HWDATA(`COMP_VGA.HWDATA), 
        .HREADY(`COMP_VGA.HREADY), 
        .HWRITE(`COMP_VGA.HWRITE), 
        .HTRANS(`COMP_VGA.HTRANS), 
        .HSEL(`COMP_VGA.HSEL), 
        .HRDATA(HRDATA_copy), 
        .HREADYOUT(HREADYOUT_copy), 
        .HSYNC(HSYNC_copy), 
        .VSYNC(VSYNC_copy), 
        .RGB(RGB_copy)
     );

    // comparator instance
    comparator uComparator(
        .HCLK(comp_vga_intf.HCLK),
        .HRESETn(comp_vga_intf.HRESETn),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .RGB(RGB),
        .HRDATA(HRDATA),
        .HRDATA_COPY(HRDATA_COPY),
        .HREADYOUT(HREADYOUT),
        .HREADYOUT_COPY(HREADYOUT_COPY),
        .HSYNC_COPY(HSYNC_copy),
        .VSYNC_COPY(VSYNC_copy),
        .RGB_COPY(RGB_copy),
        .DLS_ERROR(DLS_ERROR),
        .INJECTCOMPARATORFAULT(INJECTCOMPARATORFAULT)
    );


endmodule