#!/usr/bin/env bash

java -jar $MARS_BIN/Mars4_5.jar a dump .text HexText instmem.txt dump .data HexText datamem.txt mc CompactDataAtZero ../asm/test.asm
java -jar $MARS_BIN/Mars4_5.jar dump .data HexText datamem_ans.txt mc CompactDataAtZero ../asm/test.asm

#java -jar ~/Downloads/Mars4_5.jar a dump .text HexText instmem.txt dump .data HexText datamem.txt mc CompactDataAtZero ../asm/test.asm
#java -jar ~/Downloads/Mars4_5.jar dump .data HexText datamem_ans.txt mc CompactDataAtZero ../asm/test.asm

python parser.py datamem.txt datamem_parse.txt
python parser.py instmem.txt instmem_parse.txt
python parser.py datamem_ans.txt datamem_ans_parse.txt

vcs ../rtl/instmem.v ../rtl/datamem.v ../rtl/datamem_ans.v ../rtl/single_cycle_mips.v ../rtl/rf.v ../rtl/alu.v tb_single_cycle_mips.v -debug_pp -full64 +neg_tchk -R -l vcs.log
#iverilog -o simv ../rtl/instmem.v ../rtl/datamem.v ../rtl/datamem_ans.v ../rtl/single_cycle_mips.v ../rtl/rf.v ../rtl/alu.v tb_single_cycle_mips.v
#vcs ../rtl/instmem.v ../rtl/datamem.v ../rtl/datamem_ans.v ../mapped/single_cycle_mips_mapped.v ../lib/saed90nm.v tb_single_cycle_mips.v -debug_pp -full64 +neg_tchk -R -l vcs.log
#iverilog -o simv ../lib/saed90nm.v ../rtl/instmem.v ../rtl/datamem.v ../rtl/datamem_ans.v ../mapped/single_cycle_mips_mapped.v tb_single_cycle_mips.v
./simv
