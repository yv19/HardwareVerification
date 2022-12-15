`include "transaction.sv"

class scoreboard;

  //creating mailbox handle
  mailbox mon2scb;

  //used to count the number of transactions
  int no_transactions;
  // frame_t genFrame;
  int scoreFile;
  int file;
  int counter;

  localparam number_of_test_types = 3;

  //creating virtual interface handle
  virtual gpio_intf gpio_vif;

  // allocate a dictionary to link between test id and test cases passed
  // link would be int -> int for both dictionaries
  // int tests_passed [int];
  int total_tests [int];

  //constructor
  function new(virtual gpio_intf gpio_vif, mailbox mon2scb);
    //getting the mailbox handles from  environment
    this.mon2scb = mon2scb;
    this.gpio_vif = gpio_vif;
  endfunction

  //stores wdata and compare rdata with stored data
  task main;
    transaction dut_trans;
    // Consume the first VSYNC as it goes low upon reset
    instantiateScores();
    scoreFile = $fopen($sformatf("./output/gpio/scb/gpio_test_score.txt"), "w");
    forever begin
      // get data from the monitor
      mon2scb.get(dut_trans);

      updateTestScore(dut_trans, dut_trans.testType);

      counter++;
      no_transactions++;
    end
  endtask

  function instantiateScores();
    for (int i = 0; i < number_of_test_types; i++) begin
      total_tests[i] = 0;
      // tests_passed[i] = 0;
    end
  endfunction

  function updateTestScore(transaction dut_trans, int testType);
    // increment the counter for the total tests of that specific test
    total_tests[testType] = total_tests[testType] + 1;
  endfunction

  function closeFile();
    //write onto final file the total score
    for (int i = 0; i < number_of_test_types; i++) begin
      $display($sformatf("Test Type %0d: %0d/%0d", i, total_tests[i], total_tests[i]));
      $fwrite(scoreFile, $sformatf("Test Type %0d: %0d/%0d \n", i, total_tests[i], total_tests[i]));
    end
    $fclose(scoreFile);
    $finish;
  endfunction

endclass
