`ifndef TRANSACTION
`define TRANSACTION

class position;
    rand int x, y;
    constraint pos_within_bounds {
        x <= 29;
        x >= 0;
        y >= 0;
        y <= 29;
    }
endclass

class transaction;

    // Inputs
    rand logic [31:0] HADDR [900];
    rand logic [31:0] HWDATA [900];
    rand logic HREADY [900];
    rand logic HWRITE [900];
    rand logic [1:0] HTRANS [900];
    rand logic HSEL [900];

    int testType;
    int INPUTSIZE;

    // Outputs
    logic frame [480][240];

    // This is so that the ahblite signals are random however biased more towards valid inputs
    constraint ahblite_random_signals {
        foreach (HADDR[i]) {
            HADDR[i] dist {
                [32'h0000000:32'hffffffff] :/ 10, // Give weighting to each element in the range with 10/(range size)
                [32'h50000000:32'h50ffffff] :/ 20,
                32'h50000000 :/ 50
            };
            HTRANS[i] dist {
                [2'd0:2'd1] :/ 10,
                2'd2 :/ 20
            };
        }
    }

    constraint ahblite_valid_signals {
        foreach (HADDR[i]) {
            HTRANS[i] == 2'd2;
            HWRITE[i] == 1'b1;
            HSEL[i] == 1'b1;
            HREADY[i] == 1'b1;
            HADDR[i] == 32'h50000000;
        }
    }

    constraint same_c {
        foreach (HADDR[i]) {
            HWDATA[i] == 32'h45;
        }
    }

    constraint random_c {
        foreach (HADDR[i]) {
            HWDATA[i] <= 32'h50;
            HWDATA[i] >= 32'h45;
        }
    }

  
endclass

`endif