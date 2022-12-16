```verilog
// Task used to Generate a random data to write to attempt to write 
// to the gpio_dataout register.
// Will not update gpio_dataout unless the internal direction register
// of GPIO is already set to output
task writeToDataReg(); // Test type 0

// Task used to set the direction register (gpio_dir) of the GPIO to output
task writeOutputToDirReg(); // Test type 1

// Task used to set the direction register (gpio_dir) of the GPIO to input
task writeInputToDirReg(); // Test type 2

// A complete randomizer function. Will generate a mix of valid/invalid inputs.
// Good for testing completely random signals.
task randomizeInput(); // Test type 3