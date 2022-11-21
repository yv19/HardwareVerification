module AHBGPIO_Interface(
    // Inputs of GPIO peripheral
    input wire HCLK,
    input wire HRESETn,
    input wire [31:0] HADDR,
    input wire [1:0] HTRANS,
    input wire [31:0] HWDATA,
    input wire HWRITE,
    input wire HSEL,
    input wire HREADY,
    input wire [15:0] GPIOIN,
  
	
	// Outputs of GPIO peripheral
    input wire HREADYOUT,
    input wire [31:0] HRDATA,
    input wire [15:0] GPIOOUT,

    // constants defined in the AHBGPIO script
    input wire [7:0] gpio_data_addr,
    input wire [7:0] gpio_dir_addr,

    // Define all the registers that is used by AHBGPIO
    input wire [15:0] gpio_dataout,
    input wire [15:0] gpio_datain,
    input wire [15:0] gpio_dir,
    input wire [15:0] gpio_data_next,
    input wire [31:0] last_HADDR,
    input wire [1:0] last_HTRANS,
    input wire last_HWRITE,
    input wire last_HSEL
);

    // Write Formal Verification Assertion Properties
    
    // Formal verification assertion examples
    gpio_data_addr_assert: assert property(
                                    @(posedge HCLK) disable iff(!HRESETn)
                                    gpio_data_addr == 8'h00
                                    )
                                    else $error("The value of GPIOOUT is %h", gpio_data_addr);

    gpio_dir_addr_assert: assert property(
                                    @(posedge HCLK) disable iff(!HRESETn)
                                    gpio_dir_addr == 8'h04
                                    )
                                    else $error("The value of GPIOOUT is %h", gpio_dir_addr);
endmodule