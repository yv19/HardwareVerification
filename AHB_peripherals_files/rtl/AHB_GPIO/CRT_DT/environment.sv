`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
// `include "model.sv"

class environment;
  
  //generator and driver instance
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;
  
  //mailbox handle's
  mailbox gen2driv;
  mailbox mon2scb;
  mailbox driv2mon;
  mailbox model2scb;

  // define model of GPIO
  model mod;
  
  //event for synchronization between generator and test
  event gen_ended;
  event receivedPacket;
  
  //virtual interface
  virtual gpio_intf gpio_vif;
  
  //constructor
  function new(virtual gpio_intf gpio_vif);
    //get the interface from test
    this.gpio_vif = gpio_vif;
    //creating the mailbox (Same handle will be shared across generator and driver)
    gen2driv = new();
    mon2scb  = new();
    driv2mon = new();
    model2scb = new();
    
    //creating generator and driver
    mod = new(model2scb);
    gen  = new(gen2driv, mod, gen_ended);
    driv = new(gpio_vif, gen2driv, driv2mon, receivedPacket);
    mon  = new(gpio_vif, mon2scb, driv2mon, receivedPacket);
    scb  = new(gpio_vif, mon2scb, model2scb);
  endfunction
  
  //
  task pre_test();
    driv.reset();
  endtask
  
  task test();
    fork 
    gen.finishedGeneratingCallback();
    driv.main();
    mon.main();
    scb.main();
    join_any
  endtask
  
  task post_test();
    wait(gen_ended.triggered);
    wait(gen.repeat_count == driv.no_transactions);
    wait(gen.repeat_count == scb.no_transactions);
    // close the file and do a finish
    scb.closeFile();
  endtask
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
  endtask
  
endclass