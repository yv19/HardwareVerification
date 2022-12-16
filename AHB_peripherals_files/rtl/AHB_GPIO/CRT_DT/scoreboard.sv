`include "transaction.sv"

class scoreboard;

  //creating mailbox handle
  mailbox mon2scb;
  mailbox model2scb;

  //used to count the number of transactions
  int no_transactions;
  // frame_t genFrame;
  int scoreFile;
  int file;
  int counter;

  localparam number_of_test_types = 4;

  //creating virtual interface handle
  virtual gpio_intf gpio_vif;

  // allocate a dictionary to link between test id and test cases passed
  // link would be int -> int for both dictionaries
  int tests_passed [int];
  int total_tests [int];

  covergroup controlSignalsCoverGroup with function sample (
      logic [31:0] HADDR, logic [31:0] HWDATA, logic [1:0] HTRANS, logic HREADY, logic HWRITE, logic HSEL
  );
    // Control signal bins to satisfy testing for control signals
    coverpoint HTRANS {bins htrans[] = {[2'h0:2'h2]};}
    coverpoint HREADY;
    coverpoint HWRITE;
    coverpoint HSEL;

    Write_Data_Reg: coverpoint HADDR {bins addr1 = {32'h53000000};}
    Write_Dir_Reg: coverpoint HADDR {bins addr2 = {32'h53000004};}
    Write_Invalid_Reg: coverpoint HADDR {bins addr3 = {[0 : 32'h49999999], [32'h53000001 : 32'h50000003], [32'h50000005 : 32'hffffffff]};}
    Write_Output_Dir: coverpoint HWDATA {bins out1 = {32'h0001};}
    Write_Input_Dir: coverpoint HWDATA {bins out2 = {32'h0000};}
    Change_Output: cross Write_Output_Dir, Write_Dir_Reg{}
    Change_Input: cross Write_Input_Dir, Write_Dir_Reg{}
  endgroup

  //constructor
  function new(virtual gpio_intf gpio_vif, mailbox mon2scb, mailbox model2scb);
    //getting the mailbox handles from  environment
    this.controlSignalsCoverGroup = new();
    this.mon2scb = mon2scb;
    this.gpio_vif = gpio_vif;
    this.model2scb = model2scb;
  endfunction

  //stores wdata and compare rdata with stored data
  task main;
    transaction dut_trans;
    transaction model_trans;
    // Consume the first VSYNC as it goes low upon reset
    instantiateScores();
    scoreFile = $fopen($sformatf("./output/gpio/scb/gpio_test_score.txt"), "w");
    forever begin
      // get data from the monitor
      mon2scb.get(dut_trans);
      model2scb.get(model_trans);

      updateTestScore(dut_trans, model_trans, dut_trans.testType);
      controlSignalsCoverGroup.sample(dut_trans.HADDR, dut_trans.HWDATA, dut_trans.HTRANS, dut_trans.HREADY, dut_trans.HWRITE, dut_trans.HSEL);

      counter++;
      no_transactions++;
    end
  endtask

  function instantiateScores();
    for (int i = 0; i < number_of_test_types; i++) begin
      total_tests[i] = 0;
      tests_passed[i] = 0;
    end
  endfunction

  function updateTestScore(transaction dut_trans, transaction mod_trans, int testType);
    // increment the counter for the total tests of that specific test
    // increment the counter for the total tests of that specific test
    $display($sformatf("HREADYOUT %0h %0h", dut_trans.HREADYOUT, mod_trans.HREADYOUT));
    $display($sformatf("HRDATA %0h %0h", dut_trans.HRDATA[15:0], mod_trans.HRDATA[15:0]));
    $display($sformatf("GPIOOUT %0h %0h", dut_trans.GPIOOUT, mod_trans.GPIOOUT));
    $display($sformatf("PARITYERR %0h %0h", dut_trans.PARITYERR, mod_trans.PARITYERR));
    if (
      dut_trans.HREADYOUT == mod_trans.HREADYOUT &&
      dut_trans.HRDATA[15:0] == mod_trans.HRDATA[15:0] &&
      dut_trans.GPIOOUT == mod_trans.GPIOOUT &&
      dut_trans.PARITYERR == mod_trans.PARITYERR
    ) begin
      tests_passed[testType] = tests_passed[testType] + 1;
    end
    total_tests[testType] = total_tests[testType] + 1;
  endfunction

  function closeFile();
    //write onto final file the total score
    for (int i = 0; i < number_of_test_types; i++) begin
      $display($sformatf("Test Type %0d: %0d/%0d", i, tests_passed[i], total_tests[i]));
      $fwrite(scoreFile, $sformatf("Test Type %0d: %0d/%0d \n", i, tests_passed[i], total_tests[i]));
    end
    $fclose(scoreFile);
    $finish;
  endfunction

endclass
