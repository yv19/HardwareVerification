`include "generator.sv"

`define DRIV_IF vga_vif.driver_cb
`define DRIV_IF_COPY vga_vif_copy.driver_cb

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual vga_intf vga_vif;
  virtual vga_intf vga_vif_copy;
  
  //creating mailbox handle
  mailbox gen2driv;
  mailbox driv2mon;

  // HWDATA buffer
  logic [31:0] HWDATA_buffer;
  
  //constructor
  function new(virtual vga_intf vga_vif, virtual vga_intf vga_vif_copy, mailbox gen2driv, mailbox driv2mon);
    //getting the interface
    this.vga_vif = vga_vif;
    this.vga_vif_copy = vga_vif_copy;
    //getting the mailbox handle from  environment 
    this.gen2driv = gen2driv;
    this.driv2mon = driv2mon;
  endfunction

  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(vga_vif.HRESETn);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.HADDR <= 0;
    `DRIV_IF.HWDATA <= 0;
    `DRIV_IF.HREADY <= 0;      
    `DRIV_IF.HWRITE <= 0;
    `DRIV_IF.HTRANS <= 0;
    `DRIV_IF.HSEL <= 0;

    `DRIV_IF_COPY.HADDR <= 0;
    `DRIV_IF_COPY.HWDATA <= 0;
    `DRIV_IF_COPY.HREADY <= 0;      
    `DRIV_IF_COPY.HWRITE <= 0;
    `DRIV_IF_COPY.HTRANS <= 0;
    `DRIV_IF_COPY.HSEL <= 0;

    HWDATA_buffer <= 0;
    wait(!vga_vif.HRESETn);
    $display("--------- [DRIVER] Reset Ended---------");
  endtask
  
  //drive the transaction items to interface signals
  task main;
    forever begin
      automatic transaction trans;
      gen2driv.get(trans); // Get the transaction from the generator
      driv2mon.put(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      for (int i = 0; i < trans.INPUTSIZE; i++) begin
        @(posedge vga_vif.HCLK); // Interface clock edge
        // Control
        `DRIV_IF.HADDR <= trans.HADDR[i];
        `DRIV_IF.HSEL <= trans.HSEL[i];
        `DRIV_IF.HWRITE <= trans.HWRITE[i];
        `DRIV_IF.HREADY <= trans.HREADY[i];
        `DRIV_IF.HTRANS <= trans.HTRANS[i];
        // Data
        `DRIV_IF.HWDATA <= HWDATA_buffer;

        // Control
        `DRIV_IF_COPY.HADDR <= trans.HADDR[i];
        `DRIV_IF_COPY.HSEL <= trans.HSEL[i];
        `DRIV_IF_COPY.HWRITE <= trans.HWRITE[i];
        `DRIV_IF_COPY.HREADY <= trans.HREADY[i];
        `DRIV_IF_COPY.HTRANS <= trans.HTRANS[i];
        // Data
        `DRIV_IF_COPY.HWDATA <= HWDATA_buffer;
        HWDATA_buffer <= trans.HWDATA[i];
      end
      @(negedge vga_vif.VSYNC);
      $display("-----------------------------------------");
      no_transactions++;

      clearVGABuffer(trans);
    end
  endtask

  task clearVGABuffer(transaction trans);
    // Delete all the characters by feeding in backspace
      for (int i = 0; i < trans.INPUTSIZE-1; i++) begin
        @(posedge vga_vif.HCLK); // Interface clock edge
        // Control
        `DRIV_IF.HADDR <= 32'h50000000;
        `DRIV_IF.HSEL <= 1'b1;
        `DRIV_IF.HWRITE <= 1'b1;
        `DRIV_IF.HREADY <= 1'b1;
        `DRIV_IF.HTRANS <= 2'd2;
        // Data
        `DRIV_IF.HWDATA <= HWDATA_buffer;

        // Control
        `DRIV_IF_COPY.HADDR <= 32'h50000000;
        `DRIV_IF_COPY.HSEL <= 1'b1;
        `DRIV_IF_COPY.HWRITE <= 1'b1;
        `DRIV_IF_COPY.HREADY <= 1'b1;
        `DRIV_IF_COPY.HTRANS <= 2'd2;
        // Data
        `DRIV_IF_COPY.HWDATA <= HWDATA_buffer;

        HWDATA_buffer <= 32'h08;
      end
      @(posedge vga_vif.HCLK); // Interface clock edge
      `DRIV_IF.HSEL <= 0;
      `DRIV_IF.HWRITE <= 0;
      `DRIV_IF_COPY.HSEL <= 0;
      `DRIV_IF_COPY.HWRITE <= 0;
  endtask

endclass