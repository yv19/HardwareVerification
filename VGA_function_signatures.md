```verilog
// Task used to generate a sequence of inputs with a set of random control
// signals inputs to be fed into the VGA.
task randomizeControlSignals(int number_of_inputs); // Test type 0

// Task used to be able to output a specific character on the screen.
// Achieved by padding the character with " " until the designated character
// is reached
task generateRandomCharAtPos(int x, int y); // Test type 1

// Task used to generate a random character at a particular location
// on the screen
task generateRandomCharRandomPos(); // Test type 2

// Task used to generate a random character at a random location on
// the screen 
task generateRandomCharSamePos(); // Test type 3

// Task used to generate a full frame of outputs with random characters
task fullFrameTest(); // Test type 4

// Task used to generate the same character in a random location on
// the screen
task generateSameCharRandomPos(); // Test type 5 

// Task used to generate a blank frame
task outputBlank(); // Test type 6