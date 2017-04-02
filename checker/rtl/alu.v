`timescale 1ns/1ps
`define WORD_WIDTH 32

module alu ( opA, opB, sel, res, z, neg );
	input [`WORD_WIDTH-1:0] opA;
	input [`WORD_WIDTH-1:0]	opB;
	input [1:0] sel;	
	output reg [31:0] res;
	output z;
	output neg;

	wire [`WORD_WIDTH-1:0] res_add;
	wire [`WORD_WIDTH-1:0] res_sub;
	wire cout;

	assign {cout, res_add} = {1'b0, opA} + {1'b0, opB};
	assign {cout, res_sub} = {1'b0, opA} + {1'b0, ~opB} + 1'b1;

	/* res output */
	always @ (*)
		case (sel)
			2'd0: res <= res_add;
			2'd1: res <= res_sub;			
		endcase

	/* zero flag */
	assign z = (res == 0) ? 1'b1 : 1'b0;

	/* negative number flag */
	assign neg = ((cout == 1'b1) && (res_sub[31] == 1'b1)) ? 1'b1 : 1'b0;

endmodule 
