module AHB_GPIO_monitor(
    input wire HCLK,
    input wire HRESETn,
    input wire Model_HREADYOUT,
    input wire [31:0] Model_HRDATA,
    input wire [16:0] Model_GPIOOUT,

    input wire GPIO_HREADYOUT,
    input wire [31:0] GPIO_HRDATA,
    input wire [16:0] GPIO_GPIOOUT
);

always @(posedge HCLK) begin
$display("@%0d: HCLK asserted", $time);
end
endmodule