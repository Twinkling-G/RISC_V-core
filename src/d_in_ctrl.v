module d_in_ctrl(
	input      [3:0]  sel  ,
	input      [1:0]  addr ,
	input      [31:0] d_in ,
	output  reg[31:0] d_out
	);

	wire[31:0] d;
	assign d = {{8{sel[3]}},{8{sel[2]}},{8{sel[1]}},{8{sel[0]}}} & d_in;
	
	always @(*) begin
		d_out = 32'b0;
		case(addr)
			2'b00:
				d_out = d;
			2'b01:
				d_out[7:0] = d[15:8];
			2'b10:
				d_out[15:0] = d[31:16];
			2'b11:
				d_out[7:0] = d[31:24];
		endcase
	end	
endmodule