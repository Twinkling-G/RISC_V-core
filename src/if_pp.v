`include "cpu_property.v"
module if_pp(
	input                            clk      ,
	input                            _rst     ,
  
	//from ex
	input                            jump_en  ,
	input     [`INST_ADDR_WIDTH-1:0] jump_addr,

	//to instruction mem 
	output reg[`INST_ADDR_WIDTH-1:0] inst_addr,

	//from instruction mem
	input     [`INST_WIDTH-1:0]      inst_in  ,
	
	//to id
	output    [`INST_WIDTH-1:0]      inst_out ,
	output    [`INST_ADDR_WIDTH-1:0] pc       ,

	//for data hazard 
	input                            stall    
);	
	always @(posedge clk) begin
		if (!_rst) begin
			inst_addr <= `INST_ADDR_WIDTH'b0;
		end
		else if (!stall) begin
			inst_addr <= jump_en ? jump_addr : (inst_addr + `INST_ADDR_WIDTH'h4);
		end
	end
	
	assign inst_out    = inst_in                                                ;
	assign pc          = inst_addr                                              ;

endmodule