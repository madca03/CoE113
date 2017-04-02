`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 32
module instmem(
  inst_addr,
  inst
  );
  input [`WORD_WIDTH-1:0] inst_addr;
  output [`WORD_WIDTH-1:0] inst;

  reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

  initial begin
    //$readmemh("instmem.txt",memory);
    //$readmemh("./assembler/instmem.txt",memory);
    $readmemh("../asm/source1.byte",memory);
  end

  //Read port
  reg [`WORD_WIDTH-1:0] inst;

  always@(*)
    inst <= {memory[inst_addr],
             memory[inst_addr+1],
             memory[inst_addr+2],
             memory[inst_addr+3]};

endmodule
