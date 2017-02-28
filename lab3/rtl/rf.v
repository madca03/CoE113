`timescale 1ns/1ps
`define MEM_DEPTH  32
`define MEM_WIDTH  32
`define WORD_WIDTH 32

module rf(
	input clk,
	input rst_n,
	input [4:0] rd_addrA,
	input [4:0] rd_addrB,
	output [`WORD_WIDTH-1:0] rd_dataA,
	output [`WORD_WIDTH-1:0] rd_dataB,
	input wr_en,
	input [4:0] wr_addr,
	input [`WORD_WIDTH-1:0] wr_data
);

	reg [`MEM_WIDTH-1:0] regf [`MEM_DEPTH-1:0];
	
	wire [31:0] reg1;
	wire [31:0] reg2;
	wire [31:0] reg3;
	wire [31:0] reg4;
	wire [31:0] reg5;
	wire [31:0] reg6;
	wire [31:0] reg7;
	wire [31:0] reg8;
	wire [31:0] reg9;
	wire [31:0] reg10;
	wire [31:0] reg11;
	wire [31:0] reg12;
	wire [31:0] reg13;
	wire [31:0] reg14;
	wire [31:0] reg15;
	wire [31:0] reg16;
	wire [31:0] reg17;
	wire [31:0] reg18;
	wire [31:0] reg19;
	wire [31:0] reg20;
	wire [31:0] reg21;
	wire [31:0] reg22;
	wire [31:0] reg23;
	wire [31:0] reg24;
	wire [31:0] reg25;
	wire [31:0] reg26;
	wire [31:0] reg27;
	wire [31:0] reg28;
	wire [31:0] reg29;
	wire [31:0] reg30;
	wire [31:0] reg31;
	wire [31:0] reg32;

	assign reg1 = regf[0];
	assign reg2 = regf[1];
	assign reg3 = regf[2];
	assign reg4 = regf[3];
	assign reg5 = regf[4];
	assign reg6 = regf[5];
	assign reg7 = regf[6];
	assign reg8 = regf[7];
	assign reg9 = regf[8];
	assign reg10 = regf[9];
	assign reg11 = regf[10];
	assign reg12 = regf[11];
	assign reg13 = regf[12];
	assign reg14 = regf[13];
	assign reg15 = regf[14];
	assign reg16 = regf[15];
	assign reg17 = regf[16];
	assign reg18 = regf[17];
	assign reg19 = regf[18];
	assign reg20 = regf[19];
	assign reg21 = regf[20];
	assign reg22 = regf[21];
	assign reg23 = regf[22];
	assign reg24 = regf[23];
	assign reg25 = regf[24];
	assign reg26 = regf[25];
	assign reg27 = regf[26];
	assign reg28 = regf[27];
	assign reg29 = regf[28];
	assign reg30 = regf[29];
	assign reg31 = regf[30];
	assign reg32 = regf[31];


	always @ (posedge clk, negedge rst_n)
		if (!rst_n) begin
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
