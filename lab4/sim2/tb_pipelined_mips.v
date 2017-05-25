`timescale 1ns/1ps
//`define CLK_PERIOD 20
`include "defines.h"
`define TIMEOUT 9 
`define WATCHDOG 600
module tb_pipelined_mips;
    reg clk,rst_n;
    wire [31:0] inst_addr,inst;
    wire [31:0] data_addr,data_in,data_out;
    wire data_wr;
    wire [31:0] pc_if,pc_id,pc_exe,pc_mem,pc_wb;

    assign pc_if = inst_addr;
    pipelined_mips UUT(
        .clk(clk),
        .rst_n(rst_n),
        .inst_addr(inst_addr),
        .inst(inst),
        .data_addr(data_addr),
        .data_in(data_in),
        .data_out(data_out),
        .data_wr(data_wr)//,
        //debug
        //.pc_id(pc_id),
        //.pc_exe(pc_exe),
        //.pc_mem(pc_mem),
        //.pc_wb(pc_wb)
    );

    instmem INSTMEM(
        .clk(clk),
        .inst_addr(inst_addr),
        .inst(inst)
    );

    datamem DATAMEM(
        .clk(clk),
        .data_addr(data_addr),
        .data_wr(data_wr),
        .data_in(data_in),
        .data_out(data_out)
    );

    always begin
        #(`CLK_PERIOD/2.0) clk = ~clk;
    end

    integer nop_count, watch_count, i, j, correct;
    integer ldst,add,sub,slt,addi,slti,beq,bne,jump,jal,jr;
    reg [31:0] ref [0:127];
    reg [31:0] res;
    initial begin
        //$vcdplusfile("tb_pipelined_mips.vpd");
        //$vcdpluson;
        $dumpfile("tb_pipelined_mips.vcd");
        $dumpvars(0,tb_pipelined_mips);

        //init
        clk = 0;
        rst_n = 0;
        nop_count = 0;
        watch_count = 0;

        #(`CLK_PERIOD*10);
        #(`CLK_PERIOD*0.8);
        rst_n = 1'b1;

        //start
        while((nop_count < `TIMEOUT)&&(watch_count < `WATCHDOG))begin
            #(`CLK_PERIOD);
            if (inst == 32'd0)
                nop_count = nop_count + 1;
            else
                nop_count = 0;
            watch_count = watch_count + 1;
        end

        ldst = 0;
        add = 0;
        sub = 0;
        slt = 0;
        addi = 0;
        slti = 0;
        beq = 0;
        bne = 0;
        jump = 0;
        jal = 0;
        jr = 0;
        correct = 0;
        j = 0;

        //display mem
        $display("\n\n    DATAMEM   MEMREF       COMPARE      REGFILE");
        for (i=0; i<60; i=i+1) begin
            res = {DATAMEM.memory[(i*4)],
                   DATAMEM.memory[(i*4)+1],
                   DATAMEM.memory[(i*4)+2],
                   DATAMEM.memory[(i*4)+3]};
            case(i)
                3,4,6:
                    if(res == ref[i]) begin
                        ldst = ldst + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 3; 
                    end
                7,8,9,10:
                    if(res == ref[i]) begin
                        add = add + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 4; 
                    end
                11,12,13,14,27,49,50,51:
                    if(res == ref[i]) begin
                        beq = beq + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 5; 
                    end
                15,16,17,18:
                    if(res == ref[i]) begin
                        sub = sub + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 6; 
                    end
                19,20:
                    if(res == ref[i]) begin
                        slt = slt + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 7; 
                    end
                21,22,23:
                    if(res == ref[i]) begin
                        addi = addi + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 8; 
                    end
                24,25,26:
                    if(res == ref[i]) begin
                        slti = slti + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 9; 
                    end
                28,29,30,31,32,52,53,54,55,56:
                    if (res == ref[i]) begin
                        bne = bne + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 10; 
                    end
                33,34,35,36,37:
                    if (res == ref[i]) begin
                        jump = jump + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 11; 
                    end
                40,41,42,43,44:
                    if (res == ref[i]) begin
                        jal = jal + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 12; 
                    end
                39,45,46,47,48:
                    if (res == ref[i]) begin
                        jr = jr + 1;
                        correct = 1;
                    end
                    else begin
                        correct = 13; 
                    end
                default: correct = 2;
            endcase
            $display("%02d: %X%X%X%X  %X   %s\t%02d: %08x", i,
            DATAMEM.memory[(i*4)],
            DATAMEM.memory[(i*4)+1],
            DATAMEM.memory[(i*4)+2],
            DATAMEM.memory[(i*4)+3],
            ref[i],
            (correct==0) ? "INCORRECT":
            (correct==1) ? "CORRECT":
            (correct==2) ? "---":
            (correct==3) ? "ERR_LWSW":
            (correct==4) ? "ERR_ADD":
            (correct==5) ? "ERR_BEQ":
            (correct==6) ? "ERR_SUB":
            (correct==7) ? "ERR_SLT":
            (correct==8) ? "ERR_ADDI":
            (correct==9) ? "ERR_SLTI":
            (correct==10) ? "ERR_BNE":
            (correct==11) ? "ERR_JUMP":
            (correct==12) ? "ERR_JAL":
            (correct==13) ? "ERR_JR": "---",
            (j<32)?j:0, (j<32)?UUT.regFile[j]:0
            ); 
            j = j + 1;
        end
        $display("\n=============== RESULTS ================");
        $display("\tLW/SW:\t%s - %0d / 3", (ldst==3)?"PASSED":"FAILED", ldst);
        $display("\tADD:\t%s - %0d / 4\t", (add==4)?"PASSED":"FAILED", add);
        $display("\tSUB:\t%s - %0d / 4\t", (sub==4)?"PASSED":"FAILED", sub);
        $display("\tSLT:\t%s - %0d / 2\t", (slt==2)?"PASSED":"FAILED", slt);
        $display("\tADDI:\t%s - %0d / 3\t", (addi==3)?"PASSED":"FAILED", addi);
        $display("\tSLTI:\t%s - %0d / 3\t", (slti==3)?"PASSED":"FAILED", slti);
        $display("\tBEQ:\t%s - %0d / 8\t", (beq==8)?"PASSED":"FAILED", beq);
        $display("\tBNE:\t%s - %0d / 10\t", (bne==10)?"PASSED":"FAILED", bne);
        $display("\tJUMP:\t%s - %0d / 5\t", (jump==5)?"PASSED":"FAILED", jump);
        $display("\tJAL:\t%s - %0d / 5\t", (jal==5)?"PASSED":"FAILED", jal);
        $display("\tJR:\t%s - %0d / 5\t", (jr==5)?"PASSED":"FAILED", jr);
        $display("========================================");
        //display regfile
        /*$display("REGFILE");
        for (i=0; i<32; i=i+1) begin
            $display("%02d: %x", i, UUT.regFile[i]);/*
            $display("R1: %x",UUT.regFile[1]);
            $display("R2: %x",UUT.regFile[2]);
            $display("R3: %x",UUT.regFile[3]);
            $display("R4: %x",UUT.regFile[4]);
            $display("R5: %x",UUT.regFile[5]);
            $display("R6: %x",UUT.regFile[6]);
            $display("R7: %x",UUT.regFile[7]);
            $display("R8: %x",UUT.regFile[8]);
            $display("R9: %x",UUT.regFile[9]);
            $display("31: %x",UUT.regFile[31]);
        end*/
        $finish;
    end

    initial begin
        $readmemh("memref.word",ref);
    end

    `ifdef SDF
    initial begin
        $sdf_annotate("mapped/pipelined_mips_mapped.sdf",pipelined_mips);
    end
    `endif
endmodule