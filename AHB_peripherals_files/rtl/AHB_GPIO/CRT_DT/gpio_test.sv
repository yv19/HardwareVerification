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
    env.gen.writeInputToDirReg();
    env.run();
    
  end
endprogram