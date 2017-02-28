#!/usr/bin/env bash

java -jar $MARS_BIN/Mars4_5.jar a dump .text HexText instmem.txt dump .data HexText datamem.txt mc CompactDataAtZero ../asm/test.asm

python parser.py datamem.txt datamem_parse.txt
python parser.py instmem.txt instmem_parse.txt
python parser.py datamem_ans.txt datamem_ans_parse.txt

iverilog -o simv ../mapped/single_cycle_mips_mapped.v ../lib/saed90nm.v ../memory/instmem.v ../memory/datamem.v ../memory/datamem_ans.v tb_proc.v
./simv
