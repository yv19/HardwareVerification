`include "transaction.sv"

`ifndef MODEL
`define MODEL

class model;
  mailbox model2scb;

  logic last_HREADYOUT;
  logic [31:0] last_HRDATA;
  logic [16:0] last_GPIOOUT;
  logic last_PARITYERR;
  logic PARITY_OUT;

  logic [15:0] gpio_dataout;
  logic [15:0] gpio_datain;
  logic [15:0] gpio_dir;

  //constructor
  function new(mailbox model2scb);
    //getting the mailbox handle from env
    this.model2scb = model2scb;
  endfunction

  task sendOutputToScb(transaction trans);
    automatic transaction expectedTrans;
    generateExpectedValue(trans, expectedTrans);
    model2scb.put(expectedTrans);
  endtask

  function transaction generateFullFrame(transaction transInput, transaction expectedTransOutput);
    if ( // Invalid Input
        (trans.HADDR != 32'h53000000) ||
        (trans.HADDR != 32'h53000004 && (trans.HWDATA !== 32'h00000001 && trans.HWDATA !== 32'h00000000)) || 
        (trans.HWRITE == 1'b0) || 
        (trans.HSEL == 1'b0) || 
        (trans.HTRANS == 2'd0) || 
        (trans.HREADY == 1'b0)
        ) 
    begin
      if (gpio_dir == 0) begin
        // Store new gpio datain
        gpio_datain = transInput.GPIOIN;
        expectedTransOutput.HRDATA = gpio_datain;
        // Compute new parity error
        expectedTransOutput.PARITYERR = ^transInput.GPIOIN ^ transInput.PARITYSEL ^ transInput.GPIOIN[16];

        last_HRDATA = expectedTransOutput.HRDATA;
        last_PARITYERR = expectedTransOutput.PARITYERR
      end
      else begin
        expectedTransOutput.HRDATA = last_HRDATA;
        expectedTransOutput.PARITYERR = last_PARITYERR;
      end
      expectedTransOutput.GPIOOUT = last_GPIOOUT;
    end
    else begin // Valid Input
      // If we are updating the address register of the GPIO block
      if (trans.HADDR == 32'h53000004) begin
        gpio_dir = transInput.HWDATA;
        if (curr_gpio_dir == 1) begin // output
          // Update HRDATA to be gpio_dataout
          expectedTransOutput.HRDATA[15:0] = gpio_dataout;
          expectedTransOutput.PARITYERR = last_PARITYERR;
        end
        else begin // input
          // HRDATA == GPIOIN
          gpio_datain = transInput.GPIOIN;
          expectedTransOutput.PARITYERR = ^transInput.GPIOIN ^ transInput.PARITYSEL ^ transInput.GPIOIN[16];
          expectedTransOutput.HRDATA = gpio_datain;
        end
      end
      // If we are updating the data register of the GPIO block
      else begin
        if (curr_gpio_dir == 1) begin // output
          // Update the gpio dir register
          gpio_dataout = transInput.HWDATA;
          last_PARITYERR = ; // calculate parity error
        end
      end
    end
    expectedTransOutput.HREADYOUT = 1'b1;
    shiftCounter++;
    res = insertCharIntoFrame(res, x, y, generateFullChar(trans.HWDATA[i]));
    return res;

    // $display("%p", res);
  endfunction

  function frame insertCharIntoFrame(frame fullFrame, int x, int y, char_t data);
    for (int j = 0; j < $size(data); j++) begin
      for (int i = 0; i < $size(data[0]); i++) begin
        fullFrame[y*16 + j][x*8 + i] = data[j][i];
      end
    end
    return fullFrame;
  endfunction

endclass

`endif
