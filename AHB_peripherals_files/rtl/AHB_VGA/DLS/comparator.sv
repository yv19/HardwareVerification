module comparator(
    input logic HCLK,
    input logic HRESETn,
    input logic HSYNC,
    input logic VSYNC,
    input logic [7:0] RGB,
    input logic HREADYOUT,
    input logic [31:0] HRDATA,

    input logic HSYNC_COPY,
    input logic VSYNC_COPY,
    input logic [7:0] RGB_COPY,
    input logic HREADYOUT_COPY,
    input logic [31:0] HRDATA_COPY,
    input logic INJECTCOMPARATORFAULT,

    output logic DLS_ERROR
);
    logic DLS_ERROR_logic;
    wire HRESET = HRESETn && !INJECTCOMPARATORFAULT;

    assign DLS_ERROR = !((HSYNC === HSYNC_COPY) && (VSYNC === VSYNC_COPY) && (RGB === RGB_COPY) && (HRDATA === HRDATA_COPY) && (HREADYOUT === HREADYOUT_COPY)) && INJECTCOMPARATORFAULT;

    always @(posedge HCLK, negedge HRESETn) begin
        if (!HRESETn) begin
            DLS_ERROR_logic <= 0;
        end
        else begin
            DLS_ERROR_logic <= !((HSYNC === HSYNC_COPY) && (VSYNC === VSYNC_COPY) && (RGB === RGB_COPY)); 
        end
    end

    DLS_CHECK: assert property(
                                @(posedge HCLK) disable iff(HRESET)
                                    DLS_ERROR == 0
                                );

endmodule
