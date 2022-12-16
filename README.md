# Hardware Verification Coursework

This is the homepage of the above-named module, which is offered to MSc and 4th-year MEng students at Imperial College London.

The module is run by Dr John Wickerson (software) and Professor Pete Harrod (hardware).

## <u> Overview </u>
</br>

The high level overview of the project is to verify 2 peripherals given according to its specification. The first peripheral is GPIO (General Purpose Input Output) and the second is a VGA (Video Graphics Array). The specificationd of both peripherals are both given by the PDF's [`AHB Peripherals Specification.pdf`](https://github.com/yv19/HardwareVerification/blob/main/AHB%20Peripherals%20Specification.pdf) and [`AHB Peripherals Presentation.pdf`](https://github.com/yv19/HardwareVerification/blob/main/AHB%20Peripherals%20Specification.pdf). Systemverilog alongside Jaspergold will be used to test both peripherals along with a multitude of verification techniques that will be mentioned in more detail in the Verification Plan and Verification Report.


## <u> Verification Plan + Report </u>

- The Verification Plan can be found [here]().
- The Verification Report can be found [here]().

## <u> Directory Structure </u>

</br>

```
.
├── README.md
└── AHB_peripherals_files/
    ├── do_files
    ├── output/
    │   ├── gpio
    │   └── vga
    ├── rtl/
    │   ├── AHB_BRAM/
    │   │   └── *
    │   ├── AHB_BUS/
    │   │   └── *
    │   ├── AHB_VGA/
    │   │   ├── Assertions/
    │   │   ├── CRT_DT/
    │   │   ├── DLS/
    │   │   ├── VGA_Top_Level_Helpers/
    │   │   └── *
    │   ├── AHB_GPIO/
    │   │   ├── Assertions/
    │   │   ├── CRT_DT/
    │   │   ├── DLS/
    │   │   ├── VGA_Top_Level_Helpers/
    │   │   └── *
    │   ├── CortexM0-DS/
    │   │   └── *
    │   └── AHBLITE_SYS.sv
    ├── src/
    │   └── *.s
    ├── tbench/
    │   └── ahblite_sys_tb.sv
    ├── ahb_*.sh
    ├── *_formal.tcl
    ├── code.hex
    └── readme.txt
```
## <u> Setup </u>

1. SSH into your respective college unix server (ssh -X your-college-name@ee-mill3.ee.ic.ac.uk) or login with your MobaXterm account.
2. Copy/Clone git repository to personal directory
3. cd into the `AHB_peripherals_files` folder
4. Type `source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh` to set the QuestaSim source for your terminal.
5. Type `source /usr/local/cadence/JASPER_2018.06.002/settings.sh` to set the JasperGold source for your terminal.

## <u> GPIO Testing </u>
</br>
This section will depict how to perform different tests on the GPIO peripheral. <b> Please perform the <u>Setup</u> section before moving onto this section. </b>

</br>

### **Unit Level Tests**
</br>

- Functions inside [generator.sv](https://github.com/yv19/HardwareVerification/blob/main/AHB_peripherals_files/rtl/AHB_GPIO/CRT_DT/generator.sv) inside the rtl directory for GPIO can be selected to be put onto the [gpio_test.sv](https://github.com/yv19/HardwareVerification/blob/main/AHB_peripherals_files/rtl/AHB_GPIO/CRT_DT/gpio_test.sv) file to be run by the testbench. This will add onto the output score generated by the file `gpio_test_score.txt` on the folder [scb](https://github.com/yv19/HardwareVerification/tree/main/AHB_peripherals_files/output/gpio/scb) in the directory output

- A list of function signitures for the GPIO Unit Level Tests are listed in [this (implement)]() file if in any case the more testcases are needed to be added.

- After putting the selected testcases inside the `gpio_test.sv` file, navigate to the `AHB_peripherals_files` directory. 

- Perform Unit Level Tests by typing `./ahb_gpio.sh` into the terminal

- This should generate a new `gpio_test_score.txt` output every time it is re-ran.

The seed is randomized between every run which means every time the test is re-ran unique inputs should be generated.


### **Formal Verification**
</br>

- Navigate to the `AHB_peripherals_files` directory

- Perform Formal Verification on the GPIO by typing `jg GPIO_formal.tcl` into the terminal. This should open up a new window with JasperGold.

- Right click any of the properties in the Property table and press `Prove Property` to attempt prove properties individually or `Prove Task` to attempt to prove all properties.

## <u> VGA Testing </u>

### **Unit Level Tests**
</br>
1. Generates valid packets to feed into DUT and Model
2. It instantiates "**transaction**" packets

### **Formal Verification**
</br>
1. Generates valid packets to feed into DUT and Model
2. It instantiates "**transaction**" packets

## <u> Integration Testing </u>