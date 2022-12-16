`include "transaction.sv"
`include "model.sv"

class generator;
  //declaring mailbox
  mailbox gen2driv;
  
  //repeat count, to specify number of items to generate
  int repeat_count;  

  event genCallback;

  model mod;

  //constructor
  function new(mailbox gen2driv,event genCallback, model mod);
    this.mod = mod;
    this.gen2driv = gen2driv;
    this.genCallback = genCallback;
  endfunction

  function GenCallback();
    -> genCallback;
  endfunction

  task randomizeControlSignals(int number_of_inputs);
    automatic transaction trans = new();
    trans.same_c.constraint_mode(0); // randomize character
    trans.ahblite_valid_signals.constraint_mode(0); // randomize ahblite control signals
    trans.INPUTSIZE = number_of_inputs + 2; // Adding 2 for the end of packet transaction to still make the signal valid
    trans.testType = 0;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  // Function used to generate character given x and y positions (x and y can only be in the range 0 <= x, y < 30)
  task generateRandomCharAtPos(int x, int y);
    automatic transaction trans = new();
    automatic int c_pos = x + (y * 30);
    trans.same_c.constraint_mode(0); // turn same char constraint off
    trans.INPUTSIZE = c_pos + 3;
    trans.testType = 1;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    padWithZeros(trans, c_pos);
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task generateRandomCharRandomPos();
    automatic transaction trans = new();
    automatic position pos = new();
    automatic int c_pos;
    if( !pos.randomize() ) $fatal("Gen:: pos randomization failed");
    c_pos = pos.x + (pos.y * 30);
    trans.same_c.constraint_mode(0); // turn same char constraint off
    trans.INPUTSIZE = c_pos + 3;
    trans.testType = 2;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    padWithZeros(trans, c_pos);
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task generateRandomCharSamePos();
    automatic transaction trans = new();
    automatic int c_pos;
    automatic int x = 15;
    automatic int y = 0;
    c_pos = x + (y * 30);
    trans.INPUTSIZE = c_pos + 3;
    trans.testType = 3;
    trans.same_c.constraint_mode(0); // turn same char constraint off
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    padWithZeros(trans, c_pos);
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task outputBlank();
    automatic transaction trans = new();
    trans.INPUTSIZE = 3;
    trans.testType = 6;

    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    trans.HWDATA[0] = 32'h0;

    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  // Will generate 898 characters (can only do 898 otherwise there will be a scrolling issue)
  task fullFrameTest();
    automatic transaction trans = new();
    trans.INPUTSIZE = 900;
    trans.testType = 4;
    // randomize packets
    trans.same_c.constraint_mode(0); // turn same char constraint off
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task generateSameCharRandomPos();
    automatic transaction trans = new();
    automatic position pos = new();
    int c_pos;
    if( !pos.randomize() ) $fatal("Gen:: pos randomization failed");
    c_pos = pos.x + (pos.y * 30);
    trans.INPUTSIZE = c_pos + 3;
    trans.testType = 5;
    if( !trans.randomize() ) $fatal("Gen:: trans randomization failed");
    padWithZeros(trans, c_pos);
    endTransactionPacket(trans);
    gen2driv.put(trans);
    // Update the repeat count for env
    repeat_count++;
  endtask

  task padWithZeros(transaction trans, int c_pos);
    automatic int INPUTSIZE = trans.INPUTSIZE;
    for (int i = 0; i <= INPUTSIZE; i++) begin
      if (i != c_pos) begin
        trans.HWDATA[i] = 32'h0;
      end
    end
  endtask

  // Function to append the blank character and put HWRITE and HSEL to low 
  task endTransactionPacket(transaction trans);
    automatic int INPUTSIZE = trans.INPUTSIZE;
    trans.HWDATA[INPUTSIZE-2] = 32'h00000000;
    trans.HWRITE[INPUTSIZE-1] = 1'b0;
    trans.HSEL[INPUTSIZE-1] = 1'b0;
    // Send to the model
    mod.sendFrameToScoreboard(trans);
  endtask
endclass