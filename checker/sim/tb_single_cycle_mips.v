`timescale 1ns/1ps
`define CLK_PERIOD 50
`define TIMEOUT 9
`define WATCHDOG 500
module tb_single_cycle_mips;

  reg clk,rst_n;
  wire [31:0] inst_addr,inst;
  wire [31:0] data_addr,data_in,data_out;
  wire data_wr;

  single_cycle_mips UUT(
    .clk(clk),
    .rst_n(rst_n),
    .inst_addr(inst_addr),
    .inst(inst),
    .data_addr(data_addr),
    .data_in(data_in),
    .data_out(data_out),
    .data_wr(data_wr)
  );

  instmem I1(
    .inst_addr(inst_addr),
    .inst(inst)
  );

  datamem D1(
    .clk(clk),
    .data_addr(data_addr),
    .data_wr(data_wr),
    .data_in(data_in),
    .data_out(data_out)
  );

  always begin
    #(`CLK_PERIOD/2.0) clk = ~clk;
  end

  integer nop_count = 0;
  integer watch_count = 0;
  integer i = 0;
  integer ldst = 0;
  integer add = 0;
  integer sub = 0;
  integer slt = 0;
  integer beq = 0;
  integer bne = 0;
  reg [31:0] ref [0:127];
  reg [31:0] res;

  initial begin
    // $vcdplusfile("tb_single_cycle_mips.vpd");
    // $vcdpluson;


    //init
    clk = 0;
    rst_n = 0;

    #(`CLK_PERIOD*10);
    #(`CLK_PERIOD*0.8);
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

    //display mem
    for (i=0; i<22; i=i+1) begin
      $display("%d %X%X%X%X - %X",
        i,
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
        11,12,13,14:
          if (res == ref[i]) beq = beq + 1;
        15,16,17,18:
          if (res == ref[i]) sub = sub + 1;
        19,20:
          if (res == ref[i]) slt = slt + 1;
        21:
          if (res == ref[i]) bne = bne + 1;
      endcase
    end

    $display("Load/Store: %d",ldst);
    $display("ADD: %d",add);
    $display("SUB: %d",sub);
    $display("SLT: %d",slt);
    $display("BEQ: %d",beq);
    $display("BNE: %d",bne);

    $finish;
  end

  initial begin
    $readmemh("./ref.txt",ref);
  end

`ifdef SDF
  initial begin
    $sdf_annotate("../mapped/single_cycle_mips_mapped.sdf",single_cycle_mips);
  end
`endif

endmodule
