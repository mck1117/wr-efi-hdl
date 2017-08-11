module rs_latch(r, s, q);
	input r, s;
	output reg q = 0;
	
	always @(*) begin
		q <= q;
		if(r) q <= 0;
		else if(s) q <= 1;
	end
endmodule
