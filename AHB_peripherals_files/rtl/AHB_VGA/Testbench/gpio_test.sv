`include "environment.sv"
program test(vga_intf intf, intf_copy);

  // DO NOT SET INPUTSIZE > 898
  //declaring environment instance
  environment env;
  
  initial begin
    env = new(intf, intf_copy);
    // Generate inputs
    env.gen.outputBlank();
    env.gen.generateRandomCharSamePos();
    env.gen.generateRandomCharSamePos();
    env.gen.generateRandomCharRandomPos();
    env.gen.generateRandomCharAtPos(27, 29); // edge case
    env.gen.generateRandomCharAtPos(0, 0); // edge case
    env.gen.fullFrameTest(); // big scale edge case
    env.gen.randomizeControlSignals(20);
    env.gen.randomizeControlSignals(30);
    env.gen.randomizeControlSignals(100);
    env.gen.generateSameCharRandomPos();
    env.gen.generateSameCharRandomPos();
    env.run();
    
  end
endprogram