# Doc on writing up Jaspergold TCL files: https://docviewer.xdocs.net/view.php

clear -all
analyze -clear
# Set the file to be compiled and analyzed
analyze -sv -f vc_files/GPIO_formal.vc
# Define the testbench to be the top level module
elaborate -top AHBGPIO

# Setup global clocks and resets on the testbench
clock ahbgpio_if.HCLK
reset -expression !(ahbgpio_if.HRESETn)

# Setup task
task -set <embedded>
set_proofgrid_max_jobs 4
set_proofgrid_max_local_jobs 4

# Example cover testcases
# cover -name test_cover_from_tcl {@(posedge clk) disable iff (!rst_n) done && ab == 10'd35}
