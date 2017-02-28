`timescale 1ns/1ps
module tb_mem;
  reg clk;
  reg nrst;
  reg data_wr;
  wire [31:0] data_addr;
  wire [31:0] data_mem;
  wire [31:0] data_fsm; 

  datamem UUT(
    .clk(clk),
    .data_wr(data_wr),
    .data_addr(data_addr),
    .data_in(data_fsm),
    .data_out(data_mem)
  );

  integer i;
  initial begin
   	#1;
		$display("\n\n");
    /* Display initial contents of memory */
    for (i=0;i<3;i=i+1) begin
      $display("%X%X%X%X",
        UUT.memory[(i*4)],
        UUT.memory[(i*4)+1],
        UUT.memory[(i*4)+2],
        UUT.memory[(i*4)+3]
        );
    end
		$display("\n\n");
   $finish;
  end
endmodule
