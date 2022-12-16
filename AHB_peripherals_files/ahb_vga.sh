#!/bin/bash
set -e

rm -f ./output/vga/scb/*

vlib work
vlog  -work work +acc=blnr +cover -noincr -timescale 1ns/1ps -f vc_files/VGA_top.vc
vopt -work work tbench_top -o work_opt
vsim -coverage work_opt -do do_files/vga_sim.do -sv_seed random -gui 

# # vsim -coverage work_opt -gui\