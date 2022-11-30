class gpio_model;
    // Queue of register values
    bit [15:0] gpio_dataout_queue [$] = { 0, 0 };
    bit [15:0] gpio_datain_queue [$] = { 0, 0 };
    bit[15:0] gpio_dir_queue [$] = { 0, 0 };

    task model_reset();
        this.gpio_dataout_queue = { 0, 0 };
        this.gpio_datain_queue = { 0, 0 };
        this.gpio_dataout_queue = { 0, 0 };
    endtask

    // Take all the inputs excluding clock input as that is controlled by the gpio model module
    task generate_gpio_model_output(
        input HRESETn,
        input [31:0] HADDR,
        input [1:0] HTRANS,
        input [31:0] HWDATA,
        input HWRITE,
        input HSEL,
        input HREADY,
        input [16:0] GPIOIN,
        input PARITYSEL,

        output [15:0] gpio_dataout,
        output [15:0] gpio_datain,
        output [15:0] gpio_dir
    )

        // Push new values calculated at the back of the queue
        gpio_dataout_queue.push_back();
        gpio_datain_queue.push_back();
        gpio_dir_queue.push_back();

        // Update output values
        gpio_dataout = gpio_dataout_queue.pop_front();
        gpio_datain = gpio_datain_queue.pop_front();
        gpio_dir = gpio_dir_queue.pop_front();

    endtask
endclass //gpio_model

// Module used to compare with the DUT which will be fed into Monitor for scoring
module AHB_GPIO_Model(
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


    //Output
    output wire HREADYOUT,
    output wire [31:0] HRDATA,
    output wire [16:0] GPIOOUT
);

    localparam [31:0] gpio_data_addr = 32'h53000000;
    localparam [31:0] gpio_dir_addr = 32'h53000004;

    // Models own internal state of the registers
    reg [15:0] gpio_dataout;
    reg [15:0] gpio_datain;
    reg [15:0] gpio_dir;

    // GPIO Model Class
    gpio_model model;

    initial begin
        // Allocate memory for the model
        model = new();
    end

    always @(posedge HCLK, negedge HRESETn)
    begin
        if(!HRESETn)
        begin
            gpio_dataout <= 16'h0000;
            gpio_datain <= 16'h0000;
            gpio_dir <= 16'h0000;
            model.reset();
        end
        else
        begin
            // Run function to calculate new gpio registers using input wires
            model.generate_gpio_model_output(HRESETn, HADDR, HTRANS, HWDATA, HWRITE, HSEL, HREADY, GPIOIN, PARITYSEL, gpio_dataout, gpio_datain, gpio_dir);
            $display("Updated Model GPIO Registers");
        end
    end


    assign HREADYOUT = 1'b1;
    assign HRDATA[15:0] = gpio_datain;
    assign GPIOOUT = gpio_dataout;

endmodule