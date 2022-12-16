# Hardware Verification Coursework

This is the homepage of the above-named module, which is offered to MSc and 4th-year MEng students at Imperial College London.

The module is run by Dr John Wickerson (software) and Professor Pete Harrod (hardware).

## <u> Overview </u>
</br>

The high level overview of the project is to verify 2 peripherals given according to its specification. The first peripheral is GPIO (General Purpose Input Output) and the second is a VGA (Video Graphics Array). The specificationd of both peripherals are both given by the PDF's [`AHB Peripherals Specification.pdf`](https://github.com/yv19/HardwareVerification/blob/main/AHB%20Peripherals%20Specification.pdf) and [`AHB Peripherals Presentation.pdf`](https://github.com/yv19/HardwareVerification/blob/main/AHB%20Peripherals%20Specification.pdf). Systemverilog alongside Jaspergold will be used to test both peripherals along with a multitude of verification techniques that will be mentioned in more detail in the Verification Plan and Verification Report.

</br>

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
    │   │   └── *
    │   ├── AHB_GPIO/
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

    1. SSH into your respective college unix server (ssh -X your-college-name@ee-mill3.ee.ic.ac.uk) or login to your MobaXterm account.
    2. Copy/Clone git repository to personal directory
    3. cd into the `AHB_peripherals_files` folder
    4. Type `source /usr/local/mentor/QUESTA-CORE-PRIME_10.7c/settings.sh` to set the QuestaSim source for your terminal.
    5. Type `source /usr/local/cadence/JASPER_2018.06.002/settings.sh` to set the JasperGold source for your terminal.

## <u> GPIO Testing </u>
</br>
<b> This section will depict how to perform different tests on the GPIO peripheral. </b>

</br>

- **Unit Level Tests**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets

- **Formal Verification**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets

- **Top Level Test**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets

## <u> VGA Testing </u>

- **Unit Level Tests**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets

- **Formal Verification**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets

- **Top Level Test**
    1. Generates valid packets to feed into DUT and Model
    2. It instantiates "**transaction**" packets
