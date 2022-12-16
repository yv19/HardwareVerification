`include "transaction.sv"

`ifndef MODEL
`define MODEL

class model;
  mailbox model2scb;

  logic [31:0] last_HRDATA;
  logic [16:0] last_GPIOOUT;
  logic PARITY_OUT;

  logic [15:0] gpio_dataout;
  logic [15:0] gpio_datain;
  logic [15:0] gpio_dir;

  //constructor
  function new(mailbox model2scb);
    //getting the mailbox handle from env
    this.model2scb = model2scb;

    gpio_dataout = 0;
    gpio_datain = 0;
    gpio_dir = 0;
    PARITY_OUT = 0;
    last_GPIOOUT = 0;
    last_HRDATA = 0;
  endfunction

  task sendOutputToScb(transaction trans);
    model2scb.put(generateExpectedValue(trans));
  endtask

  function transaction generateExpectedValue(transaction transInput);
    automatic transaction expectedTransOutput;
    expectedTransOutput = new();
    if ( // Invalid Input
        ((transInput.HADDR != 32'h53000000) &&
        (transInput.HADDR != 32'h53000004 && (transInput.HWDATA !== 32'h00000001 && transInput.HWDATA !== 32'h00000000))) ||
        (transInput.HWRITE == 1'b0) ||
        (transInput.HSEL == 1'b0) ||
        (transInput.HTRANS == 2'd0) ||
        (transInput.HREADY == 1'b0)
        ) 
    begin
      $display("Invalid input");
      PARITY_OUT = ^gpio_dataout ^ transInput.PARITYSEL;
      if (gpio_dir == 0) begin
        // Store new gpio datain
        gpio_datain = transInput.GPIOIN;
        expectedTransOutput.HRDATA = {16'h0, gpio_datain};
      end
      else begin
        expectedTransOutput.HRDATA = {16'h0, gpio_dataout};
      end
      expectedTransOutput.GPIOOUT = {PARITY_OUT, gpio_dataout};
    end
    else begin // Valid Input
      $display("Valid input");
      // If we are updating the address register of the GPIO block
      if (transInput.HADDR == 32'h53000004) begin
        gpio_dir = transInput.HWDATA;
        PARITY_OUT = ^gpio_dataout ^ transInput.PARITYSEL;
        expectedTransOutput.GPIOOUT = {PARITY_OUT, gpio_dataout};
        if (gpio_dir == 1) begin // output
          // Update HRDATA to be gpio_dataout
          expectedTransOutput.HRDATA = {16'h0, gpio_dataout};
        end
        else begin // input
          // HRDATA == GPIOIN
          gpio_datain = transInput.GPIOIN;
          expectedTransOutput.HRDATA = {16'h0, gpio_datain};
        end
      end
      // If we are updating the data register of the GPIO block
      else begin
        if (gpio_dir == 1) begin // output
          gpio_dataout = transInput.HWDATA;
          PARITY_OUT = ^gpio_dataout ^ transInput.PARITYSEL;
          $display("Parity select out is %h", PARITY_OUT);
          expectedTransOutput.GPIOOUT = {PARITY_OUT, gpio_dataout};
          // Update HRDATA to be gpio_dataout
          expectedTransOutput.HRDATA = {16'h0, gpio_dataout};
        end
        else begin
          // Store new gpio datain
          gpio_datain = transInput.GPIOIN;
          expectedTransOutput.HRDATA = {16'h0, gpio_datain};
          PARITY_OUT = ^gpio_dataout ^ transInput.PARITYSEL;
          expectedTransOutput.GPIOOUT = {PARITY_OUT, gpio_dataout};
        end
      end
    end
    // Compute new parity error
    last_HRDATA = expectedTransOutput.HRDATA;
    last_GPIOOUT = expectedTransOutput.GPIOOUT;
    expectedTransOutput.PARITYERR = ^transInput.GPIOIN ^ transInput.PARITYSEL ^ transInput.GPIOIN[16];
    expectedTransOutput.HREADYOUT = 1;

    return expectedTransOutput;
  endfunction

endclass

`endif
