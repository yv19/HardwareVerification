#!/bin/bash
set -e

vlib work
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps -f ahblite_sys.vc
vopt -work work ahblite_sys_tb -o work_opt
vsim ahblite_sys_tb -do vga_sim.do -gui

# # vsim -coverage work_opt -gui\