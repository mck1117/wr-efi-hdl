module synchronizer(clk, d, q);
	input clk, d;
	output reg q;
	
	reg q_inter;
	
	always @(posedge clk) begin
		q_inter <= d;
		q <= q_inter;
	end
	
endmodule
