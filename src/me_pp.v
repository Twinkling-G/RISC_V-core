`include "cpu_property.v"

module me_pp(
	input                                clk           ,
	input                                _rst          ,
	
	//from ex
	input                                reg_w_en_in   ,
	input    [`REG_FILE_ADDR_WIDTH-1:0]  rd_addr_in    ,

	input                                mem_r_en_in   ,
	input                                mem_w_en_in   ,
	
	input    [2:0]                       mem_sign      ,
	input    [2:0]                       mem_whb       ,
	input    [`DATA_WIDTH-1:0]           mem_data_in   ,

	input                                sel_mem_res   ,   
	input reg[`DATA_WIDTH-1:0]           res           ,
		
	//to wb
	output reg                           reg_w_en_out  ,
	output reg[`REG_FILE_ADDR_WIDTH-1:0] rd_addr_out   ,
	output    [`DATA_WIDTH-1:0]          reg_data      ,   

	//to data ram
	output reg                           mem_r_en_out  ,  
	output reg                           mem_w_en_out  ,
	output reg [3:0]                     mem_sel       ,
	output     [`DATA_ADDR_WIDTH-1:0]    mem_addr_out  ,
	output     [`DATA_ADDR_WIDTH-1:0]    data_out  ,

	//from data ram
	input     [`DATA_WIDTH-1:0]          data_in   ,

	//for data hazard
	output                               pb_reg_w_en   ,
	output    [`REG_FILE_ADDR_WIDTH-1:0] pb_rd_addr    ,
	output    [`DATA_WIDTH-1:0]          pb_reg_data     

	);

	reg [2:0]                  mem_sign_q   ;
	reg [2:0]                  mem_whb_q    ;
	reg                        sel_mem_res_q;
	reg [`DATA_WIDTH-1:0]      mem_data_q   ;
	reg [`DATA_WIDTH-1:0]      res_q        ;

	always @(posedge clk) begin
		if (!_rst) begin
			res_q         <= `DATA_ADDR_WIDTH'b0    ;
			rd_addr_out   <= `REG_FILE_ADDR_WIDTH'b0;
			reg_w_en_out  <= 1'b0                   ;
			mem_r_en_out  <= 1'b0                   ;
			mem_w_en_out  <= 1'b0                   ;
			mem_sign_q    <= 3'b0                   ;
			mem_whb_q     <= 3'b0                   ;
			mem_data_q    <= `DATA_WIDTH'b0         ;
			sel_mem_res_q <= 1'b0                   ;
		end
		else begin
			res_q         <= res        ;
			rd_addr_out   <= rd_addr_in ;
			reg_w_en_out  <= reg_w_en_in;
			mem_r_en_out  <= mem_r_en_in;
			mem_w_en_out  <= mem_w_en_in;
			mem_sign_q    <= mem_sign   ;
			mem_whb_q     <= mem_whb    ;
			mem_data_q    <= mem_data_in;
			sel_mem_res_q <= sel_mem_res;
		end
	end

	wire [`DATA_WIDTH-1:0] dic_y     ;
	reg  [`DATA_WIDTH-1:0] extend_y  ;

	d_in_ctrl  dic(mem_sel,res_q[1:0],data_in   ,dic_y   );
	d_out_ctrl doc(mem_sel,res_q[1:0],mem_data_q,data_out);

	assign reg_data     = sel_mem_res_q ? extend_y : res_q;
	assign mem_addr_out = res_q                           ;
	assign pb_reg_w_en  = reg_w_en_out                    ;
	assign pb_rd_addr   = rd_addr_out                     ;
	assign pb_reg_data  = reg_data                        ;

 	always @(*) begin
 		mem_sel = 4'b0000;
 		case(mem_whb_q)
 			3'b001:begin
 				case(mem_addr_out[1:0])
 					2'b00:mem_sel = 4'b0001;
 					2'b01:mem_sel = 4'b0010;
 					2'b10:mem_sel = 4'b0100;
 					2'b11:mem_sel = 4'b1000;
 				endcase
 			end
			3'b010:begin
				case(mem_addr_out[1])
					1'b0:mem_sel = 4'b0011;
					1'b1:mem_sel = 4'b1100;
				endcase
			end
			3'b100:begin
				mem_sel = 4'b1111;
			end
 		endcase
 	end 

	always @(*) begin
		extend_y = dic_y;
		case(mem_sign_q)
			3'b001:extend_y = {{24{dic_y[7]}},dic_y[7:0]}  ;
			3'b010:extend_y = {{16{dic_y[15]}},dic_y[15:0]};
			3'b100:extend_y = dic_y                        ;
		endcase
	end	

endmodule