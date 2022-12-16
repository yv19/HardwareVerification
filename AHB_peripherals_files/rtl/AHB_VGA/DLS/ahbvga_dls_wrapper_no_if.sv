module AHBVGA_DLS_WRAPPER(
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [31:0] HWDATA,
    input wire HREADY,
    input wire HWRITE,
    input wire [1:0] HTRANS,
    input wire HSEL,

    output wire [31:0] HRDATA,
    output wire HREADYOUT,

    output wire HSYNC,
    output wire VSYNC,
    output wire [7:0] RGB
);
    logic HSYNC_copy;
    logic VSYNC_copy;
    logic [7:0] RGB_copy;
    logic [31:0] HRDATA_copy;
    logic HREADYOUT_copy;

    // modify this to be "1" if we want to inject comparator fault
    localparam INJECTCOMPARATORFAULT = 1'b0;
    
    // AHBLite VGA Peripheral
    AHBVGA uAHBVGA1 ( 
        .HCLK(HCLK), 
        .HRESETn(HRESETn), 
        .HADDR(HADDR), 
        .HWDATA(HWDATA), 
        .HREADY(HREADY), 
        .HWRITE(HWRITE), 
        .HTRANS(HTRANS), 
        .HSEL(HSEL), 
        .HRDATA(HRDATA), 
        .HREADYOUT(HREADYOUT), 
        .HSYNC(HSYNC), 
        .VSYNC(VSYNC), 
        .RGB(RGB)
     );

    // AHBLite VGA Peripheral copy
    AHBVGA uAHBVGA_copy ( 
        .HCLK(HCLK), 
        .HRESETn(HRESETn), 
        .HADDR(HADDR), 
        .HWDATA(HWDATA), 
        .HREADY(HREADY), 
        .HWRITE(HWRITE), 
        .HTRANS(HTRANS), 
        .HSEL(HSEL), 
        .HRDATA(HRDATA_copy), 
        .HREADYOUT(HREADYOUT_copy), 
        .HSYNC(HSYNC_copy), 
        .VSYNC(VSYNC_copy), 
        .RGB(RGB_copy)
     );

    // comparator instance
    comparator uComparator(
        .HCLK(HCLK),
        .HRESETn(HRESETn),
        .HSYNC(HSYNC),
        .VSYNC(VSYNC),
        .RGB(RGB),
        .HRDATA_COPY(HRDATA_copy),
        .HREADYOUT(HREADYOUT),
        .HREADYOUT_COPY(HREADYOUT_copy),
        .HSYNC_COPY(HSYNC_copy),
        .VSYNC_COPY(VSYNC_copy),
        .RGB_COPY(RGB_copy),
        .DLS_ERROR(DLS_ERROR)
    );


endmodule