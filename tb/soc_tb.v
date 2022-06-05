`include "cpu_property.v"
module soc_tb();
	reg clk ;
	reg _rst;

	integer i;

	risc_v_soc cpu(clk,_rst);

	initial begin
		$readmemh("rv32ui-p-add.txt",cpu.inst_rom.mem);
		// for(i = 0;i < 400 ; i = i+1)begin
		// 	$display("[IM%X] = %X",i*4,cpu.inst_rom.mem[i]);
		// end

		//$readmemh("rv32ui-p-add.txt",cpu.data_ram.mem);
		clk = 1'b0;
		forever #20 clk = ~clk;
	end

	initial begin
		    _rst = 1'b0;
		#30 _rst = 1'b1;
	end

	initial begin
		forever begin
			@(posedge clk)
			for(i = 1;i < 32 ; i = i+1)begin
				$display("[R%d] = %X",i,cpu.core_o.rf.regs[i]);
			end
			// $display("---------------");
			// $display("inst_addr = %X",cpu.core_o.if_pp_o.inst_addr);
			// $display("inst      = %X",cpu.core_o.if_pp_o.inst_out);
			$display("===========================================");
		end
	end


endmodule