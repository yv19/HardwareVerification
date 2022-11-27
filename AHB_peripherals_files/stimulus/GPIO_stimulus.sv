class GPIO_Stimulus_packets;
    rand logic [31:0] HADDR;
    rand logic [1:0] HTRANS;
    rand logic [31:0] HWDATA;
    rand logic HWRITE;
    rand logic HSEL;
    rand logic HREADY;
    rand logic [15:0] GPIOIN;

    // Write constraints to limit range of values generated

    constraint HADDR_dist {
        HADDR dist {
            [32'h0000000:32'hffffffff] :/ 10, // Give weighting to each element in the range with 10/(range size)
            [32'h53000000:32'h53ffffff] :/ 20,
            32'h53000000 :/ 40,
            32'h53000004 :/ 40
        };
    }

    constraint HTRANS_constraint { 
        // Only either IDLE or Non-Seq transfer
        // Want to put more weight onto the Non-Seq transfers as it is going to be the most common case for GPIO
        HTRANS dist {
            0 := 10,
            2 := 90
        };
    }

    constraint HWDATA_dist {
        // Only the 16 bits of HWDATA is used
        HWDATA dist {
            [32'h00000000:32'h0000ffff] :/ 40,
            32'h00000000 :/ 40,
            32'h00000001 :/ 40
        };
    }

    // Check if this is necessary for GPIOIN
    constraint GPIOIN_mask_zeros {
        GPIOIN <= 16'h00ff;
    }

endclass

module GPIO_Stimulus(
    input wire HCLK,
    input wire HRESETn,

    output wire [31:0] HADDR,
    output wire [1:0] HTRANS,
    output wire [31:0] HWDATA,
    output wire HWRITE,
    output wire HSEL,
    output wire HREADY,
    output wire [15:0] GPIOIN
    );

    logic [31:0] HADDR_reg;
    logic [1:0] HTRANS_reg;
    logic [31:0] HWDATA_reg;
    logic HWRITE_reg;
    logic HSEL_reg;
    logic HREADY_reg;
    logic [15:0] GPIOIN_reg;

    GPIO_Stimulus_packets p;

    initial begin
        p = new();
    end

    always @(posedge HCLK, negedge HRESETn)
    begin
        assert (p.randomize) else $fatal;

        HADDR_reg <= p.HADDR;
        HTRANS_reg <= p.HTRANS;
        HWDATA_reg <= p.HWDATA;
        HWRITE_reg <= p.HWRITE;
        HSEL_reg <= p.HSEL;
        HREADY_reg <= p.HREADY;
        GPIOIN_reg <= p.GPIOIN;
    end

    assign HADDR = HADDR_reg;
    assign HTRANS = HTRANS_reg;
    assign HWDATA = HWDATA_reg;
    assign HWRITE = HWRITE_reg;
    assign HSEL = HSEL_reg;
    assign HREADY = HREADY_reg;
    assign GPIOIN = GPIOIN_reg;

endmodule