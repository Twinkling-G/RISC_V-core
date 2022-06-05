`include "cpu_property.v"
module core(
	input                            clk      ,
	input                            _rst     ,

	//to instruction mem 
	output    [`INST_ADDR_WIDTH-1:0] inst_addr,

	//from instruction mem 
	input  reg[`INST_WIDTH-1:0]      inst     ,

	//to data mem
	output                           data_w_en,
	output                           data_r_en,
	output    [3:0]                  data_sel ,
	output    [`DATA_ADDR_WIDTH-1:0] data_addr,
	output    [`DATA_WIDTH-1:0]      data_out ,

	//from data mem
	input     [`DATA_WIDTH-1:0]      data_in
);
	//====================if==========================

	//to id
	wire [`INST_WIDTH-1:0]          if_inst     ;
	wire [`INST_ADDR_WIDTH-1:0]     if_pc       ;

	//====================id==========================

	//to register file
	wire [`REG_FILE_ADDR_WIDTH-1:0] id_rs1_addr   ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] id_rs2_addr   ;
	
	//to ex
	//oprand
	wire [`DATA_WIDTH-1:0]          id_opd1       ;
	wire [`DATA_WIDTH-1:0]          id_opd2       ;
	wire [`DATA_WIDTH-1:0]          id_base       ;
	wire [`DATA_WIDTH-1:0]          id_offset     ;
	//alu conctrl
	wire [4:0]                      id_op         ;
	//data select
	wire                            id_sel_to_me  ;
	wire                            id_sel_to_if  ;
	wire                            id_sel_mem_res;
	//jump conctrl
	wire                            id_jump       ;
	wire                            id_cond_jump  ;
	//write register
	wire [`REG_FILE_ADDR_WIDTH-1:0] id_rd_addr    ;
	wire                            id_reg_w_en   ;
	//mem conctrl
	wire                            id_mem_r_en   ;
	wire                            id_mem_w_en   ;
	wire [2:0]                      id_mem_sign   ;
	wire [2:0]                      id_mem_whb    ;
	wire [`DATA_WIDTH-1:0]          id_mem_data   ;	

	//for data hazard                           
	wire                            id_insert_nop ;

	//====================ex==========================
	//from ex
	//to me
	wire                            ex_reg_w_en   ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] ex_rd_addr    ;
   
	wire                            ex_mem_r_en   ;
	wire                            ex_mem_w_en   ;
	wire [2:0]                      ex_mem_sign   ;
	wire [2:0]                      ex_mem_whb    ; 
	wire [`DATA_WIDTH-1:0]          ex_mem_data   ;

	wire                            ex_sel_mem_res;   
	wire [`DATA_WIDTH-1:0]          ex_res        ;

	//for data hazard
	wire                            ex_pb_mem_r_en;
	wire                            ex_pb_reg_w_en;
	wire [`REG_FILE_ADDR_WIDTH-1:0] ex_pb_rd_addr ;
	wire [`DATA_WIDTH-1:0]          ex_pb_reg_data;

	//for branch hazard
	wire                            ex_jump_en    ;
	wire [`DATA_WIDTH-1:0]          ex_jump_addr  ;


	//====================me==========================
	//from me
	wire                            me_reg_w_en    ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] me_rd_addr     ;
	wire [`DATA_WIDTH-1:0]          me_reg_data    ;   

	//to data ram
	wire                            me_mem_r_en    ;  
	wire                            me_mem_w_en    ;
	wire [3:0]                      me_mem_sel     ;
	wire [`DATA_ADDR_WIDTH-1:0]     me_mem_addr    ;
	wire [`DATA_ADDR_WIDTH-1:0]     me_mem_data    ;

	//for data hazard
	wire                            me_pb_reg_w_en ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] me_pb_rd_addr  ;
	wire [`DATA_WIDTH-1:0]          me_pb_reg_data ;  

	//====================wb==========================
	//from wb
	wire                            wb_reg_w_en    ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] wb_rd_addr     ;
	wire [`DATA_WIDTH-1:0]          wb_reg_data    ;

	//for data hazard
	wire                            wb_pb_reg_w_en ;
	wire [`REG_FILE_ADDR_WIDTH-1:0] wb_pb_rd_addr  ;
	wire [`DATA_WIDTH-1:0]          wb_pb_reg_data ;

	//====================rf==========================
	//to id
	wire [`DATA_WIDTH-1:0]          rf_rs1;
	wire [`DATA_WIDTH-1:0]          rf_rs2;


	//====================core========================
	
	if_pp if_pp_o(
		.clk      (clk          ),
		._rst     (_rst         ),
	  
		//from ex
		.jump_en  (ex_jump_en   ),
		.jump_addr(ex_jump_addr ),

		//to instruction mem 
		.inst_addr(inst_addr ),

		//from instruction mem
		.inst_in  (inst         ),
		
		//to id
		.inst_out (if_inst      ),
		.pc       (if_pc        ),

		//for data hazard 
		.stall    (id_insert_nop)
		);
	id_pp id_pp_o(
		.clk        (clk           ),
		._rst       (_rst          ),

		//from if
		.inst_in    (if_inst       ),
		.pc         (if_pc         ),

		//to register file
		.rs1_addr   (id_rs1_addr   ),
		.rs2_addr   (id_rs2_addr   ),

		//from register file
		.rs1_in     (rf_rs1        ),
		.rs2_in     (rf_rs2        ),

		//to ex
		//oprand
		.opd1       (id_opd1       ),
		.opd2       (id_opd2       ),
		.base       (id_base       ),
		.offset     (id_offset     ),
		//alu conctrl
		.op         (id_op         ),
		//data select
		.sel_to_me  (id_sel_to_me  ),
		.sel_to_if  (id_sel_to_if  ),
		.sel_mem_res(id_sel_mem_res),
		//jump conctrl
		.jump       (id_jump       ),
		.cond_jump  (id_cond_jump  ),
		//write register
		.rd_addr    (id_rd_addr    ),
		.reg_w_en   (id_reg_w_en   ),
		//mem conctrl
		.mem_r_en   (id_mem_r_en   ),
		.mem_w_en   (id_mem_w_en   ),
		.mem_sign   (id_mem_sign   ),
		.mem_whb    (id_mem_whb    ),
		.mem_data   (id_mem_data   ),	

		//from ex
		.flush      (ex_jump_en    ),

		//for data hazard       
		.ex_mem_r_en(ex_pb_mem_r_en),                    
		.ex_reg_w_en(ex_pb_reg_w_en),
		.ex_rd_addr (ex_pb_rd_addr ),
		.ex_reg_data(ex_pb_reg_data),
		.me_reg_w_en(me_pb_reg_w_en),
		.me_rd_addr (me_pb_rd_addr ),
		.me_reg_data(me_pb_reg_data),
		.wb_reg_w_en(wb_pb_reg_w_en),
		.wb_rd_addr (wb_pb_rd_addr ),
		.wb_reg_data(wb_pb_reg_data),
		.insert_nop (id_insert_nop )
		);
	ex_pp ex_pp_o(
		.clk            (clk           ),
		._rst           (_rst          ),
	 
		//from id 
		//oprand
		.opd1           (id_opd1       ),
		.opd2           (id_opd2       ),
		.base           (id_base       ),
		.offset         (id_offset     ),
		//alu conctrl
		.op             (id_op         ),
		//data select
		.sel_to_me      (id_sel_to_me  ),
		.sel_to_if      (id_sel_to_if  ),
		.sel_mem_res_in (id_sel_mem_res),
		//jump conctrl
		.jump           (id_jump       ),
		.cond_jump      (id_cond_jump  ),
		//write register
		.reg_w_en_in    (id_reg_w_en   ),
		.rd_addr_in     (id_rd_addr    ),
		//mem conctrl
		.mem_r_en_in    (id_mem_r_en   ),
		.mem_w_en_in    (id_mem_w_en   ),
		.mem_sign_in    (id_mem_sign   ),
		.mem_whb_in     (id_mem_whb    ),
		.mem_data_in    (id_mem_data   ),	

		//to me
		.reg_w_en_out   (ex_reg_w_en   ),
		.rd_addr_out    (ex_rd_addr    ),

		.mem_r_en_out   (ex_mem_r_en   ),
		.mem_w_en_out   (ex_mem_w_en   ),
		.mem_sign_out   (ex_mem_sign   ),
		.mem_whb_out    (ex_mem_whb    ), 
		.mem_data_out   (ex_mem_data   ),

		.sel_mem_res_out(ex_sel_mem_res),   
		.res            (ex_res        ),

		//for data hazard
		.flush          (id_insert_nop ),
		.pb_mem_r_en    (ex_pb_mem_r_en),
		.pb_reg_w_en    (ex_pb_reg_w_en),
		.pb_rd_addr     (ex_pb_rd_addr ),
		.pb_reg_data    (ex_pb_reg_data),

		//for branch hazard
		.jump_en        (ex_jump_en    ),
		.jump_addr      (ex_jump_addr  )
		);
	me_pp me_pp_o(
		.clk           (clk           ),
		._rst          (_rst          ),
		
		//from ex
		.reg_w_en_in   (ex_reg_w_en   ),
		.rd_addr_in    (ex_rd_addr    ),

		.mem_r_en_in   (ex_mem_r_en   ),
		.mem_w_en_in   (ex_mem_w_en   ),
		.mem_sign      (ex_mem_sign   ),
		.mem_whb       (ex_mem_whb    ),
		.mem_data_in   (ex_mem_data   ),

		.sel_mem_res   (ex_sel_mem_res),   
		.res           (ex_res        ),
			
		//to wb
		.reg_w_en_out  (me_reg_w_en   ),
		.rd_addr_out   (me_rd_addr    ),
		.reg_data      (me_reg_data   ),   

		//to data ram
		.mem_r_en_out  (data_r_en     ),  
		.mem_w_en_out  (data_w_en     ),
		.mem_sel       (data_sel      ),
		.mem_addr_out  (data_addr     ),
		.data_out      (data_out      ),

		//from data ram
		.data_in       (data_in       ),

		//for data hazard
		.pb_reg_w_en   (me_pb_reg_w_en),
		.pb_rd_addr    (me_pb_rd_addr ),
		.pb_reg_data   (me_pb_reg_data) 
		);
	wb_pp wb_pp_o(
		.clk           (clk           ), 
		._rst          (_rst          ), 
		//from me
		.reg_w_en_in   (me_reg_w_en   ),
		.rd_addr_in    (me_rd_addr    ), 
		.reg_data_in   (me_reg_data   ),   

		//to register file
		.reg_w_en_out  (wb_reg_w_en   ),
		.rd_addr_out   (wb_rd_addr    ),
		.reg_data_out  (wb_reg_data   ),

		//for data hazard
		.pb_reg_w_en   (wb_pb_reg_w_en),
		.pb_rd_addr    (wb_pb_rd_addr ),
		.pb_reg_data   (wb_pb_reg_data)  
		);

	reg_file rf(
		.clk     (clk ),
		._rst    (_rst), 

		//from id
		.rs1_addr(id_rs1_addr),
		.rs2_addr(id_rs2_addr),

		//to id
		.rs1     (rf_rs1),
		.rs2     (rf_rs2),

		//from wb
		.w_en    (wb_reg_w_en),
		.rd_addr (wb_rd_addr ), 
		.w_in    (wb_reg_data)
		);
	
endmodule