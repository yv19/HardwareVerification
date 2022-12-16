module VGA_Monitor_top(
    input logic HCLK,
    input logic HRESETn,
    input logic HSYNC,
    input logic VSYNC,
    input logic [7:0] RGB
);

logic clk_div;
int counter;
int file;

always @(posedge HCLK or negedge HRESETn)
begin
    if (!HRESETn)
      clk_div = 1'b0;
    else
      clk_div=~clk_div;
end

initial begin
    counter = 0;
end

always @(posedge clk_div) begin
    if (counter == 2)
    begin
        if (RGB == 8'h1c)
            begin
                $fwrite(file, "%s", "#");
            end
        else if (RGB == 0)
            begin
                $fwrite(file, "%s", " ");
            end
        else
            begin
                $fwrite(file, "%s", "X");
            end
    end
end

always @(negedge HSYNC)
begin
    if (counter == 2)
    begin
        $fwrite(file, "%s", "\n");
    end
end

always @(negedge VSYNC)
begin
    if (counter < 1) begin
        // file = $fopen($sformatf("./output/vga/top/monitor_vga.txt"), "w");
        counter++;
    end
    else if (counter == 1) begin
        $display("Opening File Buffer");
        counter++;
        file = $fopen($sformatf("./output/vga/top/monitor_vga.txt"), "w");
    end
    else begin
        if (counter == 2) begin
            $display("Finished writing frame. Closing File Buffer");
            $fclose(file); 
            counter++;
        end
    end
end

endmodule