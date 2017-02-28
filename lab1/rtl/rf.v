`timescale 1ns/1ps
module rf(
	input clk,
	input nrst,
	input [4:0] rd_addrA,
	input [4:0] rd_addrB,
	output [31:0] rd_dataA,
	output [31:0] rd_dataB,
	input wr_en,
	input [4:0] wr_addr,
	input [31:0] wr_data
);

	reg [31:0] regf [31:0];
	
	always @ (posedge clk, negedge nrst)
		if (!nrst) begin
			regf[0] <= 32'd0;
			regf[1] <= 32'd0;
			regf[2] <= 32'd0;
			regf[3] <= 32'd0;
			regf[4] <= 32'd0;
			regf[5] <= 32'd0;
			regf[6] <= 32'd0;
			regf[7] <= 32'd0;
			regf[8] <= 32'd0;
			regf[9] <= 32'd0;
			regf[10] <= 32'd0;
			regf[11] <= 32'd0;
			regf[12] <= 32'd0;
			regf[13] <= 32'd0;
			regf[14] <= 32'd0;
			regf[15] <= 32'd0;
			regf[16] <= 32'd0;
			regf[17] <= 32'd0;
			regf[18] <= 32'd0;
			regf[19] <= 32'd0;
			regf[20] <= 32'd0;
			regf[21] <= 32'd0;
			regf[22] <= 32'd0;
			regf[23] <= 32'd0;
			regf[24] <= 32'd0;
			regf[25] <= 32'd0;
			regf[26] <= 32'd0;
			regf[27] <= 32'd0;
			regf[28] <= 32'd0;
			regf[29] <= 32'd0;
			regf[30] <= 32'd0;
			regf[31] <= 32'd0;
		end
		else
			if (wr_en)
				case (wr_addr)
					5'd0: regf[wr_addr] <= 0;
					default: regf[wr_addr] <= wr_data;
				endcase

	assign rd_dataA = regf[rd_addrA];
	assign rd_dataB = regf[rd_addrB];

endmodule
