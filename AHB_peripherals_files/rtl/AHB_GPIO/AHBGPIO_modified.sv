//////////////////////////////////////////////////////////////////////////////////
//END USER LICENCE AGREEMENT                                                    //
//                                                                              //
//Copyright (c) 2012, ARM All rights reserved.                                  //
//                                                                              //
//THIS END USER LICENCE AGREEMENT (�LICENCE�) IS A LEGAL AGREEMENT BETWEEN      //
//YOU AND ARM LIMITED ("ARM") FOR THE USE OF THE SOFTWARE EXAMPLE ACCOMPANYING  //
//THIS LICENCE. ARM IS ONLY WILLING TO LICENSE THE SOFTWARE EXAMPLE TO YOU ON   //
//CONDITION THAT YOU ACCEPT ALL OF THE TERMS IN THIS LICENCE. BY INSTALLING OR  //
//OTHERWISE USING OR COPYING THE SOFTWARE EXAMPLE YOU INDICATE THAT YOU AGREE   //
//TO BE BOUND BY ALL OF THE TERMS OF THIS LICENCE. IF YOU DO NOT AGREE TO THE   //
//TERMS OF THIS LICENCE, ARM IS UNWILLING TO LICENSE THE SOFTWARE EXAMPLE TO    //
//YOU AND YOU MAY NOT INSTALL, USE OR COPY THE SOFTWARE EXAMPLE.                //
//                                                                              //
//ARM hereby grants to you, subject to the terms and conditions of this Licence,//
//a non-exclusive, worldwide, non-transferable, copyright licence only to       //
//redistribute and use in source and binary forms, with or without modification,//
//for academic purposes provided the following conditions are met:              //
//a) Redistributions of source code must retain the above copyright notice, this//
//list of conditions and the following disclaimer.                              //
//b) Redistributions in binary form must reproduce the above copyright notice,  //
//this list of conditions and the following disclaimer in the documentation     //
//and/or other materials provided with the distribution.                        //
//                                                                              //
//THIS SOFTWARE EXAMPLE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ARM     //
//EXPRESSLY DISCLAIMS ANY AND ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING     //
//WITHOUT LIMITATION WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR //
//PURPOSE, WITH RESPECT TO THIS SOFTWARE EXAMPLE. IN NO EVENT SHALL ARM BE LIABLE/
//FOR ANY DIRECT, INDIRECT, INCIDENTAL, PUNITIVE, OR CONSEQUENTIAL DAMAGES OF ANY/
//KIND WHATSOEVER WITH RESPECT TO THE SOFTWARE EXAMPLE. ARM SHALL NOT BE LIABLE //
//FOR ANY CLAIMS, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, //
//TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE    //
//EXAMPLE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE EXAMPLE. FOR THE AVOIDANCE/
// OF DOUBT, NO PATENT LICENSES ARE BEING LICENSED UNDER THIS LICENSE AGREEMENT.//
//////////////////////////////////////////////////////////////////////////////////


module AHBGPIO(
  input wire HCLK,
  input wire HRESETn,
  input wire [31:0] HADDR,
  input wire [1:0] HTRANS,
  input wire [31:0] HWDATA,
  input wire HWRITE,
  input wire HSEL,
  input wire HREADY,
  input wire [16:0] GPIOIN,
  input wire PARITYSEL,
  
	
	//Output
  output wire HREADYOUT,
  output wire [31:0] HRDATA,
  output wire [16:0] GPIOOUT,
  output wire PARITYERR
  
  );

  wire PARITY_OUT = (^gpio_dataout) ^ PARITYSEL;
  assign PARITYERR = (^GPIOIN) ^ PARITYSEL ^ GPIOIN[16];

  localparam [31:0] gpio_data_addr = 32'h53000000;
  localparam [31:0] gpio_dir_addr = 32'h53000004;
  
  reg [15:0] gpio_dataout;
  reg [15:0] gpio_datain;
  reg [15:0] gpio_dir;
  reg [31:0] last_HADDR;
  reg [1:0] last_HTRANS;
  reg last_HWRITE;
  reg last_HSEL;
  reg last_HREADY;
  
  integer i;
  
  assign HREADYOUT = 1'b1;
  
// Set Registers from address phase  
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      last_HADDR <= 16'h0000;
      last_HTRANS <= 16'h0000;
      last_HWRITE <= 16'h0000;
      last_HSEL <= 16'h0000;
      last_HREADY <= 16'h0000;
    end
    else
    begin
      last_HREADY <= HREADY;
      last_HADDR <= HADDR;
      last_HTRANS <= HTRANS;
      last_HWRITE <= HWRITE;
      last_HSEL <= HSEL;
    end
  end

  // Update in/out switch
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_dir <= 16'h0000;
    end
    else if ((last_HADDR == gpio_dir_addr) & last_HSEL & last_HWRITE & last_HTRANS[1] & last_HREADY)
      gpio_dir <= HWDATA[15:0];
  end

  // Update output value
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_dataout <= 16'h0000;
    end
    else if ((gpio_dir == 16'h0001) & (last_HADDR == gpio_data_addr) & last_HSEL & last_HWRITE & last_HREADY & last_HTRANS[1])
      // Parity Generation
      gpio_dataout <= HWDATA[15:0];
  end
  
  // Update input value
  always @(posedge HCLK, negedge HRESETn)
  begin
    if(!HRESETn)
    begin
      gpio_datain <= 16'h0000;
    end
    else if (gpio_dir == 16'h0000)
      gpio_datain <= GPIOIN[15:0];
    else if (gpio_dir == 16'h0001)
      gpio_datain <= GPIOOUT[15:0];
  end
         
  assign HRDATA[15:0] = gpio_datain;
  assign GPIOOUT = {PARITY_OUT, gpio_dataout};
endmodule
