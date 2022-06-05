`include "cpu_property.v"

module ex_pp(
	input                                clk            ,
	input                                _rst           ,
 
	//from id 
	//oprand
	input     [`DATA_WIDTH-1:0]          opd1           ,
	input     [`DATA_WIDTH-1:0]          opd2           ,
	input     [`DATA_WIDTH-1:0]          base           ,
	input     [`DATA_WIDTH-1:0]          offset         ,
	//alu conctrl
	input     [4:0]                      op             ,
	//data select
	input                                sel_to_me      ,
	input                                sel_to_if      ,
	input                                sel_mem_res_in ,
	//jump conctrl
	input                                jump           ,
	input                                cond_jump      ,
	//write register
	input                                reg_w_en_in    ,
	input     [`REG_FILE_ADDR_WIDTH-1:0] rd_addr_in     ,
	//mem conctrl
	input                                mem_r_en_in    ,
	input                                mem_w_en_in    ,
	input     [2:0]                      mem_sign_in    ,
	input     [2:0]                      mem_whb_in     ,
	input     [`DATA_WIDTH-1:0]          mem_data_in    ,	

	//to me
	output reg                           reg_w_en_out   ,
	output reg[`REG_FILE_ADDR_WIDTH-1:0] rd_addr_out    ,

	output reg                           mem_r_en_out   ,
	output reg                           mem_w_en_out   ,
	output reg[2:0]                      mem_sign_out   ,
	output reg[2:0]                      mem_whb_out    , 
	output reg[`DATA_WIDTH-1:0]          mem_data_out   ,	

	output reg                           sel_mem_res_out,   
	output    [`DATA_WIDTH-1:0]          res            ,

	
	//for branch hazard
	output                               jump_en        ,
	output    [`DATA_WIDTH-1:0]          jump_addr      ,

	//for data hazard
	input                                flush          ,
	output                               pb_mem_r_en    ,
	output                               pb_reg_w_en    ,
	output    [`REG_FILE_ADDR_WIDTH-1:0] pb_rd_addr     ,
	output    [`DATA_WIDTH-1:0]          pb_reg_data     
);

	reg [`DATA_WIDTH-1:0]          opd1_q     ;
	reg [`DATA_WIDTH-1:0]          opd2_q     ;
	reg [`DATA_WIDTH-1:0]          base_q     ;
	reg [`DATA_WIDTH-1:0]          offset_q   ;
	reg [`DATA_WIDTH-1:0]          mem_data_q ;

	reg [4:0]                      op_q       ; 
	reg [2:0]                      sel_to_me_q;
	reg                            sel_to_if_q;
	reg                            jump_q     ;
	reg                            cond_jump_q;

	always @(posedge clk) begin
		if (!_rst || flush || jump_en) begin
			opd1_q          <= `DATA_WIDTH'b0         ; 
			opd2_q          <= `DATA_WIDTH'b0         ; 
			base_q          <= `DATA_WIDTH'b0         ; 
			offset_q        <= `DATA_WIDTH'b0         ; 
			mem_data_out    <= `DATA_WIDTH'b0         ; 
			rd_addr_out     <= `REG_FILE_ADDR_WIDTH'b0;
 
			op_q            <= `ADD_OP                ;
			sel_to_me_q     <= 2'h0                   ;
			sel_to_if_q     <= 1'b0                   ;
			sel_mem_res_out <= 1'b0                   ;
			jump_q          <= 1'b0                   ;
			cond_jump_q     <= 1'b0                   ;
			reg_w_en_out    <= 1'b0                   ;
			mem_r_en_out    <= 1'b0                   ;
			mem_w_en_out    <= 1'b0                   ;
			mem_sign_out    <= 3'b0                   ;
			mem_whb_out     <= 3'b0                   ;
			
		end
		else begin
			opd1_q          <= opd1                   ; 
			opd2_q          <= opd2                   ; 
			base_q          <= base                   ; 
			offset_q        <= offset                 ; 
			mem_data_out    <= mem_data_in            ;
			rd_addr_out     <= rd_addr_in             ;
 
			op_q            <= op                     ;
			sel_to_me_q     <= sel_to_me              ;
			sel_to_if_q     <= sel_to_if              ;
			sel_mem_res_out <= sel_mem_res_in         ;
			jump_q          <= jump                   ;
			cond_jump_q     <= cond_jump              ;
			reg_w_en_out    <= reg_w_en_in            ;
			mem_r_en_out    <= mem_r_en_in            ;
			mem_w_en_out    <= mem_w_en_in            ;
			mem_sign_out    <= mem_sign_in            ;
			mem_whb_out     <= mem_whb_in             ;
			
		end
	end

	wire[`DATA_WIDTH-1:0] deputy_res;
	reg [`DATA_WIDTH-1:0] main_res  ;
	reg                   cond      ;

	assign jump_en     = jump_q || cond && cond_jump_q      ;
	assign jump_addr   = sel_to_if_q ? main_res : deputy_res;
	assign res         = sel_to_me_q ? deputy_res: main_res ; 
	assign pb_mem_r_en = mem_r_en_out                       ;
	assign pb_reg_w_en = reg_w_en_out                       ;
	assign pb_rd_addr  = rd_addr_out                        ;
	assign pb_reg_data = res                                ;

	assign deputy_res = base_q + offset_q; 
	always @(*) begin
		main_res = `DATA_WIDTH'b0;
		cond     = 1'b0          ;
		case(op_q)
			`ADD_OP  :main_res = opd1_q +  opd2_q                                  ;
			`SUB_OP  :main_res = opd1_q -  opd2_q                                  ;
			`XOR_OP  :main_res = opd1_q ^  opd2_q                                  ; 
			`OR_OP   :main_res = opd1_q |  opd2_q                                  ; 
			`AND_OP  :main_res = opd1_q &  opd2_q                                  ; 
			`SLL_OP  :main_res = opd1_q << opd2_q[4:0]                             ; 
			`SRL_OP  :main_res = opd1_q >> opd2_q[4:0]                             ;
			`SRA_OP  :main_res = $signed(opd1_q) >>> opd2_q[4:0]                   ;
			`SLT_OP  :main_res = ($signed(opd1_q) < $signed(opd2_q))  ?32'b1 :32'b0;
			`SLTU_OP :main_res = (opd1_q <  opd2_q)                   ?32'b1 :32'b0;
			`BEQ_OP  :cond     = (opd1_q == opd2_q)                   ? 1'b1 : 1'b0;
			`BNE_OP  :cond     = (opd1_q != opd2_q)                   ? 1'b1 : 1'b0;
			`BLT_OP  :cond     = ($signed(opd1_q) <  $signed(opd2_q)) ? 1'b1 : 1'b0;
			`BGE_OP  :cond     = ($signed(opd1_q) >= $signed(opd2_q)) ? 1'b1 : 1'b0;
			`BLTU_OP :cond     = (opd1_q <  opd2_q)                   ? 1'b1 : 1'b0;
			`BGEU_OP :cond     = (opd1_q >= opd2_q)                   ? 1'b1 : 1'b0;
		endcase
	end


endmodule