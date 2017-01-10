module rpm_shift_reg_stage(clk, reset, en, d, q, sum_in, sum_out);
	parameter INPUT_WIDTH = 16;
	parameter SUM_WIDTH = 32;
	
	input clk, reset, en;
	
	input [INPUT_WIDTH - 1:0] d;
	output reg [INPUT_WIDTH - 1:0] q = {INPUT_WIDTH{1'b0}};
	
	input [SUM_WIDTH - 1:0] sum_in;
	output reg [SUM_WIDTH - 1:0] sum_out;
	
	always @(posedge clk) begin
		sum_out <= sum_in + d;
	end
	
	always @(posedge clk) begin
		if(~reset) begin
			q <= {INPUT_WIDTH{1'b0}};
		end else if (en) begin
			q <= d;
		end
	end
endmodule
