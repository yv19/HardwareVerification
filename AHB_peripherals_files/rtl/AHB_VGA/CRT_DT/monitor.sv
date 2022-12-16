`include "transaction.sv"

`define MON_CLB vga_vif.monitor_cb

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
      initiateMonitor();
      driv2mon.get(trans); // Get the transaction from the generator
      updateTransactionFrame(trans);
      // now on the correct line to record text console region
      // loop until clock has reached 145
      mon2scb.put(trans);
    end
  endtask

  task initiateMonitor;
    // Wait for the first VSYNC
    @(negedge `MON_CLB.VSYNC);
    // Wait for 35 HSYNCS due to the vertical padding around the text region
    waitForHSYNCS(35);
  endtask

  task waitForHSYNCS(int hSYNCCount);
    for (int i = 0; i < hSYNCCount; i++) begin
      @(negedge `MON_CLB.HSYNC);  
    end
  endtask

  task updateTransactionFrame(transaction trans);
    for (int j = 0; j < 480; j++) begin
      waitForCLKS(288);
      for (int i = 0; i < 240; i++) begin
        trans.frame[j][i] = (`MON_CLB.RGB == 8'h1c) ? 1 : 0;
        // half sampling rate
        waitForCLKS(2);
      end
      @(negedge `MON_CLB.HSYNC);
    end
  endtask

  task waitForCLKS(int cLKSCount);
    for (int i = 0; i < cLKSCount; i++) begin
      @(posedge vga_vif.HCLK);  
    end
  endtask
  
endclass