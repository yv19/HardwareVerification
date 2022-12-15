`include "transaction.sv"

class monitor;
  
  //creating virtual interface handle
  virtual gpio_intf gpio_vif;
  
  //creating mailbox handle
  mailbox mon2scb;
  mailbox driv2mon;

  event receivedPacket;
  
  int i;
  int j;
  
  //constructor
  function new(virtual gpio_intf gpio_vif, mailbox mon2scb, mailbox driv2mon, event receivedPacket);
    //getting the interface
    this.gpio_vif = gpio_vif;
    //getting the mailbox handles from  environment
    this.mon2scb = mon2scb;
    this.driv2mon = driv2mon;
    this.receivedPacket = receivedPacket;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
    forever begin
      automatic transaction trans;
      driv2mon.get(trans); // Get the transaction from the generator
      -> receivedPacket;

      @(posedge gpio_vif.HCLK); // Address Phase
      @(posedge gpio_vif.HCLK); // Data Phase
      @(posedge gpio_vif.HCLK); // Output Should be recorded
      
      trans.HREADYOUT = gpio_vif.HREADYOUT;
      trans.HRDATA = gpio_vif.HRDATA;
      trans.GPIOOUT = gpio_vif.GPIOOUT;
      trans.PARITYERR = gpio_vif.PARITYERR;

      // Send to Scoreboard
      mon2scb.put(trans);
    end
  endtask
  
endclass