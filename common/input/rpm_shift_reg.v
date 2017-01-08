module rpm_shift_reg(clk, reset, en, input_sample, output_sum);
	parameter LENGTH_INPUT = 16;
	parameter LENGTH_SUM = 32;
	parameter COUNT_SUMS = 32;
	
	input clk, reset, en;
	
	input [LENGTH_INPUT - 1:0] input_sample;
	output [LENGTH_SUM - 1:0] output_sum;

	
	wire [LENGTH_INPUT - 1:0] shift [COUNT_SUMS - 1:0];
	wire [LENGTH_SUM - 1:0] sums [COUNT_SUMS - 1:0];
	
	
	rpm_shift_reg_stage first(clk, reset, en, input_sample, shift[0], 32'd0, sums[0]);
	
	assign output_sum = sums[COUNT_SUMS - 1];
	
	genvar i;
	generate for (i = 0; i < COUNT_SUMS - 1; i = i + 1) begin : gen_loop
		rpm_shift_reg_stage s(clk, reset, en, shift[i], shift[i + 1], sums[i], sums[i + 1]);
	end endgenerate
	
endmodule
