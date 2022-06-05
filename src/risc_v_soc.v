`include "cpu_property.v"
module risc_v_soc(
	input clk ,
	input _rst     
);
	//===========rom==============
	wire [`DATA_WIDTH-1:0]      inst_rom_data;
	//===========ram==============
	wire [`DATA_WIDTH-1:0]      data_ram_data;
	//===========core=============
	wire [`INST_ADDR_WIDTH-1:0] core_inst_addr;
	wire                        core_data_w_en;
	wire                        core_data_r_en;
	wire [3:0]                  core_data_sel ;
	wire [`DATA_ADDR_WIDTH-1:0] core_data_addr;
	wire [`DATA_WIDTH-1:0]      core_data     ;

	//===========soc==============
	rom#(13,8192) inst_rom(
		.addr(core_inst_addr[14:2]),
		.data(inst_rom_data       )
		);
	ram#(13,8192) data_ram(
		.clk     (clk                 ),
		._rst    (_rst                ),
		.w_en    (core_data_w_en      ),
		.sel     (core_data_sel       ),
		.w_addr  (core_data_addr[14:2]),
		.data_in (core_data           ),
		.r_addr  (core_data_addr[14:2]),
		.data_out(data_ram_data       )
		);
	core core_o(
		.clk      (clk           ),
		._rst     (_rst          ),

		//to instruction mem 
		.inst_addr(core_inst_addr),

		//from instruction mem 
		.inst     (inst_rom_data ),

		//to data mem
		.data_w_en(core_data_w_en),
		.data_r_en(core_data_r_en),
		.data_sel (core_data_sel ),
		.data_addr(core_data_addr),
		.data_out (core_data     ),

		//from data mem
		.data_in  (data_ram_data )
		); 

endmodule