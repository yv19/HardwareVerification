class VGA_Stimulus_packets;
    rand logic [31:0] HADDR;
    rand logic [1:0] HTRANS;
    rand logic [31:0] HWDATA;
    rand logic HWRITE;
    rand logic HSEL;
    rand logic HREADY;


    // HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL

endclass

module VGA_Stimulus(
    AHBVGA_if.generator ahbvga_if
    );
    // HCLK, HRESETn,  
    // HADDR, HWDATA, HREADY, HWRITE, HTRANS, HSEL

    logic [31:0] HADDR_reg;
    logic [1:0] HTRANS_reg;
    logic [31:0] HWDATA_reg;
    logic HWRITE_reg;
    logic HSEL_reg;
    logic HREADY_reg;
    logic HRESETn;

    VGA_Stimulus_packets p;

    initial begin
        // p = new();
        HRESETn <= 1;
        @(posedge ahbvga_if.HCLK);
        HRESETn <= 0;
        @(posedge ahbvga_if.HCLK);
        HRESETn <= 1;
        @(posedge ahbvga_if.HCLK);
        HSEL_reg <= 1'b1;
        HREADY_reg <= 1'b1;
        HTRANS_reg <= 2'd2;
        HWRITE_reg <= 1'b1;
        HADDR_reg <= 32'h50000000;
        
        @(posedge ahbvga_if.HCLK);
        HWDATA_reg <= 32'h00000031;
        HTRANS_reg <= 2'd0;
        @(posedge ahbvga_if.HCLK);
        HTRANS_reg <= 2'd2;
        HWDATA_reg <= 32'h00000032;
        @(posedge ahbvga_if.HCLK);
        HWDATA_reg <= 32'h000000ff;
        @(posedge ahbvga_if.HCLK);
        HWDATA_reg <= 32'h00000034;
        @(posedge ahbvga_if.HCLK);
        HWDATA_reg <= 32'h00000000;
        @(posedge ahbvga_if.HCLK);
        HSEL_reg <= 1'b0;
        // HREADY_reg <= 1'b0; This is causing the break (No idea why)
        HWRITE_reg <= 1'b0;
    end

    // always @(posedge HCLK, negedge HRESETn)
    // begin
    //     if(!HRESETn)
    //     begin
    //         HADDR_reg <= 0;
    //         HTRANS_reg <= 0;
    //         HWDATA_reg <= 0;
    //         HWRITE_reg <= 0;
    //         HSEL_reg <= 0;
    //         HREADY_reg <= 0;
    //     end
    //     else
    //     begin
    //         assert (p.randomize) else $fatal;

    //         // Potentially to-do: Switch to modports and interfaces
    //         HADDR_reg <= p.HADDR;
    //         HTRANS_reg <= p.HTRANS;
    //         HWDATA_reg <= p.HWDATA;
    //         HWRITE_reg <= p.HWRITE;
    //         HSEL_reg <= p.HSEL;
    //         HREADY_reg <= p.HREADY;
    //     end
    // end

    assign ahbvga_if.HADDR = HADDR_reg;
    assign ahbvga_if.HTRANS = HTRANS_reg;
    assign ahbvga_if.HWDATA = HWDATA_reg;
    assign ahbvga_if.HWRITE = HWRITE_reg;
    assign ahbvga_if.HSEL = HSEL_reg;
    assign ahbvga_if.HREADY = HREADY_reg;
    assign ahbvga_if.HRESETn = HRESETn;

endmodule