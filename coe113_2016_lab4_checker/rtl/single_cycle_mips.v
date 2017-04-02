`define WORD_WIDTH 32
module single_cycle_mips ( clk, rst_n, inst_addr, inst, data_addr, data_in,
        data_out, data_wr );
  output [31:0] inst_addr;
  input [31:0] inst;
  output [31:0] data_addr;
  input [31:0] data_in;
  output [31:0] data_out;
  input clk, rst_n;
  output reg data_wr;

  parameter instBEQ = 6'b000100;
  parameter instBNE = 6'b000101;
  parameter instADDI = 6'b001000;
  parameter instSLTI = 6'b001010;
  parameter instSW = 6'b101011;
  parameter instLW = 6'b100011;

  parameter instRType = 6'd0;

  parameter functADD = 6'b100000;
  parameter functSUB = 6'b100010;
  parameter functSLT = 6'b101010;

	reg [4:0] rd_addrA;
	reg [4:0] rd_addrB;
	wire [31:0] rd_dataA;
	wire [31:0] rd_dataB;
	reg wr_en;
	reg [4:0] wr_addr;
	reg [31:0] wr_data;
	reg [5:0] opcode;
	reg [5:0] funct;

	/* Register File */
	rf R1 (.clk(clk),
		.rst_n(rst_n),
		.rd_addrA(rd_addrA),
		.rd_addrB(rd_addrB),
		.rd_dataA(rd_dataA),
		.rd_dataB(rd_dataB),
		.wr_en(wr_en),
		.wr_addr(wr_addr),
		.wr_data(wr_data)
	);

	/* Program Counter */
	reg [31:0] inst_addr;

	reg [`WORD_WIDTH-1:0] aluOpB;
	reg [1:0] aluSel;
	wire [`WORD_WIDTH-1:0] aluRes;
	wire aluZ;
	wire aluNeg;

	/* ALU */
	alu A1 (.opA(rd_dataA),
		.opB(aluOpB),
		.sel(aluSel),
		.res(aluRes),
		.z(aluZ),
		.neg(aluNeg)
	);

  always @ (*)
    rd_addrA <= inst[25:21];

  always @ (*)
    rd_addrB <= inst[20:16];

  always @ (*)
    opcode <= inst[31:26];

  always @ (*)
    funct <= inst[5:0];

	always @ (posedge clk, negedge rst_n)
		if (!rst_n)
			inst_addr <= 0;
		else
      case (opcode)
        instBEQ:
          if (aluZ)
            inst_addr <= (inst_addr + 4) + { {15{inst[15]}}, inst[15:0], 2'b0 };
          else
            inst_addr <= inst_addr + 4;
        instBNE:
          if (!aluZ)
            inst_addr <= (inst_addr + 4) + { {15{inst[15]}}, inst[15:0], 2'b0 };
          else
            inst_addr <= inst_addr + 4;
        default:
            inst_addr <= inst_addr + 4;
      endcase

	/* wr_addr input multiplexer for the reg file */
	always @ (*)
		case (opcode)
      instRType:
				wr_addr <= inst[15:11];		// rd
      instADDI,
      instSLTI,
      instSW,
      instLW:
				wr_addr <= inst[20:16];		// rt
			default:
				wr_addr <= inst[15:11];
		endcase

	/* wr_en control signal for reg file */
	always @ (*)
		case (opcode)
      instRType,
      instADDI,
      instSLTI,
      instLW:
				wr_en <= 1'b1;
			default:
				wr_en <= 1'b0;
		endcase

	/* aluOpB input multiplexer for the ALU */
	always @ (*)
		case (opcode)
      instRType:
				aluOpB <= rd_dataB;
      instADDI,
      instSLTI,
      instSW,
      instLW:
				aluOpB <= { {16{inst[15]}}, inst[15:0] };		// sign extend
			default:
				aluOpB <= rd_dataB;
		endcase

	parameter aluAdd = 2'd0;
	parameter aluSub = 2'd1;

	/* aluSel control signal for ALU */
	always @ (*)
		case (opcode)
      instRType:
				case (funct)
          functADD:
						aluSel <= aluAdd;
          functSUB,
          functSLT:
						aluSel <= aluSub;
					//default:
						//aluSel <= ???
				endcase
      instADDI,
      instSW,
      instLW:
				aluSel <= aluAdd;
      instBEQ,
      instBNE,
      instSLTI:
				aluSel <= aluSub;
		endcase

	/* data_wr control signal for the data memory */
	always @ (*)
		case (opcode)
      instSW:
				data_wr <= 1'b1;
			default:
				data_wr <= 1'b0;
		endcase

	/* wr_data input control signal for the reg file */
	always @ (*)
		case (opcode)
      instRType:
				case (funct)
          functSLT:
						wr_data <= 32'd1;
					default:
						wr_data <= aluRes;
				endcase
      instADDI:
				wr_data <= aluRes;
      instSLTI:
				wr_data <= 32'd1;
      instLW:
				wr_data <= data_in;
		endcase


	assign data_out = rd_dataB;
	assign data_addr = aluRes;
endmodule
