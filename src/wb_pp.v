`include "cpu_property.v"

module wb_pp(
	input                                clk           , 
	input                                _rst          , 
	//from me
	input                                reg_w_en_in   ,
	input    [`REG_FILE_ADDR_WIDTH-1:0]  rd_addr_in    , 
	input    [`DATA_WIDTH-1:0]           reg_data_in   ,   

	//to register file
	output reg                           reg_w_en_out  ,
	output reg[`REG_FILE_ADDR_WIDTH-1:0] rd_addr_out   ,
	output reg[`DATA_WIDTH-1:0]          reg_data_out  ,

	//for data hazard
	output                               pb_reg_w_en   ,
	output    [`REG_FILE_ADDR_WIDTH-1:0] pb_rd_addr    ,
	output    [`DATA_WIDTH-1:0]          pb_reg_data     
);

	always @(posedge clk) begin
		if (!_rst) begin
			reg_data_out   <= `DATA_WIDTH'b0         ;
			rd_addr_out    <= `REG_FILE_ADDR_WIDTH'b0;
			reg_w_en_out   <= 1'b0                   ;
		end
		else begin
			reg_data_out   <= reg_data_in            ;
			rd_addr_out    <= rd_addr_in             ;
			reg_w_en_out   <= reg_w_en_in            ;
		end
	end

	assign pb_reg_w_en = reg_w_en_out;
	assign pb_rd_addr  = rd_addr_out ;
	assign pb_reg_data = reg_data_out;
endmodule