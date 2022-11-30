bind AHBGPIO AHBGPIO_assertions u_AHBGPIO_assertions (.*);

module AHBGPIO_assertions(
    // Inputs of GPIO peripheral
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [1:0] HTRANS,
    input wire [31:0] HWDATA,
    input wire HWRITE,
    input wire HSEL,
    input wire HREADY,
    input wire [16:0] GPIOIN,
    input wire PARITYSEL,
  
	
	// Outputs of GPIO peripheral
    input wire HREADYOUT,
    input wire [31:0] HRDATA,
    input wire [16:0] GPIOOUT,
    input wire PARITYERR
);

    reg[15:0] last_HWDATA;
    reg[16:0] last_GPIOIN;
    reg[16:0] last_GPIOOUT;
    // track our own version of the internal state of gpio_dir
    reg[15:0] gpio_dir;

    reg [31:0] last_HADDR;
    reg [1:0] last_HTRANS;
    reg last_HWRITE;
    reg last_HSEL;
    reg last_HREADY;

    // constants defined in the AHBGPIO script
    localparam [31:0] gpio_data_addr_value = 32'h53000000;
    localparam [31:0] gpio_dir_addr_value = 32'h53000004;

    // constants defined in the AHBGPIO script
    localparam [15:0] dir_input = 16'h0000;
    localparam [15:0] dir_output = 16'h0001;

    wire AHB_write = HSEL && HWRITE && HTRANS[1] && HREADY;

    // Set Registers from address phase  
    always @(posedge HCLK, negedge HRESETn)
    begin
    if(!HRESETn)
    begin
        last_HADDR <= 16'h0000;
        last_HTRANS <= 16'h0000;
        last_HWRITE <= 16'h0000;
        last_HSEL <= 16'h0000;
        last_HREADY <= 16'h0000;
    end
    else
    begin
        last_HREADY <= HREADY;
        last_HADDR <= HADDR;
        last_HTRANS <= HTRANS;
        last_HWRITE <= HWRITE;
        last_HSEL <= HSEL;
    end
    end

    // Update in/out switch
    always @(posedge HCLK, negedge HRESETn)
    begin
    if(!HRESETn)
    begin
        gpio_dir <= 16'h0000;
    end
    else if ((last_HADDR == gpio_dir_addr_value) & last_HSEL & last_HWRITE & last_HTRANS[1] & last_HREADY)
        gpio_dir <= HWDATA[15:0];
    end

    always @(posedge HCLK, negedge HRESETn)
    begin
    if(!HRESETn)
    begin
        last_HWDATA <= 16'h0000;
        last_GPIOIN <= 16'h0000;
        last_GPIOOUT <= 16'h0000;
    end
    else begin
        last_HWDATA <= HWDATA[15:0];
        last_GPIOIN <= GPIOIN;
        last_GPIOOUT <= GPIOOUT;
    end
    end

    // Write Formal Verification Assertion Properties
    
    // Valid write
    Valid_write: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                (AHB_write && HADDR == gpio_data_addr_value) |-> ##1 (gpio_dir == dir_output) |-> ##1 GPIOOUT[15:0] == last_HWDATA[15:0]
                                );

    // Non Valid write
    Invalid_write: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                !(AHB_write && HADDR == gpio_data_addr_value) |-> ##2 $stable(GPIOOUT[15:0])
                                );

    // Input stable
    Stable_Input_GPIO_Dir: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                $stable(gpio_dir) && (gpio_dir == dir_input) |-> ##1 last_GPIOIN[15:0] == HRDATA[15:0] && $stable(GPIOOUT[15:0])
                                );

    // Ouput stable
    Stable_Output_GPIO_Dir: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                $stable(gpio_dir) && (gpio_dir == dir_output) |-> ##1 last_GPIOOUT[15:0] == HRDATA[15:0]
                                );
    ///////
    // Input -> Output transition
    Input_Output_transition_GPIO_Dir: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                (gpio_dir == dir_input) && (AHB_write) && (HADDR == gpio_dir_addr_value) ##1 HWDATA[15:0] == dir_output && (gpio_dir == dir_input)
                                |-> ##1 last_GPIOIN[15:0] == HRDATA[15:0] // Should still be the input
                                ##1 last_GPIOOUT[15:0] == HRDATA[15:0] // Should now be the output
                                );

    // Output -> Input transition
    Output_Input_transition_GPIO_Dir: assert property(
                                @(posedge HCLK) disable iff(!HRESETn)
                                (gpio_dir == dir_output) && (AHB_write) && (HADDR == gpio_dir_addr_value) ##1 HWDATA[15:0] == dir_input && (gpio_dir == dir_output)
                                |-> ##1 last_GPIOOUT[15:0] == HRDATA[15:0] // Should still be the input
                                ##1 last_GPIOIN[15:0] == HRDATA[15:0] // Should now be the output
                                );

    // Verifying Parity of GPIOOUT
    Parity_out_Check: assert property(
                                    @(posedge HCLK) disable iff(!HRESETn)
                                    (^GPIOOUT[15:0]) ^ PARITYSEL == GPIOOUT[16]
                                    );

    // Verifying Parity of GPIOIN
    Parity_in_Check: assert property(
                                    @(posedge HCLK) disable iff(!HRESETn)
                                    (((^GPIOIN) ^ PARITYSEL) == GPIOIN[16]) |-> ~PARITYERR
                                    );

endmodule