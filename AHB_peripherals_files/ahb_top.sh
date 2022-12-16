#!/bin/bash
set -e

rm -f ./output/vga/top/*

vlib work
vlog -work work +acc=blnr -noincr -timescale 1ns/1ps -f vc_files/ahblite_sys.vc
vopt -work work ahblite_sys_tb -o work_opt
vsim ahblite_sys_tb -do do_files/ahblite_sim.do -gui

# # vsim -coverage work_opt -gui\