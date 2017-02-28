`timescale 1ns/1ps
`define MEM_DEPTH  1024
`define MEM_WIDTH  8
`define WORD_WIDTH 32
`define CLK_PD 100
`define DEL_IN 3

module tb_proc;
	wire [31:0] inst_addr;
  wire [31:0] inst;
  wire [31:0] data_addr;
  wire [31:0] data_in;
  wire [31:0] data_out;
  reg clk, rst_n;
  wire data_wr;

	single_cycle_mips UUT (.clk(clk),
		.rst_n(rst_n),
		.inst_addr(inst_addr),
		.inst(inst),
		.data_addr(data_addr),
		.data_in(data_in),
    .data_out(data_out),
		.data_wr(data_wr)
	);

	instmem I1 (.inst_addr(inst_addr),
		.inst(inst)
	);

	datamem D1 (.clk(clk),
  	.data_addr(data_addr),
  	.data_wr(data_wr),
  	.data_in(data_in),
  	.data_out(data_out)
	);

	datamem_ans D2();

	always #(`CLK_PD/2.0) clk = ~clk;

	integer i = 0;
	integer j = 0;
	integer k = 0;

	integer sw_w = 0;
	integer add_w = 0;
	integer sub_w = 0;
	integer slt_w = 0;
	integer addi_w = 0;
	integer slti_w = 0;
	integer beq_w = 0;
	integer bne_w = 0;

	initial begin
		// $vcdplusfile("tb_proc.vpd");
		// $vcdpluson;
		// $sdf_annotate("../mapped/single_cycle_mips_mapped.sdf", UUT);

		clk = 0;
		rst_n = 0;

		#(`CLK_PD/2.0);
		#(`DEL_IN);
		rst_n = 1;

		while (k != 10) begin
			if (UUT.inst == 32'd0) begin
				k = k + 1;
			end
			#(`CLK_PD);
		end

		$display("\nPrinting the final contents of the data memory...");

		$display("data # \t\taddress \tdata	\tcorrect data");
		$display("-------- \t-------- \t-------- \t--------");
		while(j != 10) begin
			if ((i < 3) && (!beq_w)) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					beq_w = 1;
				end
			end

			if ((i > 3) && (i < 6) && (!bne_w)) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					bne_w = 1;
				end
			end

			if (i == 9) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					sw_w = 1;
				end
			end

			if (i == 16) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					add_w = 1;
				end
			end

			if (i == 17) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					sub_w = 1;
				end
			end

			if (i == 18) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					slt_w = 1;
				end
			end

			if (i == 19) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					slti_w = 1;
				end
			end

			if (i == 20) begin
				if (
					(D1.memory[(i*4)] != D2.memory[(i*4)]) ||
					(D1.memory[(i*4)+1] != D2.memory[(i*4)+1]) ||
					(D1.memory[(i*4)+2] != D2.memory[(i*4)+2]) ||
					(D1.memory[(i*4)+3] != D2.memory[(i*4)+3])
					) begin
					addi_w = 1;
				end
			end

      $display("%8d \t%X \t%X%X%X%X \t%X%X%X%X",
				i,
				i*4,
				D1.memory[(i*4)],
        D1.memory[(i*4)+1],
        D1.memory[(i*4)+2],
        D1.memory[(i*4)+3],

				D2.memory[(i*4)],
        D2.memory[(i*4)+1],
        D2.memory[(i*4)+2],
        D2.memory[(i*4)+3]
        );
			if ((!D1.memory[(i*4)]) && (!D1.memory[(i*4)+1]) && (!D1.memory[(i*4)+2]) && (!D1.memory[(i*4)+3]))
				j = j + 1;
			else
				j = 0;
			i = i + 1;
    end
		$display("\n\n");

		if (sw_w) $display("lw: wrong");
		else $display("lw: correct");
		if (sw_w) $display("sw: wrong");
		else $display("sw: correct");
		if (add_w) $display("add: wrong");
		else $display("add: correct");
		if (sub_w) $display("sub: wrong");
		else $display("sub: correct");
		if (slt_w) $display("slt: wrong");
		else $display("slt: correct");
		if (addi_w) $display("addi: wrong");
		else $display("addi: correct");
		if (slti_w) $display("slti: wrong");
		else $display("slti: correct");
		if (beq_w) $display("beq: wrong");
		else $display("beq: correct");
		if (bne_w) $display("bne: wrong");
		else $display("bne: correct");

		$finish;
	end

endmodule
