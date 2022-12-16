`include "transaction.sv"
`include "model.sv"

class generator;
  //declaring mailbox
  mailbox gen2driv;
  model mod;
  
  //repeat count, to specify number of items to generate
  int repeat_count;  
  //event
  event ended;

  //constructor
  function new(mailbox gen2driv, model mod, event ended);
    //getting the mailbox handle from env
    this.gen2driv = gen2driv;
    this.mod = mod;
    this.ended = ended;
  endfunction

  function finishedGeneratingCallback();
    -> ended;
  endfunction

  task writeToDataReg();
    automatic transaction trans = new();
    trans.testType = 0;
    // Randomize HWDATA to be anything between 16'h0000 to 16'hffff
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    trans.HADDR = 32'h53000000;
    gen2driv.put(trans);
    mod.sendOutputToScb(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task writeOutputToDirReg();
    automatic transaction trans = new();
    trans.testType = 1;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    trans.HADDR = 32'h53000004;
    trans.HWDATA = 16'h0001;
    gen2driv.put(trans);
    mod.sendOutputToScb(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task writeInputToDirReg();
    automatic transaction trans = new();
    trans.testType = 2;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    trans.HADDR = 32'h53000004;
    trans.HWDATA = 16'h0000;
    gen2driv.put(trans);
    mod.sendOutputToScb(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task randomizeInput();
    automatic transaction trans = new();
    trans.testType = 3;
    trans.ahblite_valid_signals.constraint_mode(0);
    trans.HWDATA_upper_bound.constraint_mode(0);
    trans.min_GPIO_constraint.constraint_mode(0);
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    gen2driv.put(trans);
    mod.sendOutputToScb(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

endclass