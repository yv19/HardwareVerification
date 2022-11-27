`timescale 1ns/1ps
module gpio_random_top(

);
reg HRESETn, HCLK;
wire [7:0] LED;

wire [31:0] HADDR;
wire [1:0] HTRANS;
wire [31:0] HWDATA;
wire HWRITE;
wire HSEL;
wire HREADY;
wire [15:0] GPIOIN;

// Instantiate the AHBLite GPIO	
GPIO_Stimulus uGPIO_Stimulus(
	.HCLK(HCLK),
	.HRESETn(HRESETn),

	.HADDR(HADDR),
	.HWDATA(HWDATA),
	.HREADY(HREADY),
	.HWRITE(HWRITE),
	.HTRANS(HTRANS),
	.HSEL(HSEL),
	.GPIOIN(GPIOIN)
	);

// Instantiate the AHBLite GPIO	
AHBGPIO uAHBGPIO(
	.HCLK(HCLK),
	.HRESETn(HRESETn),
	.HADDR(HADDR),
	.HWDATA(HWDATA),
	.HREADY(HREADY),
	.HWRITE(HWRITE),
	.HTRANS(HTRANS),

	.HSEL(HSEL),
	.HRDATA(HRDATA_GPIO),
	.HREADYOUT(HREADYOUT_GPIO),
    
	.GPIOIN(GPIOIN),
	.GPIOOUT(LED[7:0])
	);

initial
begin
    HCLK=0;
    forever
    begin
        #5 HCLK=1;
        #5 HCLK=0;
    end
end

initial
begin
    // Reset everything
    HRESETn=1;
    #30 HRESETn=0;
    #20 HRESETn=1;
end
endmodule