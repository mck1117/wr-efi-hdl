module output_driver(clk, reset_n, en, tooth_num, tooth_edge, start_tooth, end_tooth, start_counts, end_counts, out);
	parameter timer_length = 24;

	input clk, reset_n, en;
	
	input [7:0] tooth_num;
	input tooth_edge;

	input [7:0] start_tooth, end_tooth;

	input [timer_length-1:0] start_counts, end_counts;
	
	output out;

	parameter STATE_IDLE = 3'd0;
	parameter STATE_WAIT_SECOND_TOOTH = 3'd1;
	parameter STATE_WAIT_EXPIRY = 3'd2;

	reg [2:0] state = STATE_IDLE;
	
	wire timer_output_rising, timer_output_falling;
	
	reg [timer_length-1:0] start_counts_latched, end_counts_latched;
	reg [7:0] end_tooth_latched;
	
	reg timer_rising_trigger = 0;
	reg timer_falling_trigger = 0;
	
	reg timers_rst = 1;

	// One timer to turn on, and one to turn off
	oneshot_timer tm_rising(clk, reset_n & timers_rst, timer_rising_trigger, timer_output_rising, start_counts_latched);
	oneshot_timer tm_falling(clk, reset_n & timers_rst, timer_falling_trigger, timer_output_falling, end_counts_latched);
	
	// Latch the timer results
	rs_latch ltch(timer_output_rising, timer_output_falling, out);
	
	
	always @(posedge clk) begin
		timer_rising_trigger <= 0;
		timer_falling_trigger <= 0;
		timers_rst <= 1;
	
		case (state)
			STATE_IDLE: begin
				if(en && tooth_edge && tooth_num == start_tooth) begin
					// start 1st timer
					timer_rising_trigger <= 1;
					
					// Latch timer expiry counts
					start_counts_latched <= start_counts;
					end_counts_latched <= end_counts;
					
					if(start_tooth == end_tooth) begin
						// start the falling trigger too
						timer_falling_trigger <= 1;
						// Go to the state where we wait for both timers to expire
						state = STATE_WAIT_EXPIRY;
					end else begin
						end_tooth_latched <= end_tooth;
						
						state = STATE_WAIT_SECOND_TOOTH;
					end
				end
			end
			STATE_WAIT_SECOND_TOOTH: begin
				if(tooth_edge && tooth_num == end_tooth_latched) begin
					// start 2nd timer
					timer_falling_trigger <= 1;
					
					// Wait for the timer to expire
					state = STATE_WAIT_EXPIRY;
				end
			end
			STATE_WAIT_EXPIRY: begin
				if(timer_output_falling) begin
					// Reset timers for the next event (active low)
					timers_rst <= 0;
					
					// Return to normalcy
					state = STATE_IDLE;
				end
			end
		endcase
	end
endmodule
