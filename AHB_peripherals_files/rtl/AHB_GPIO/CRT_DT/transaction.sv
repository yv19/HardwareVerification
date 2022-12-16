`ifndef GPIO_TRANSACTION
`define GPIO_TRANSACTION

class transaction;
    //declaring the transaction items

    rand logic [31:0] HADDR;
    rand logic [1:0] HTRANS;
    rand logic [31:0] HWDATA;
    rand logic HWRITE;
    rand logic HSEL;
    rand logic HREADY;
    rand logic [16:0] GPIOIN;
    rand logic PARITYSEL;

    // Outputs
    logic HREADYOUT;
    logic [31:0] HRDATA;
    logic [16:0] GPIOOUT;
    logic PARITYERR;

    int testType;

    constraint ahblite_valid_signals {
        HTRANS == 2'd2;
        HWRITE == 1'b1;
        HSEL == 1'b1;
        HREADY == 1'b1;
    }

    constraint HWDATA_upper_bound {
        HWDATA <= 16'hffff;
    }

    constraint min_GPIO_constraint {
        HSEL == 1'b1;
    }
  
endclass

`endif