`include "generator.sv"

`define D_VGA_CLK_BLOCK vga_vif1.driver_cb

class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual vga_intf vga_vif1;
  
  //creating mailbox handle
  mailbox gen2driv;
  mailbox driv2mon;

  // HWDATA buffer
  logic [31:0] HWDATA_buffer;
  
  //constructor
  function new(virtual vga_intf vga_vif1, mailbox gen2driv, mailbox driv2mon);
    //getting the interface
    this.vga_vif1 = vga_vif1;
    //getting the mailbox handle from  environment 
    this.gen2driv = gen2driv;
    this.driv2mon = driv2mon;
  endfunction

  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(vga_vif1.HRESETn);
    $display("--------- [DRIVER] Reset Started ---------");
    `D_VGA_CLK_BLOCK.HADDR <= 0;
    `D_VGA_CLK_BLOCK.HWDATA <= 0;
    `D_VGA_CLK_BLOCK.HREADY <= 0;     
    `D_VGA_CLK_BLOCK.HWRITE <= 0;
    `D_VGA_CLK_BLOCK.HTRANS <= 0;
    `D_VGA_CLK_BLOCK.HSEL <= 0;

    HWDATA_buffer <= 0;
    wait(!vga_vif1.HRESETn);
    $display("--------- [DRIVER] Reset Ended---------");
  endtask
  
  //drive the transaction items to interface signals
  task main;
    forever begin
      automatic transaction trans;
      int cnt;
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      gen2driv.get(trans); // Get the transaction from the generator
      driv2mon.put(trans);
      repeat(trans.INPUTSIZE) begin
        @(posedge vga_vif1.HCLK); // Interface clock edge
        // Control
        `D_VGA_CLK_BLOCK.HADDR <= trans.HADDR[cnt];
        `D_VGA_CLK_BLOCK.HSEL <= trans.HSEL[cnt];
        `D_VGA_CLK_BLOCK.HWRITE <= trans.HWRITE[cnt];
        `D_VGA_CLK_BLOCK.HREADY <= trans.HREADY[cnt];
        `D_VGA_CLK_BLOCK.HTRANS <= trans.HTRANS[cnt];
        // Data
        `D_VGA_CLK_BLOCK.HWDATA <= HWDATA_buffer;
        // Buffer
        HWDATA_buffer <= trans.HWDATA[cnt];
        cnt++;
      end
      @(negedge vga_vif1.VSYNC);
      $display("-----------------------------------------");
      no_transactions++;

      clearVGA(trans);
    end
  endtask

  task clearVGA(transaction trans);
    // Delete all the characters by feeding in backspace
      for (int i = 0; i < trans.INPUTSIZE-1; i++) begin
        @(posedge vga_vif1.HCLK); // Interface clock edge
        // Control
        `D_VGA_CLK_BLOCK.HADDR <= 32'h50000000;
        `D_VGA_CLK_BLOCK.HSEL <= 1'b1;
        `D_VGA_CLK_BLOCK.HWRITE <= 1'b1;
        `D_VGA_CLK_BLOCK.HREADY <= 1'b1;
        `D_VGA_CLK_BLOCK.HTRANS <= 2'd2;
        // Data
        `D_VGA_CLK_BLOCK.HWDATA <= HWDATA_buffer;

        HWDATA_buffer <= 32'h08;
      end
      @(posedge vga_vif1.HCLK); // Interface clock edge
      `D_VGA_CLK_BLOCK.HSEL <= 0;
      `D_VGA_CLK_BLOCK.HWRITE <= 0;
  endtask

endclass