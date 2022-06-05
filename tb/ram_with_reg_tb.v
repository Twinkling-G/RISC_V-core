module ram_with_reg_tb();
	reg        clk   ;
	reg        _rst  ;
	reg        w_en  ;
	reg  [3 :0]sel   ;
	reg  [9 :0]r_addr;
	reg  [31:0]d_in  ;
	reg  [9 :0]w_addr;
	wire [31:0]d_out ;
	
	ram#(1024,10) ram_o(clk,_rst,w_en,sel,w_addr,d_in,r_addr,d_out);

	initial begin
		clk = 1'b1;
		forever #20 clk = ~clk; 
	end

	initial begin
		_rst = 1'b0;
		#20 _rst = 1'b1;
	end

	initial begin
		d_in   = 32'hFF0000AA;
		w_addr = 10'h001     ;
		r_addr = 10'h000     ;
		w_en   = 1'b1        ;
		sel    = 4'b1111     ;
		#20
		#40
		d_in   = 32'h550000C3;
		w_addr = 10'h002     ; 
		w_en   = 1'b1        ;
		sel    = 4'b1111     ;
		#40
		r_addr = 10'h002     ;
		w_en   = 1'b0        ;
		#40
		d_in   = 32'hCCCC3333;
		w_addr = 10'h000     ; 
		w_en   = 1'b1        ;
		sel    = 4'b1111     ;
		r_addr = 10'h000     ;
		#40
		d_in   = 32'h00007e00;
		w_addr = 10'h001     ; 
		w_en   = 1'b1        ;
		sel    = 4'b0010     ;
		r_addr = 10'h001     ;
	end

endmodule