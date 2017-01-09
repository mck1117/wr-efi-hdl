module sync(clk, reset_n, vrin, eng_phase, trigger, synced, next_tooth_length_deg, tooth_period, trigger_tooth_cnt, trigger_teeth_missing);
	input clk, reset_n, vrin;
	
	input [15:0] trigger_tooth_cnt;
	input [15:0] trigger_teeth_missing;
	
	output reg trigger;
	output reg [15:0] next_tooth_length_deg;
	
	output reg [15:0] eng_phase;
	
	initial eng_phase <= 0;
	
	reg [31:0] cnt = 32'h0;
	output reg [31:0] tooth_period;
	
	wire vr_edge;
	
	edge_det vr_edge_det(clk, vrin, vr_edge);
	
	
	reg [31:0] expect_min, expect_max;
	output reg synced;
	initial synced <= 0;
	
	
	initial expect_min = 0;
	initial expect_max = 32'hffffffff;
	
	// Debug state variable (optimized out for synth)
	reg [2:0] st = 3'd7;
	
	// How many teeth do we expect before the next long tooth?
	reg [15:0] teeth_until_long = 0;
	
	reg half_reset = 0;
	
	always @(posedge clk) begin
		if(~reset_n) begin
			trigger <= 0;
			next_tooth_length_deg <= 16'd0;
			eng_phase <= 16'd0;
			cnt <= 16'd0;
			tooth_period <= 16'd0;
			expect_min = 0;
			expect_max = 32'hffffffff;
			synced <= 0;
			teeth_until_long = 0;
			
			half_reset <= 0;
			
			st <= 3'd7;
		end else begin
			trigger <= 0;
		
			if(vr_edge) begin
				// When we get an edge actually start listening
				half_reset <= 1;
			
				if(half_reset) begin
					// Reset count
					cnt <= 32'd0;
					
					// Only output trigger if synced
					trigger <= synced;
				
					// Did we get a valid short tooth?
					if(cnt > expect_min && cnt < expect_max) begin
						expect_min <= cnt - (cnt >> 1);	// 75%
						expect_max <= cnt + (cnt >> 1);	// 125%
						
						if(teeth_until_long == 0) begin
							st <= 3'd0;
						
							synced <= 0;
						end else begin
							st <= 3'd1;
							
							tooth_period <= cnt + 1;
							
							eng_phase <= eng_phase + 16'd256;	// One tooth is 256 quanta
						
							teeth_until_long = teeth_until_long - 1;
							
							next_tooth_length_deg = (teeth_until_long == 0) ? ((trigger_teeth_missing + 1) * 16'd256) : 16'd256;
						end
					end else if (cnt > (expect_min * 3) && cnt < (expect_max * 3)) begin
						if(teeth_until_long == 0) begin
							st <= 3'd2;
						
							// We have achieved sync
							synced <= 1;
							
							// Reset tooth counter
							teeth_until_long <= trigger_tooth_cnt - trigger_teeth_missing - 1;
							
							// The next tooth after the long tooth is always a normal length tooth
							next_tooth_length_deg <= 16'd256;
							
							eng_phase <= 16'd0;
						end else begin
							st <= 3'd3;
						
							// We got a long tooth when we didn't expect
							synced <= 0;
						end
					end else begin
						st <= 3'd4;
						synced <= 0;
						
						expect_min <= 32'h0;
						expect_max <= 32'hffffffff;
					end
				end
			end else begin		
				// Timeout after no pulse
				if(((teeth_until_long == 0) && (cnt > expect_max * (trigger_teeth_missing + 1))) ||
				   ((teeth_until_long != 0) && (cnt > expect_max))) begin
					st <= 3'd5;
				   
					cnt <= 0;
					synced <= 0;
					
					expect_min <= 32'h0;
					expect_max <= 32'hffffffff;
				end else begin
					// If we aren't in the process of resetting,
					// add to count.  We don't count while under half_reset
					// so we don't confuse ourselves with a runt at the beginning
					if (half_reset) begin
						cnt <= cnt + 1;
					end
				end
			end
		end
	end
endmodule
