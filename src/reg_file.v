`include "cpu_property.v"

module reg_file(
	input                                 clk     ,
	input                                 _rst    , 

	//from id
	input      [`REG_FILE_ADDR_WIDTH-1:0] rs1_addr,
	input      [`REG_FILE_ADDR_WIDTH-1:0] rs2_addr,

	//to id
	output reg [`DATA_WIDTH-1:0]          rs1     ,
	output reg [`DATA_WIDTH-1:0]          rs2     ,

	//from wb
	input                                 w_en    ,
	input      [`REG_FILE_ADDR_WIDTH-1:0] rd_addr , 
	input      [`DATA_WIDTH-1:0]          w_in    
	
);
	integer i;
	reg[`DATA_WIDTH-1:0] regs[1:`REG_FILE_DEPTH-1];

	always @(*) begin
		if (rs1_addr == `REG_FILE_ADDR_WIDTH'b0) begin
			rs1 = `DATA_WIDTH'b0;
		end
		else begin
			rs1 = regs[rs1_addr];
		end
	end

	always @(*) begin
		if (rs2_addr == `REG_FILE_ADDR_WIDTH'b0) begin
			rs2 = `DATA_WIDTH'b0;
		end
		else begin
			rs2 = regs[rs2_addr];
		end
	end

	always @(posedge clk ) begin
		if (_rst == 1'b0)begin 
			for(i = 1;i<`REG_FILE_DEPTH;i = i+1)begin
				regs[i] <= `DATA_WIDTH'b0;
			end	
		end
		else if (w_en && rd_addr != `REG_FILE_ADDR_WIDTH'b0) begin
			regs[rd_addr] <= w_in;
		end
	end
endmodule