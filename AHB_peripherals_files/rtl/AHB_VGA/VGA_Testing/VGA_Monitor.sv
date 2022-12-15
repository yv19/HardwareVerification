module VGA_Monitor_test(
    vga_intf.TEMP_MONITOR ahbvga_if
);

int file;
int file2;
int counter;

logic clk_div;

always @(posedge ahbvga_if.HCLK or negedge ahbvga_if.HRESETn)
begin
    if (!ahbvga_if.HRESETn)
      clk_div = 1'b0;
    else
      clk_div=~clk_div;
end

initial begin
    counter = 0;
end

always @(posedge clk_div) begin
    if (file)
    begin
        if (ahbvga_if.RGB == 8'h1c)
            begin
                $fwrite(file, "%s", "#");
            end
        else if (ahbvga_if.RGB == 0)
            begin
                $fwrite(file, "%s", " ");
            end
        else
            begin
                $fwrite(file, "%s", "X");
            end
    end
end

always @(negedge ahbvga_if.HSYNC)
begin
    if (file)
    begin
        $fwrite(file, "%s", "\n");
    end
end

always @(negedge ahbvga_if.VSYNC)
begin
    $display("counter is %i", counter);
    file2 = $fopen($sformatf("./output/vga/mon/monitor_vga_%d.txt", counter), "w");
    counter++;
    if (file)
        $fclose(file);
    file = file2;
end

endmodule