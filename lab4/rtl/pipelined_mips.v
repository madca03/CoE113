`timescale 1ns/1ps
`define WORD_WIDTH 32
`define MEM_DEPTH  32
`define MEM_WIDTH  32
`define INPUT_DELAY 5
`define OUTPUT_DELAY 5

module pipelined_mips ( clk, rst_n, inst_addr, inst, data_addr, data_in,
  data_out, data_wr, pc_IF, pc_ID, pc_EXE, pc_MEM, pc_WB );
  input clk;
  input rst_n;
  output [31:0] inst_addr;
  input [31:0] inst;
  output [31:0] data_addr;
  input [31:0] data_in;
  output [31:0] data_out;
  output data_wr;
  output [31:0] pc_IF;
  output [31:0] pc_ID;
  output [31:0] pc_EXE;
  output [31:0] pc_MEM;
  output [31:0] pc_WB;

  parameter instBEQ = 6'b000100;
  parameter instBNE = 6'b000101;
  parameter instADDI = 6'b001000;
  parameter instSLTI = 6'b001010;
  parameter instSW = 6'b101011;
  parameter instLW = 6'b100011;
  parameter instJUMP = 6'b000010;
  parameter instJAL = 6'b000011;

  parameter instRType = 6'd0;

  parameter functADD = 6'b100000;
  parameter functSUB = 6'b100010;
  parameter functSLT = 6'b101010;
  parameter functJR = 6'b001000;

  parameter aluAdd = 2'd0;
  parameter aluSub = 2'd1;

  wire [31:0] rd_dataA;
  wire [31:0] rd_dataB;

  /* Program Counter */
  reg [31:0] inst_addr;

  wire [31:0] aluRes;
  wire aluZ;
  wire aluNeg;

  wire [31:0] pc_IF;
  wire [31:0] pc_ID;
  wire [31:0] pc_EXE;
  wire [31:0] pc_MEM;
  wire [31:0] pc_WB;

  reg [31:0] if_id_inst_addr;
  wire [31:0] if_id_inst;

  reg [31:0] id_exe_aluOpA;
  reg [31:0] id_exe_aluOpB;
  reg [31:0] id_exe_storeOp;
  reg [4:0] id_exe_wr_addr;
  reg [31:0] id_exe_inst;
  reg [31:0] id_exe_inst_addr;
  reg [1:0] id_exe_aluSel;
  reg id_exe_data_wr;
  reg id_exe_wr_en;

  reg [31:0] exe_mem_aluRes;
  reg [31:0] exe_mem_storeOp;
  reg [4:0] exe_mem_wr_addr;
  reg [31:0] exe_mem_inst;
  reg [31:0] exe_mem_inst_addr;
  reg exe_mem_wr_en;
  reg exe_mem_data_wr;
  reg exe_mem_aluZ;
  reg exe_mem_aluNeg;

  reg [4:0] mem_wb_wr_addr;
  reg [31:0] mem_wb_wr_data;
  reg [31:0] mem_wb_inst;
  reg [31:0] mem_wb_inst_addr;
  reg [31:0] mem_wb_aluRes;
  reg mem_wb_wr_en;
  reg mem_wb_aluNeg;

  reg branch_taken;
  reg flush_jump;

  /* Register File */
  rf R1 (.clk(clk),
    .rst_n(rst_n),
    .rd_addrA(if_id_inst[25:21]),
    .rd_addrB(if_id_inst[20:16]),
    .rd_dataA(rd_dataA),
    .rd_dataB(rd_dataB),
    .wr_en(mem_wb_wr_en),
    .wr_addr(mem_wb_wr_addr),
    .wr_data(mem_wb_wr_data)
  );

  /* ALU */
  alu A1 (.opA(id_exe_aluOpA),
    .opB(id_exe_aluOpB),
    .sel(id_exe_aluSel),
    .res(aluRes),
    .z(aluZ),
    .neg(aluNeg)
  );

  always @ (*)
    if ( ((id_exe_inst[31:26] == instBEQ) && aluZ) || ((exe_mem_inst[31:26] == instBEQ) && exe_mem_aluZ) ||
      ((id_exe_inst[31:26] == instBNE) && !aluZ) || ((exe_mem_inst[31:26] == instBNE) && !exe_mem_aluZ) )
      branch_taken <= 1'b1;
    else
      branch_taken <= 1'b0;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) flush_jump <= 1'b0;
    else
      case (if_id_inst[31:26])
        instRType:
          case (if_id_inst[5:0])
            functJR:
              flush_jump <= 1'b1;
            default:
              flush_jump <= 1'b0;
          endcase

        instJUMP,instJAL:
          flush_jump <= 1'b1;

        default:
          flush_jump <= 1'b0;
      endcase

  reg [31:0] new_inst_addr;
  reg [31:0] inst_plus_four;

  // Program Counter Logic
  always @ (posedge clk, negedge rst_n)
    if (!rst_n)
      inst_addr <= 0;
    else
      case (if_id_inst[31:26])
        instRType:
          case (if_id_inst[5:0])
            functJR:
              // rd_dataA contains the value of $ra ($31)
              inst_addr <= rd_dataA;
            default:
              inst_addr <= inst_addr + 4;
          endcase
        instJUMP,
        instJAL:
          inst_addr <= { inst_addr[31:28], if_id_inst[25:0], 2'b0 };
        default:
          // "id_exe_inst[31:26]" is the instruction opcode at the EXE stage
          case (id_exe_inst[31:26])
            instBEQ:
              if (aluZ)
                inst_addr <= if_id_inst_addr + { {14{id_exe_inst[15]}}, id_exe_inst[15:0], 2'b0 };
              else
                inst_addr <= inst_addr + 4;
            instBNE:
              if (!aluZ)
                inst_addr <= if_id_inst_addr + { {14{id_exe_inst[15]}}, id_exe_inst[15:0], 2'b0 };
              else
                inst_addr <= inst_addr + 4;
            default:
              inst_addr <= inst_addr + 4;
          endcase
      endcase

  /* IF/ID Pipeline Register */
  always @ (posedge clk, negedge rst_n)
    if (!rst_n) begin
      if_id_inst_addr <= 0;
    end
    else begin
      if_id_inst_addr <= pc_IF;
    end

  assign if_id_inst = inst;

  /* IF/ID Pipeline Register end */

  // PC at IF stage
  assign pc_IF = inst_addr;
  assign pc_ID = if_id_inst_addr;
  assign pc_EXE = id_exe_inst_addr;
  assign pc_MEM = exe_mem_inst_addr;
  assign pc_WB = mem_wb_inst_addr;

  /* ID/EXE Pipeline Register */
  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_aluOpA <= 0;
    else id_exe_aluOpA <= rd_dataA;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_aluOpB <= 0;
    else
      // "if_id_inst[31:26]" is the instruction opcode at ID stage
      case (if_id_inst[31:26])
        instRType:
          id_exe_aluOpB <= rd_dataB;
        instADDI,
        instSLTI,
        instSW,
        instLW:
          id_exe_aluOpB <= { {16{inst[15]}}, inst[15:0] };		// sign extend
        default:
          id_exe_aluOpB <= rd_dataB;
      endcase

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_storeOp <= 0;
    else id_exe_storeOp <= rd_dataB;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_inst <= 0;
    else id_exe_inst <= if_id_inst;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_inst_addr <= 0;
    else id_exe_inst_addr <= if_id_inst_addr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_wr_addr <= 0;
    else
      // "if_id_inst[31:26]" is the instruction opcode at ID stage
      case (if_id_inst[31:26])
        instRType:
          id_exe_wr_addr <= if_id_inst[15:11];		// rd
        instADDI,
        instSLTI,
        instSW,
        instLW:
          id_exe_wr_addr <= if_id_inst[20:16];		// rt
        instJAL:
          id_exe_wr_addr <= 31;   // write to $ra (return address)
        default:
          id_exe_wr_addr <= if_id_inst[15:11];
      endcase

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_aluSel <= 0;
    else
      // "if_id_inst[31:26]" is the instruction opcode at ID stage
      case (if_id_inst[31:26])
        instRType:
        // "if_id_inst[5:0]" is the funct code for an R type instruction at ID stage
          case (if_id_inst[5:0])
            functADD:
              id_exe_aluSel <= aluAdd;
            functSUB,
            functSLT:
              id_exe_aluSel <= aluSub;
          endcase
        instADDI,
        instSW,
        instLW:
          id_exe_aluSel <= aluAdd;
        instBEQ,
        instBNE,
        instSLTI:
          id_exe_aluSel <= aluSub;
      endcase

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_data_wr <= 0;
    else
      if (branch_taken || flush_jump)
        id_exe_data_wr <= 1'b0;
      else
        // "if_id_inst[31:26]" is the instruction opcode at ID stage
        case (if_id_inst[31:26])
          instSW:
            id_exe_data_wr <= 1'b1;
          default:
            id_exe_data_wr <= 1'b0;
        endcase

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) id_exe_wr_en <= 0;
    else
      if (branch_taken)
        id_exe_wr_en <= 1'b0;
      else
        // "if_id_inst[31:26]" is the instruction opcode at ID stage
        case (if_id_inst[31:26])
          instRType:
            if (if_id_inst == 32'd0) id_exe_wr_en <= 1'b0;
            else id_exe_wr_en <= 1'b1;
          instADDI,
          instSLTI,
          instLW,
          instJAL:
            id_exe_wr_en <= 1'b1;
          default:
            id_exe_wr_en <= 1'b0;
        endcase

  /* EXE/MEM pipeline register */
  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_storeOp <= 0;
    else exe_mem_storeOp <= id_exe_storeOp;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_wr_addr <= 0;
    else exe_mem_wr_addr <= id_exe_wr_addr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_inst <= 0;
    else exe_mem_inst <= id_exe_inst;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_inst_addr <= 0;
    else exe_mem_inst_addr <= id_exe_inst_addr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_wr_en <= 0;
    else exe_mem_wr_en <= id_exe_wr_en;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n)  exe_mem_data_wr <= 0;
    else exe_mem_data_wr <= id_exe_data_wr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_aluRes <= 0;
    else exe_mem_aluRes <= aluRes;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_aluNeg <= 0;
    else exe_mem_aluNeg <= aluNeg;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) exe_mem_aluZ <= 0;
    else exe_mem_aluZ <= aluZ;

  /* EXE/MEM pipeline register end */

  assign data_addr = exe_mem_aluRes;
  assign data_out = exe_mem_storeOp;
  assign data_wr = exe_mem_data_wr;

  /* MEM/WB pipeline register */
  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_inst <= 0;
    else mem_wb_inst <= exe_mem_inst;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_inst_addr <= 0;
    else mem_wb_inst_addr <= exe_mem_inst_addr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_wr_addr <= 0;
    else mem_wb_wr_addr <= exe_mem_wr_addr;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_wr_en <= 0;
    else mem_wb_wr_en <= exe_mem_wr_en;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_aluRes <= 0;
    else mem_wb_aluRes <= exe_mem_aluRes;

  always @ (posedge clk, negedge rst_n)
    if (!rst_n) mem_wb_aluNeg <= 0;
    else mem_wb_aluNeg <= exe_mem_aluNeg;

  /* MEM/WB pipeline register end */


  always @ (*)
    case (mem_wb_inst[31:26])
      instRType: begin
        // "exe_mem_inst[5:0]" is the funct code for an R type instruction at ID stage
        case (mem_wb_inst[5:0])
          functSLT:
            if (mem_wb_aluNeg)
              mem_wb_wr_data <= 32'd1;
            else
              mem_wb_wr_data <= 32'd0;
          default:
            mem_wb_wr_data <= mem_wb_aluRes;
        endcase
      end

      instADDI: begin
        mem_wb_wr_data <= mem_wb_aluRes;
      end

      instSLTI: begin
        if (mem_wb_aluNeg)
          mem_wb_wr_data <= 32'd1;
        else
          mem_wb_wr_data <= 32'd0;
      end

      instLW: begin
        mem_wb_wr_data <= data_in;
      end

      instJAL:
        // exe_mem_inst_addr is PC + 4
        mem_wb_wr_data <= exe_mem_inst_addr;
        // mem_wb_wr_data <= exe_mem_inst_addr + 4;
    endcase


endmodule

module alu ( opA, opB, sel, res, z, neg );
	input [`WORD_WIDTH-1:0] opA;
	input [`WORD_WIDTH-1:0]	opB;
	input [1:0] sel;
	output [31:0] res;
	output z;
	output neg;

	wire [`WORD_WIDTH-1:0] res_add;
	wire [`WORD_WIDTH-1:0] res_sub;
  reg [31:0] res_temp;

  assign res_add = opA + opB;
  assign res_sub = opA - opB;

	/* res output */
  always @ (*)
    case (sel)
      2'd0: res_temp <= res_add;
      2'd1: res_temp <= res_sub;
    endcase

  assign #(`INPUT_DELAY) res = res_temp;

	/* zero flag */
	assign #(`INPUT_DELAY) z = (res_temp == 0) ? 1'b1 : 1'b0;

	/* negative number flag */
	assign #(`INPUT_DELAY) neg = (res_temp[31] == 1'b1) ? 1'b1 : 1'b0;

endmodule

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

  wire [31:0] reg0;
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

  assign reg0 = regf[0];
	assign reg1 = regf[1];
	assign reg2 = regf[2];
	assign reg3 = regf[3];
	assign reg4 = regf[4];
	assign reg5 = regf[5];
	assign reg6 = regf[6];
	assign reg7 = regf[7];
	assign reg8 = regf[8];
	assign reg9 = regf[9];
	assign reg10 = regf[10];
	assign reg11 = regf[11];
	assign reg12 = regf[12];
	assign reg13 = regf[13];
	assign reg14 = regf[14];
	assign reg15 = regf[15];
	assign reg16 = regf[16];
	assign reg17 = regf[17];
	assign reg18 = regf[18];
	assign reg19 = regf[19];
	assign reg20 = regf[20];
	assign reg21 = regf[21];
	assign reg22 = regf[22];
	assign reg23 = regf[23];
	assign reg24 = regf[24];
	assign reg25 = regf[25];
	assign reg26 = regf[26];
	assign reg27 = regf[27];
	assign reg28 = regf[28];
	assign reg29 = regf[29];
	assign reg30 = regf[30];
	assign reg31 = regf[31];

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
