`define COMP_VGA1 comp_vga_intf.dut_cb
`define COMP_VGA2 comp_vga_intf_copy.dut_cb

module AHBVGA_DLS_WRAPPER(vga_intf comp_vga_intf, comp_vga_intf_copy, output logic DLS_ERROR);
    logic HSYNC_copy;
    logic VSYNC_copy;
    logic [7:0] RGB_copy;
    logic [31:0] HRDATA_copy;
    logic HREADYOUT_copy;

    // modify this to be "1" if we want to inject comparator fault
    localparam INJECTCOMPARATORFAULT = 1'b0;
    
    // AHBLite VGA Peripheral
    AHBVGA uAHBVGA1 ( comp_vga_intf );

    // AHBLite VGA Peripheral copy
    AHBVGA uAHBVGA_copy ( comp_vga_intf_copy );

    // comparator instance
    comparator uComparator(
    .HCLK(HCLK),
    .HRESETn(HRESETn),
    .HSYNC(comp_vga_intf.HSYNC),
    .VSYNC(comp_vga_intf.VSYNC),
    .RGB(comp_vga_intf.RGB ^ INJECTCOMPARATORFAULT),
    .HSYNC_COPY(comp_vga_intf_copy.HSYNC),
    .VSYNC_COPY(comp_vga_intf_copy.VSYNC),
    .RGB_COPY(comp_vga_intf_copy.RGB),
    .DLS_ERROR(DLS_ERROR)
  );


endmodule