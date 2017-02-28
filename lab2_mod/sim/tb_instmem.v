`timescale 1ns/1ps
module tb_instmem;
  reg [31:0] inst_addr;
  wire [31:0] inst;

	instmem UUT(.inst_addr(inst_addr), 
		.inst(inst));

	integer i;
	initial begin
		#1;
		$display("\n\n");
		for(i=0; i<2; i=i+1) begin
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
