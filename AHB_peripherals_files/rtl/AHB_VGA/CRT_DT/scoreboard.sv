`include "transaction.sv"

`define SCB_IF vga_vif.scoreboard_cb

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

  localparam number_of_test_types = 7;

  //creating virtual interface handle
  virtual vga_intf vga_vif;

  // allocate a dictionary to link between test id and test cases passed
  // link would be int -> int for both dictionaries
  int tests_passed [int];
  int total_tests [int];

  covergroup charCoverGroup with function sample (logic [31:0] HWDATA, int PosX, int PosY);
    // bins to test whether every character is satisfied
    CHAR: coverpoint HWDATA {bins char[] = {[32'h45:32'h50]};}
    // bins to test that a character is in all parts of the screen
    X: coverpoint PosX {bins x[] = {[0 : 29]};}
    Y: coverpoint PosY {bins y[] = {[0 : 29]};}
    Pos: cross X, Y{}
  endgroup

  covergroup controlSignalsCoverGroup with function sample (
      logic [31:0] HADDR, logic [1:0] HTRANS, logic HREADY, logic HWRITE, logic HSEL
  );
    // Control signal bins to satisfy testing for control signals
    coverpoint HTRANS {bins htrans[] = {[2'h0:2'h2]};}
    coverpoint HREADY;
    coverpoint HWRITE;
    coverpoint HSEL;
    // bins for HADDR (1 bin for the correct VGA address and else)
    coverpoint HADDR {
      bins correct_addr = {32'h50000000};
      bins other_addr = {[0 : 32'h49999999], [32'h50000001 : 32'hffffffff]};
    }
  endgroup

  //constructor
  function new(virtual vga_intf vga_vif, mailbox mon2scb, mailbox model2scb);
    // Instantiate the covergroup bins for functional coverage
    this.charCoverGroup = new();
    this.controlSignalsCoverGroup = new();
    //getting the mailbox handles from  environment
    this.mon2scb = mon2scb;
    this.model2scb = model2scb;
    this.vga_vif = vga_vif;
  endfunction

  //stores wdata and compare rdata with stored data
  task main;
    transaction dut_trans;
    logic model_frame [480][240];
    // Consume the first VSYNC as it goes low upon reset
    instantiateScores();
    scoreFile = $fopen($sformatf("./output/vga/scb/vga_test_score.txt"), "w");
    forever begin
      mon2scb.get(dut_trans);
      model2scb.get(model_frame);
      sampleSignals(dut_trans);
      updateTestScore(dut_trans.frame, model_frame, dut_trans.testType);
      writeFrame(0, dut_trans.frame);
      writeFrame(1, model_frame);
      counter++;
      no_transactions++;
    end
  endtask

  function sampleSignals(transaction dut_trans);
    for (int i = 0; i < dut_trans.INPUTSIZE; i++) begin
      charCoverGroup.sample(dut_trans.HWDATA[i], i % 30, i / 30);
      controlSignalsCoverGroup.sample(dut_trans.HADDR[i], dut_trans.HTRANS[i], dut_trans.HREADY[i], dut_trans.HWRITE[i], dut_trans.HSEL[i]);
    end
  endfunction

  function instantiateScores();
    for (int i = 0; i < number_of_test_types; i++) begin
      total_tests[i] = 0;
      tests_passed[i] = 0;
    end
  endfunction

  function writeFrame(int isMod, logic frame[480][240]);
    string outputFrom = (isMod) ? "mod" : "dut";
    file = $fopen($sformatf("./output/vga/scb/%s_%0d.txt", outputFrom, counter), "w");
    for (int j = 0; j < $size(frame); j++) begin
      for (int i = 0; i < $size(frame[j]); i++) begin
        if (frame[j][i] == 1'b1) begin
          $fwrite(file, "%s", "#");
        end else begin
          $fwrite(file, "%s", " ");
        end
      end
      $fwrite(file, "%s", "\n");
    end
    $fclose(file);
  endfunction

  function updateTestScore(logic dut_frame[480][240], logic mod_frame[480][240], int testType);
    automatic int hasFailed = 0; 
    for (int j = 0; j < $size(mod_frame); j++) begin
      for (int i = 0; i < $size(mod_frame[j]); i++) begin
        if (dut_frame[j][i] != mod_frame[j][i]) begin
          hasFailed = 1;
          break;
        end
      end
      if (hasFailed) begin
        break;
      end
    end
    // incremenet the counter if test has passed
    tests_passed[testType] = tests_passed[testType] + 1 - hasFailed;
    // increment the counter for the total tests of that specific test
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
