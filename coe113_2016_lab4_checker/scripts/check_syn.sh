# Mapped files should be in check directory

#!/bin/bash
cd ../sim
#vcs ../check/mapped/*.v ./defines.h ./tb_pipelined_mips.v ./instmem.v ./datamem.v ../lib/saed90nm.v -full64 -debug_pp -R +neg_tchk +define+SDF -l vcs.log
iverilog -o simv datamem.v instmem.v tb_pipelined_mips.v ../mapped/pipelined_mips_mapped.v defines.h ../lib/saed90nm.v
./simv
