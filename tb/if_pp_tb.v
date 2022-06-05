`include "cpu_attr.v"
module if_pp_tb();
	reg clk;
	reg _rst;
	reg jump;
	reg[`INST_ADDR_WIDTH-1:0] jump_addr;
	wire[`INST_ADDR_WIDTH-1:0] inst_addr;

	if_pp if_p(
		.clk(clk),
		._rst(_rst),
		.jump(jump),
		.jump_addr(jump_addr),
		.inst_in(),
		.inst_addr(inst_addr),
		.inst_out());

	initial begin
		clk = 1'b0;
		forever #20 clk = ~clk;
	end

	initial begin
		_rst = 1'b0;
		#100 _rst = 1'b1;
	end

	initial begin
		jump = 1'b0;
		#200 jump = 1'b1;
	end

	initial begin
		jump_addr = `INST_ADDR_WIDTH'hAB;
	end	

endmodule