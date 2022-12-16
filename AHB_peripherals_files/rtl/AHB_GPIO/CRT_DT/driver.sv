`include "generator.sv"

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual gpio_intf gpio_vif;
  
  //creating mailbox handle
  mailbox gen2driv;
  mailbox driv2mon;

  event receivedPacket;
  
  //constructor
  function new(virtual gpio_intf gpio_vif, mailbox gen2driv, mailbox driv2mon, event receivedPacket);
    //getting the interface
    this.gpio_vif = gpio_vif;
    //getting the mailbox handle from  environment 
    this.gen2driv = gen2driv;
    this.driv2mon = driv2mon;
    this.receivedPacket = receivedPacket;
  endfunction

  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(gpio_vif.HRESETn);
    $display("--------- [DRIVER] Reset Started ---------");
    gpio_vif.HADDR <= 0;
    gpio_vif.HWDATA <= 0;
    gpio_vif.HREADY <= 0;      
    gpio_vif.HWRITE <= 0;
    gpio_vif.HTRANS <= 0;
    gpio_vif.HSEL <= 0;
    gpio_vif.GPIOIN <= 0;
    gpio_vif.PARITYSEL <= 0;
    wait(!gpio_vif.HRESETn);
    $display("--------- [DRIVER] Reset Ended---------");
  endtask
  
  //drive the transaction items to interface signals
  task main;
    forever begin
      automatic transaction trans;
      gen2driv.get(trans); // Get the transaction from the generator
      driv2mon.put(trans);
      wait(receivedPacket.triggered);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);

      @(posedge gpio_vif.HCLK); // Interface clock edge

      gpio_vif.HADDR <= trans.HADDR;    
      gpio_vif.HWRITE <= trans.HWRITE;
      gpio_vif.GPIOIN <= trans.GPIOIN;
      gpio_vif.PARITYSEL <= trans.PARITYSEL;

      gpio_vif.HSEL <= trans.HSEL;
      gpio_vif.HREADY <=  trans.HREADY;  
      gpio_vif.HTRANS <= trans.HTRANS;

      @(posedge gpio_vif.HCLK); // Interface clock edge

      gpio_vif.HWDATA <= trans.HWDATA;

      // This is when the update for GPIO should happen

      $display("-----------------------------------------");
      no_transactions++;
    end
  endtask

endclass