module sync(clk, vrin, eng_phase, trigger, synced, next_tooth_length_deg, tooth_period, trigger_tooth_cnt, trigger_tooth_width_deg, trigger_teeth_missing, trigger_offset);
	input clk, vrin;
	
	input [15:0] trigger_tooth_cnt;
	input [15:0] trigger_tooth_width_deg;
	input [15:0] trigger_teeth_missing;
	input [15:0] trigger_offset;
	
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
	reg [3:0] st = 0;
	
	// How many teeth do we expect before the next long tooth?
	reg [15:0] teeth_until_long = 0;
	
	always @(posedge clk) begin
		trigger <= 0;
	
		if(vr_edge) begin
			// Reset count
			cnt <= 32'd0;
			
			trigger <= 1;
		
			// Did we get a valid short tooth?
			if(cnt > expect_min && cnt < expect_max) begin
				expect_min <= cnt - (cnt >> 1);
				expect_max <= cnt + (cnt >> 1);
				
				if(teeth_until_long == 0) begin
					st <= 4'd0;
				
					synced <= 0;
				end else begin
					st <= 4'd1;
					
					tooth_period <= cnt + 1;
					
					eng_phase <= eng_phase + trigger_tooth_width_deg;
				
					teeth_until_long = teeth_until_long - 1;
					
					next_tooth_length_deg = (teeth_until_long == 0) ? ((trigger_teeth_missing + 1) * trigger_tooth_width_deg) : trigger_tooth_width_deg;
				end
			end else if (cnt > (expect_min * 3) && cnt < (expect_max * 3)) begin
				if(teeth_until_long == 0) begin
					st <= 4'd2;
				
					// We have achieved sync
					synced <= 1;
					
					// Reset tooth counter
					teeth_until_long <= trigger_tooth_cnt - trigger_teeth_missing - 1;
					
					next_tooth_length_deg <= trigger_tooth_width_deg;
					
					eng_phase <= trigger_offset;
				end else begin
					st <= 4'd3;
				
					// We got a long tooth when we didn't expect
					synced <= 0;
				end
			end else begin
				st <= 4'd4;
				synced <= 0;
				
				expect_min <= 32'h0;
				expect_max <= 32'hffffffff;
			end
		
		end else begin		
			// Timeout after no pulse
			if(((teeth_until_long == 0) && (cnt > expect_max * (trigger_teeth_missing + 1))) ||
			   ((teeth_until_long != 0) && (cnt > expect_max))) begin
				cnt <= 0;
				synced <= 0;
				
				expect_min <= 32'h0;
				expect_max <= 32'hffffffff;
			end else begin
				cnt <= cnt + 1;
			end
		end
	end
endmodule
