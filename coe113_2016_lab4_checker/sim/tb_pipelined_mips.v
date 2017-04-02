`timescale 1ns/1ps
//`define CLK_PERIOD 20
`include "defines.h"
`define TIMEOUT 9
`define WATCHDOG 500
module tb_pipelined_mips;

  reg clk,rst_n;
  wire [31:0] inst_addr,inst;
  wire [31:0] data_addr,data_in,data_out;
  wire data_wr;
  wire [31:0] pc_if,pc_id,pc_exe,pc_mem,pc_wb;

  assign pc_if = inst_addr;
  single_cycle_mips UUT(
    .clk(clk),
    .rst_n(rst_n),
    .inst_addr(inst_addr),
    .inst(inst),
    .data_addr(data_addr),
    .data_in(data_in),
    .data_out(data_out),
    .data_wr(data_wr)//,
    //debug
    // .pc_id(pc_id),
    // .pc_exe(pc_exe),
    // .pc_mem(pc_mem),
    // .pc_wb(pc_wb)
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

  integer nop_count,watch_count,i;
  integer ldst,add,sub,slt,beq,bne;
  reg [31:0] ref [0:127];
  reg [31:0] res;
  initial begin
    // $vcdplusfile("tb_pipelined_mips.vpd");
    // $vcdpluson;
    $dumpfile("tb_pipelined_mips.vcd");
    $dumpvars;

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
    beq = 0;
    bne = 0;

    //display mem
    for (i=0; i<27; i=i+1) begin
      $display("%X%X%X%X",
        DATAMEM.memory[(i*4)],
        DATAMEM.memory[(i*4)+1],
        DATAMEM.memory[(i*4)+2],
        DATAMEM.memory[(i*4)+3],
        );
      res = {DATAMEM.memory[(i*4)],
             DATAMEM.memory[(i*4)+1],
             DATAMEM.memory[(i*4)+2],
             DATAMEM.memory[(i*4)+3]};
      case(i)
        3,4,6:
          if (res == ref[i]) ldst = ldst + 1;
        7,8,9,10:
          if (res == ref[i]) add = add + 1;
        11,12,13,14,21:
          if (res == ref[i]) beq = beq + 1;
        15,16,17,18:
          if (res == ref[i]) sub = sub + 1;
        19,20:
          if (res == ref[i]) slt = slt + 1;
        22,23,24,25,26:
          if (res == ref[i]) bne = bne + 1;
      endcase
    end

    $display("Load/Store: %d / 3",ldst);
    $display("ADD: %d / 4",add);
    $display("SUB: %d / 4",sub);
    $display("SLT: %d / 2",slt);
    $display("BEQ: %d / 5",beq);
    $display("BNE: %d / 5",bne);

    //display regfile
    /*$display("R1: %x",UUT.STAGE_2.RF.elem01);
    $display("R2: %x",UUT.STAGE_2.RF.elem02);
    $display("R3: %x",UUT.STAGE_2.RF.elem03);
    $display("R4: %d",UUT.STAGE_2.RF.elem04);
    $display("R5: %d",UUT.STAGE_2.RF.elem05);
    $display("R6: %d",UUT.STAGE_2.RF.elem06);
    */

    $finish;
  end

  initial begin
    $readmemh("./ref.txt",ref);
  end

`ifdef SDF
  initial begin
    $sdf_annotate("../check/mapped/pipelined_mips_mapped.sdf",pipelined_mips);
  end
`endif

endmodule
