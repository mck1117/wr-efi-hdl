module clk_div(clk_in, clk_out);
	parameter RATIO = 100;
	parameter BITS = 7;
	
	input clk_in;
	output reg clk_out;
	initial clk_out = 0;
	
	reg [BITS - 1:0] cnt;
	
	initial cnt = 0;
	
	always @(posedge clk_in) begin
		if(cnt == RATIO / 2) begin
			clk_out = ~clk_out;
			cnt <= 0;
		end else begin
			cnt <= cnt + 1;
		end
	end
endmodule
