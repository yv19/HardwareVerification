interface AHBGPIO_Interface(
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

    // Define all the registers that is used by AHBGPIO

    // The 3 registers for the GPIO
    input wire [15:0] gpio_dataout,
    input wire [15:0] gpio_datain,
    input wire [15:0] gpio_dir,
    
    // Registers used for logic
    input wire [15:0] gpio_data_next,
    input wire [31:0] last_HADDR,
    input wire [1:0] last_HTRANS,
    input wire last_HWRITE,
    input wire last_HSEL
);

    reg[15:0] last_HWDATA;
    reg[15:0] last_GPIOIN;
    reg[15:0] last_GPIOOUT;
    // Used to check whether we're in address phase or data phase

    // constants defined in the AHBGPIO script
    localparam [31:0] gpio_data_addr_value = 32'h53000000;
    localparam [31:0] gpio_dir_addr_value = 32'h53000004;

    wire AHB_write = HSEL && HWRITE && HTRANS[1] && HREADY;
    wire gpio_write_bool = ((gpio_dir == 16'h0001) && AHB_write);

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

    // Check Registers reset properly
    GPIO_Registers_Reset: assert property(
                                        @(posedge HRESETn)
                                        ##1 (gpio_dataout == 0 && gpio_datain == 0 && gpio_dir == 0 && last_HADDR == 0 && last_HTRANS == 0 && last_HWRITE == 0 && last_HSEL == 0)
                                        );

    // If write operation then the gpio_dataout register is same as the HWDATA inputted (clock cycle delay of 2 as it takes 1 to load the data and another to update GPIO dataout)
    GPIO_Dataout_Update: assert property(
                                        @(posedge HCLK) disable iff(!HRESETn)
                                        (gpio_write_bool && (HADDR == gpio_data_addr_value)) |-> ##2 (last_HWDATA == gpio_dataout)
                                        );

    // If read operation then read data from external device
    Read_From_Device: assert property(
                                    @(posedge HCLK) disable iff(!HRESETn)
                                    (gpio_dir == 16'h0000) |-> ##1 (last_GPIOIN == gpio_datain))
                                    else $error("The expected value of gpio_datain is: %h and the actual value is %h", last_GPIOIN, gpio_datain);

    // Assert that if the write condition is not true then there should be no updates happening to gpio_dataout
    GPIO_No_Write_Updates: assert property(
                                        @(posedge HCLK) disable iff(!HRESETn)
                                        !(gpio_write_bool && (HADDR == gpio_data_addr_value)) |-> ##2 $stable(gpio_dataout)
                                        );

    // Assert that if the write condition is not true then there should be no updates happening to gpio_dataout
    GPIO_Dir_Register_Update: assert property(
                                            @(posedge HCLK) disable iff(!HRESETn)
                                            (gpio_write_bool && (HADDR == gpio_dir_addr_value)) |-> ##1 (HWDATA == 16'h0000 || HWDATA == 16'h0001) |-> ##1 gpio_dir == last_HWDATA
                                            );

    // Make sure that direction register of gpio_dir is either 0 or 1
    GPIO_Dir_Register_Range: assert property(
                                            @(posedge HCLK) disable iff(!HRESETn)
                                            (gpio_dir == 16'h0000) or (gpio_dir == 16'h0001)
                                            );

    // If direction register it output then gpio_datain == gpio_dataout
    GPIO_No_Read_Updates: assert property(
                                        @(posedge HCLK) disable iff(!HRESETn)
                                        (gpio_dir == 16'h0001) |-> ##1 (last_GPIOOUT == gpio_datain)
                                        );

endinterface