module edge_det(clk, in, out);
	input clk, in;
	output out;
	
	reg a, b;
	
	// Was it high this time, and low last time?
	assign out = a & ~b;
	
	always @(posedge clk) begin
		b <= a;
		a <= in;
	end
endmodule
