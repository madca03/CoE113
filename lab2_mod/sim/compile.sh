#!/usr/bin/env bash

java -jar $MARS_BIN/Mars4_5.jar a dump .text HexText instmem.txt dump .data HexText datamem.txt mc CompactDataAtZero ../asm/test.asm
java -jar $MARS_BIN/Mars4_5.jar dump .data HexText datamem_ans.txt mc CompactDataAtZero ../asm/test.asm

python parser.py datamem.txt datamem_parse.txt
python parser.py instmem.txt instmem_parse.txt
python parser.py datamem_ans.txt datamem_ans_parse.txt

#vcs ../memory/instmem.v ../memory/datamem.v ../memory/datamem_ans.v ../mapped/single_cycle_mips_mapped.v ../lib/saed90nm.v tb_proc.v -debug_pp -full64 +neg_tchk -R -l vcs.log
iverilog -o simv ../memory/instmem.v ../memory/datamem.v ../memory/datamem_ans.v ../mapped/single_cycle_mips_mapped.v ../lib/saed90nm.v tb_proc.v
./simv

#vcs instmem.v datamem.v datamem_ans.v single_cycle_mips_mapped.v saed90nm.v tb_proc.v -debug_pp -full64 +neg_tchk -R -l vcs.log
# iverilog -o simv instmem.v datamem.v datamem_ans.v single_cycle_mips_mapped.v saed90nm.v tb_proc.v
