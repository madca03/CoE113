#!/bin/bash
cd ../sim
# vcs -f ../scripts/dep_rtl.f -full64 -debug_pp -R
iverilog -o simv ../sim/instmem.v ../sim/datamem.v ../rtl/single_cycle_mips.v ../rtl/rf.v ../rtl/alu.v ../sim/tb_single_cycle_mips.v
iverilog -o simv tb_single_cycle_mips.v datamem.v instmem.v ../rtl/single_cycle_mips.v ../rtl/rf.v ../rtl/alu.v
