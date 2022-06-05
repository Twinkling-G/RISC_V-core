module ram #(parameter 
	ADDR_WIDTH,
	WORD_DEPTH
	)(
	input                  clk     ,
	input                  _rst    ,
	input                  w_en    ,
	input [3:0]            sel     ,
	input [ADDR_WIDTH-1:0] w_addr  ,
	input [31:0]           data_in ,
	input [ADDR_WIDTH-1:0] r_addr  ,
	output[31:0]           data_out 
);

	reg[31:0] mem[0:WORD_DEPTH-1];	
	//RD
	assign data_out[7:0]   = mem[r_addr][7:0]  ;
	assign data_out[15:8]  = mem[r_addr][15:8] ;
	assign data_out[23:16] = mem[r_addr][23:16];
	assign data_out[31:24] = mem[r_addr][31:24];

	always @(posedge clk) begin
		//WR
		if(w_en)begin
			if(sel[0]) mem[w_addr][7:0]   <= data_in[7:0]  ;
			if(sel[1]) mem[w_addr][15:8]  <= data_in[15:8] ;
			if(sel[2]) mem[w_addr][23:16] <= data_in[23:16];
			if(sel[3]) mem[w_addr][31:24] <= data_in[31:24];
		end
	end
endmodule