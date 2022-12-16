`include "environment.sv"
program test(gpio_intf intf);

  // DO NOT SET INPUTSIZE > 898
  //declaring environment instance
  environment env;
  
  initial begin
    env = new(intf);
    // Generate inputs
    env.gen.writeToDataReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeToDataReg();
    env.gen.writeToDataReg();
    env.gen.writeToDataReg();
    env.gen.writeInputToDirReg();
    env.gen.writeInputToDirReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeInputToDirReg();
    env.gen.randomizeInput();
    env.gen.randomizeInput();
    env.gen.randomizeInput();
    env.gen.writeToDataReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeToDataReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeInputToDirReg();
    env.gen.writeOutputToDirReg();
    env.gen.writeToDataReg();
    env.gen.randomizeInput();
    env.gen.randomizeInput();
    env.gen.randomizeInput();
    env.gen.randomizeInput();
    env.run();
    
  end
endprogram