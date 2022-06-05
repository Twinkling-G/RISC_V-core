module d_out_ctrl(
	input      [3:0]  sel  ,
	input      [1:0]  addr ,
	input      [31:0] d_in ,
	output     [31:0] d_out
	);

	reg [31:0] d;

	assign d_out = {{8{sel[3]}},{8{sel[2]}},{8{sel[1]}},{8{sel[0]}}} & d;

	always @(*) begin
		d = 32'b0;
		case(addr)
			2'b00:
				d = d_in;
			2'b01:
				d[15:8] = d_in[7:0];
			2'b10:
				d[31:16] = d_in[15:0];
			2'b11:
				d[31:24] = d_in[7:0];
		endcase
	end

		
endmodule