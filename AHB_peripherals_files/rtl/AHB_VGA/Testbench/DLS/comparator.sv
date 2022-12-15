module comparator(
    input logic HCLK,
    input logic HRESETn,
    input logic HSYNC,
    input logic VSYNC,
    input logic [7:0] RGB,

    input logic HSYNC_COPY,
    input logic VSYNC_COPY,
    input logic [7:0] RGB_COPY,

    output logic DLS_ERROR
);
    logic DLS_ERROR_logic;

    assign DLS_ERROR = !((HSYNC === HSYNC_COPY) && (VSYNC === VSYNC_COPY) && (RGB === RGB_COPY));

    always @(posedge HCLK, negedge HRESETn) begin
        if (!HRESETn) begin
            DLS_ERROR_logic <= 0;
        end
        else begin
            DLS_ERROR_logic <= !((HSYNC === HSYNC_COPY) && (VSYNC === VSYNC_COPY) && (RGB === RGB_COPY)); 
        end
    end

    DLS_CHECK: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                    !((HSYNC === HSYNC_COPY) && (VSYNC === VSYNC_COPY) && (RGB === RGB_COPY)) == 0
                                );

endmodule
