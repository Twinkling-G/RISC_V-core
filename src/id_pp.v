`include "cpu_property.v"

module id_pp(
	input                                clk        ,
	input                                _rst       ,

	//from if
	input [`INST_WIDTH-1:0]              inst_in    ,
	input [`DATA_WIDTH-1:0]              pc         ,

	//to register file
	output [`REG_FILE_ADDR_WIDTH-1:0]    rs1_addr   ,
	output [`REG_FILE_ADDR_WIDTH-1:0]    rs2_addr   ,

	//from register file
	input [`DATA_WIDTH-1:0]              rs1_in     ,
	input [`DATA_WIDTH-1:0]              rs2_in     ,

	//to ex
	//oprand
	output reg[`DATA_WIDTH-1:0]          opd1       ,
	output reg[`DATA_WIDTH-1:0]          opd2       ,
	output reg[`DATA_WIDTH-1:0]          base       ,
	output reg[`DATA_WIDTH-1:0]          offset     ,
	//alu conctrl
	output reg[4:0]                      op         ,
	//data select
	output reg                           sel_to_me  ,
	output reg                           sel_to_if  ,
	output reg                           sel_mem_res,
	//jump conctrl
	output reg                           jump       ,
	output reg                           cond_jump  ,
	//write register
	output reg                           reg_w_en   ,
	output    [`REG_FILE_ADDR_WIDTH-1:0] rd_addr    ,
	//mem conctrl
	output reg                           mem_r_en   ,
	output reg                           mem_w_en   ,
	output reg[2:0]                      mem_sign   ,
	output reg[2:0]                      mem_whb    ,
	output reg[`DATA_WIDTH-1:0]          mem_data   ,	

	//from ex
	input                                flush      ,

	//for data hazard
	input                                ex_mem_r_en,                           
	input                                ex_reg_w_en,
	input     [`REG_FILE_ADDR_WIDTH-1:0] ex_rd_addr ,
	input     [`DATA_WIDTH-1:0]          ex_reg_data,
	input                                me_reg_w_en,
	input     [`REG_FILE_ADDR_WIDTH-1:0] me_rd_addr ,
	input     [`DATA_WIDTH-1:0]          me_reg_data,
	input                                wb_reg_w_en,
	input     [`REG_FILE_ADDR_WIDTH-1:0] wb_rd_addr ,
	input     [`DATA_WIDTH-1:0]          wb_reg_data,
	output                               insert_nop
);
	
	
	reg [`INST_WIDTH-1:0] inst_q;
	reg [`DATA_WIDTH-1:0] pc_q  ;

	always @(posedge clk) begin
		if (!_rst || flush) begin
			inst_q <= `INST_WIDTH'b110011;//NOP:R0+R0->R0
			pc_q   <= `DATA_WIDTH'b0     ;
		end
		else if (!insert_nop) begin
			inst_q = inst_in;
			pc_q   = pc     ;
		end
	end

	wire[6:0] opcode       ;
	wire[2:0] func3        ;
	wire[6:0] func7        ; 
	wire      haz_rs1_ex_rd;
	wire      haz_rs2_ex_rd;

	reg                   opd1_sel   ;
	reg [1:0]             opd2_sel   ;
	reg [1:0]             base_sel   ;
	reg [1:0]             off_sel    ;
	reg [`DATA_WIDTH-1:0] rs1_y      ;
	reg [`DATA_WIDTH-1:0] rs2_y      ;
	reg                   mem_data_en;
	reg                   insert_nop1;
	reg                   insert_nop2;
	reg                   insert_nop3;
	                                         
	assign opcode        = inst_q[6:0]                            ;
	assign func3         = inst_q[14:12]                          ;
	assign func7         = inst_q[31:25]                          ;
	assign rs1_addr      = inst_q[19:15]                          ;
	assign rs2_addr      = inst_q[24:20]                          ;
	assign rd_addr       = inst_q[11:7]                           ;
	assign insert_nop    = insert_nop1 | insert_nop2 | insert_nop3;
	assign haz_rs1_ex_rd = rs1_addr == ex_rd_addr && ex_reg_w_en  ;
	assign haz_rs2_ex_rd = rs2_addr == ex_rd_addr && ex_reg_w_en  ;
	
	always @(*) begin
		insert_nop1 = 1'b0;
		case(opd1_sel)
			`OPD1_SEL_REG:begin
				insert_nop1 = ex_mem_r_en && haz_rs1_ex_rd;
				opd1        = rs1_y                       ;
			end
			`OPD1_SEL_PC :opd1 = pc_q  ;
		endcase
		
	end

	always @(*) begin
		insert_nop2 = 1'b0;
		case(opd2_sel)
			`OPD2_SEL_REG  :begin
				insert_nop2 = ex_mem_r_en && haz_rs2_ex_rd;
				opd2        = rs2_y                       ;
			end
			`OPD2_SEL_S_IMM:opd2 = {{20{inst_q[31]}},inst_q[31:25],inst_q[11:7]}                            ;
			`OPD2_SEL_J_IMM:opd2 = {{11{inst_q[31]}},inst_q[31],inst_q[19:12],inst_q[20],inst_q[30:21],1'b0};
			`OPD2_SEL_I_IMM:opd2 = {{20{inst_q[31]}},inst_q[31:20]}                                         ;
		endcase
	end

	always @(*) begin
		insert_nop3 = mem_data_en && ex_mem_r_en && haz_rs2_ex_rd;
		mem_data    = rs2_y;
	end

	always @(*) begin
		if (haz_rs1_ex_rd) begin
			rs1_y = ex_reg_data;
		end
		else if (rs1_addr == me_rd_addr && me_reg_w_en ) begin
			rs1_y = me_reg_data;
		end
		else if (rs1_addr == wb_rd_addr && wb_reg_w_en) begin
			rs1_y = wb_reg_data;
		end 
		else begin
			rs1_y = rs1_in;
		end
	end

	always @(*) begin
		if (haz_rs2_ex_rd ) begin
			rs2_y = ex_reg_data;
		end
		else if (rs2_addr == me_rd_addr && me_reg_w_en ) begin
			rs2_y = me_reg_data;
		end
		else if (rs2_addr == wb_rd_addr && wb_reg_w_en ) begin
			rs2_y = wb_reg_data;
		end
		else begin
			rs2_y = rs2_in;
		end
	end


	always @(*) begin
		case(base_sel)
			`BASE_SEL_PC: base = pc_q          ;
			`BASE_SEL_0 : base = `DATA_WIDTH'b0;
		endcase
	end

	always @(*) begin
		case(off_sel)
			`OFF_SEL_4    : offset = `DATA_WIDTH'h4                                                         ;
			`OFF_SEL_B_IMM: offset = {{19{inst_q[31]}},inst_q[31],inst_q[7],inst_q[30:25],inst_q[11:8],1'b0};
			`OFF_SEL_U_IMM: offset = {inst_q[31:12],12'b0}                                                  ;
		endcase
	end

	always @(*) begin
		op          = `ADD_OP       ;
   
		sel_to_me   = 1'b0          ;
		sel_to_if   = 1'b0          ;
		sel_mem_res = 1'b0          ;
   
		jump        = 1'b0          ;
		cond_jump   = 1'b0          ;
   
		reg_w_en    = 1'b0          ;
   
		mem_data_en = 1'b0          ;
		mem_r_en    = 1'b0          ;
		mem_w_en    = 1'b0          ;
		mem_sign    = 3'b000        ;
		mem_whb     = 3'b000        ;
		  
		opd1_sel    = `OPD1_SEL_REG ;
		opd2_sel    = `OPD2_SEL_REG ;
		base_sel    = `BASE_SEL_PC  ;
		off_sel     = `OFF_SEL_4    ;
          
		case(opcode)
			`R_INST:begin
				reg_w_en = 1'b1;
				case(func3)
					3'h0:begin
						case(func7)
							7'h00:op = `ADD_OP;
							7'h20:op = `SUB_OP; 
						endcase
					end
					3'h4:op = `XOR_OP;
					3'h6:op = `OR_OP ;
					3'h7:op = `AND_OP;
					3'h1:op = `SLL_OP;
					3'h5:begin
						case(func7)
							7'h00:op = `SRL_OP;
							7'h20:op = `SRA_OP;
						endcase
					end
					3'h2:op = `SLT_OP ;
					3'h3:op = `SLTU_OP; 
				endcase
			end
			`B_INST:begin        
				off_sel   = `OFF_SEL_B_IMM;                           
				cond_jump = 1'b1          ;
				case(func3)
					3'h0:op = `BEQ_OP ;
					3'h1:op = `BNE_OP ;
					3'h4:op = `BLT_OP ;
					3'h5:op = `BGE_OP ;
					3'h6:op = `BLTU_OP;
					3'h7:op = `BGEU_OP;
				endcase
			end
			`I_INST_1:begin
				opd2_sel = `OPD2_SEL_I_IMM;
				reg_w_en = 1'b1           ;
				case(func3)
					3'h0: op = `ADD_OP;
					3'h4: op = `XOR_OP;
					3'h6: op = `OR_OP ;
					3'h7: op = `AND_OP;
					3'h1: op = `SLL_OP;
					3'h5: begin
						case(inst_q[31:25])
							7'h00:op = `SRL_OP;
							7'h20:op = `SRA_OP;
						endcase
					end
					3'h2: op = `SLT_OP ;
					3'h3: op = `SLTU_OP;
				endcase
			end
			`I_INST_2:begin                       
				opd2_sel    = `OPD2_SEL_I_IMM;
				mem_r_en    = 1'b1           ;
				reg_w_en    = 1'b1           ;
				sel_mem_res = 1'b1           ;
				case(func3)
					3'h0,3'h4:mem_whb = 3'b001;
					3'h1,3'h5:mem_whb = 3'b010;
					3'h2:     mem_whb = 3'b100;
				endcase
				case(func3)
					3'h0:          mem_sign = 3'b001;
					3'h1:          mem_sign = 3'b010;
					3'h2,3'h4,3'h5:mem_sign = 3'b100;
				endcase
			end
			`I_INST_3:begin                         
				opd2_sel    = `OPD2_SEL_I_IMM;
				jump        = 1'b1           ;
				reg_w_en    = 1'b1           ;
				sel_to_me   = 1'b1           ;
				sel_to_if   = 1'b1           ;
			end
			`I_INST_4:begin
				case(inst_q[31:20])
					12'h0:op = `ECALL_OP ;
					12'h1:op = `EBREAK_OP;
				endcase
			end
			`S_INST:begin
				opd2_sel    = `OPD2_SEL_S_IMM;
				mem_w_en    = 1'b1           ;
				mem_data_en = 1'b1           ;
				case(func3)
					3'h0,3'h4:mem_whb = 3'b001;
					3'h1,3'h5:mem_whb = 3'b010;
					3'h2:     mem_whb = 3'b100;
				endcase
			end
			`U_INST_1:begin
				base_sel  = `BASE_SEL_0   ;
				off_sel   = `OFF_SEL_U_IMM;
				reg_w_en  = 1'b1          ; 
				sel_to_me = 1'b1          ;
			end
			`U_INST_2:begin
				off_sel   = `OFF_SEL_U_IMM;
				reg_w_en  = 1'b1          ;
				sel_to_me = 1'b1          ; 
			end
			`J_INST:begin
				opd1_sel    = `OPD1_SEL_PC   ;
				opd2_sel    = `OPD2_SEL_J_IMM;
				jump        = 1'b1           ;
				reg_w_en    = 1'b1           ;
				sel_to_me   = 1'b1           ;
				sel_to_if   = 1'b1           ;
			end
		endcase

		if(rd_addr == `REG_FILE_ADDR_WIDTH'b0) begin
			reg_w_en = 1'b0;
		end
	end
endmodule