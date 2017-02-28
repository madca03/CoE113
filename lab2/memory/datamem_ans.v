`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 32
module datamem_ans(
  );

  reg [`MEM_WIDTH-1:0] memory [0:`MEM_DEPTH-1];

  initial begin
    $readmemh("datamem_ans_parse.txt",memory);
  end
endmodule
