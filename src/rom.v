module rom#(parameter 
	ADDR_WIDTH,
	WORD_DEPTH
	)(
	input     [ADDR_WIDTH-1:0] addr,
	output reg[31:0]           data
);
	reg[31:0] mem[0:WORD_DEPTH-1];

	always @(*) begin
		data = mem[addr];
	end
endmodule