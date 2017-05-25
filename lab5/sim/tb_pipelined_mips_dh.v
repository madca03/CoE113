`timescale 1ns/1ps
`define TIMEOUT 9
`define WATCHDOG 500

module tb_pipelined_mips();
	reg clk, rst_n;
	wire [31:0] inst_addr;
  wire [31:0] inst;
  wire [31:0] data_addr;
  wire [31:0] data_in;
  wire [31:0] data_out;
  wire data_wr;
	wire [31:0] pc_IF;
	wire [31:0] pc_ID;
	wire [31:0] pc_EXE;
	wire [31:0] pc_MEM;
	wire [31:0] pc_WB;

	pipelined_mips UUT ( .clk(clk),
		.rst_n(rst_n),
		.inst_addr(inst_addr),
		.inst(inst),
		.data_addr(data_addr),
		.data_in(data_in),
    .data_out(data_out),
		.data_wr(data_wr),
		.pc_IF(pc_IF),
		.pc_ID(pc_ID),
		.pc_EXE(pc_EXE),
		.pc_MEM(pc_MEM),
		.pc_WB(pc_WB)
	);

	instmem I1 ( .clk(clk),
		.inst_addr(inst_addr),
		.inst(inst)
	);

	datamem D1 (.clk(clk),
  	.data_addr(data_addr),
  	.data_wr(data_wr),
  	.data_in(data_in),
  	.data_out(data_out)
	);

	reg [31:0] ref [0:127];
	reg [31:0] res;

	always begin
    #(`CLK_PERIOD/2.0) clk = ~clk;
  end

	integer nop_count = 0;
	integer watch_count = 0;
	integer i = 0;
	integer ldst,add,sub,slt,beq,bne,jump,jal,jr,addi,slti;

	initial begin
		$dumpfile("pipelined_mips.vcd");
		$dumpvars;
		clk = 0;
		rst_n = 0;

		#(`CLK_PERIOD*10);
		#(`CLK_PERIOD*0.8);		// 540n
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
		jump = 0;
		jal = 0;
		jr = 0;
		addi = 0;
		slti = 0;

		//display mem
    for (i=0; i<75; i=i+1) begin
      $display("%d - %d - %X - %X%X%X%X - %X",
				i,
        i*4,
        i*4,
        D1.memory[(i*4)],
        D1.memory[(i*4)+1],
        D1.memory[(i*4)+2],
        D1.memory[(i*4)+3],
        ref[i]
        );

			res = {D1.memory[(i*4)],
			 D1.memory[(i*4)+1],
			 D1.memory[(i*4)+2],
			 D1.memory[(i*4)+3]};

			case(i)
				3,4,6:
					if (res == ref[i]) ldst = ldst + 1;
				7,8,9,10:
					if (res == ref[i]) add = add + 1;
				11,12,13,14,21,57,58:
					if (res == ref[i]) beq = beq + 1;
				15,16,17,18:
					if (res == ref[i]) sub = sub + 1;
				19,20:
					if (res == ref[i]) slt = slt + 1;
				22,23,24,25,26:
					if (res == ref[i]) bne = bne + 1;
				27,28,29,30,31,59,60:
					if (res == ref[i]) jump = jump + 1;
				32,33,35,36,37,40,42:
					if (res == ref[i]) jal = jal + 1;
				34,38,41:
					if (res == (ref[i] - 32'h00003000)) jal = jal + 1;
				39,53,54,55,56:
					if (res == ref[i]) jr = jr + 1;
				43,44,45,46,47:
					if (res == ref[i]) slti = slti + 1;
				48,49,50,51:
					if (res == ref[i]) addi = addi + 1;
				52:
					if (res == (ref[i] - 32'h00003000)) addi = addi + 1;

			endcase
		end

		$display("\n");
		$display("\tLW/SW:\t %d / 3",ldst);
		$display("\tADD:\t %d / 4",add);
		$display("\tADDI:\t %d / 5",addi);
		$display("\tSUB:\t %d / 4",sub);
		$display("\tSLT:\t %d / 2",slt);
		$display("\tSLTI:\t %d / 5",slti);
		$display("\tBEQ:\t %d / 7",beq);
		$display("\tBNE:\t %d / 5",bne);
		$display("\tJUMP:\t %d / 7",jump);
		$display("\tJAL:\t %d / 10",jal);
		$display("\tJR:\t %d / 5",jr);


		$finish;
	end

	initial begin
		$readmemh("./datamem_ans.txt",ref);
	end

	`ifdef SDF
	  initial begin
	    $sdf_annotate("../mapped/single_cycle_mips_mapped.sdf",single_cycle_mips);
	  end
	`endif
endmodule
