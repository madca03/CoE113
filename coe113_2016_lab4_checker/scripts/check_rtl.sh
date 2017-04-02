# RTL files should be in check directory
#!/bin/bash

cd ../sim
# vcs ../check/*.v ./defines.h ./tb_pipelined_mips.v datamem.v instmem.v -full64 -debug_pp -R -l vcs.log
iverilog -o simv ../rtl/single_cycle_mips.v ../rtl/alu.v ../rtl/rf.v ./datamem.v ./instmem.v ./tb_pipelined_mips.v
