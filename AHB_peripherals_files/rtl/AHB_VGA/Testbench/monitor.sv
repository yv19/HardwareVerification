`include "transaction.sv"

`define MON_IF vga_vif.monitor_cb

class monitor;
  
  //creating virtual interface handle
  virtual vga_intf vga_vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  mailbox driv2mon;
  
  int i;
  int j;
  
  //constructor
  function new(virtual vga_intf vga_vif, mailbox mon2scb, mailbox driv2mon);
    //getting the interface
    this.vga_vif = vga_vif;
    //getting the mailbox handles from  environment
    this.mon2scb = mon2scb;
    this.driv2mon = driv2mon;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    forever begin
      automatic transaction trans;
      @(negedge `MON_IF.VSYNC);
      // Create the frame
      repeat(35) begin
        @(negedge `MON_IF.HSYNC);
      end
      driv2mon.get(trans); // Get the transaction from the generator
      // now on the correct line to record text console region
      i = 0;
      j = 0;
      // loop until clock has reached 145
      while(j < 480) begin
        repeat (144 << 1) begin
          @(posedge vga_vif.HCLK);
        end
        while (i < 240) begin
          trans.frame[j][i] = (`MON_IF.RGB == 8'h1c) ? 1 : 0;
          // half sampling rate
          @(posedge vga_vif.HCLK);
          @(posedge vga_vif.HCLK);
          i++;
        end
        @(negedge `MON_IF.HSYNC)
        i = 0;
        j++;
      end
      // Send to Scoreboard
      mon2scb.put(trans);
    end
  endtask
  
endclass