module ign_timer(clk, reset_n, trigger, timing, eng_phase, next_tooth_width, tooth_period, out);
	input clk, reset_n, trigger;
	
	input [15:0] timing;
	input [15:0] eng_phase;
	input [15:0] next_tooth_width;
	input [31:0] tooth_period;
	
	output reg out;
	
	initial out <= 0;
	
	reg [31:0] cnt = 0;
	reg [31:0] cnt_trigger = 0;
	reg cnt_running = 0;
	
		
		
	wire signed [16:0] quanta_until_expiry_raw = timing - eng_phase;
	
	reg [15:0] quanta_until_expiry;
	
	always @(*) begin
		if(quanta_until_expiry_raw < 0) begin
			quanta_until_expiry <= 16'd15360 + quanta_until_expiry_raw;
		end else begin
			quanta_until_expiry <= quanta_until_expiry_raw;
		end
	end
		
		
		
	always @(posedge clk) begin
		if(~reset_n) begin
			cnt = 32'd0;
			cnt_trigger = 32'd0;
			cnt_running = 0;
			
			out <= 0;
		end else begin
			out <= 0;
		
			if(cnt_running) begin
				if(cnt >= cnt_trigger) begin
					out <= 1;
					cnt_running <= 0;
				end else begin
					cnt <= cnt + 1;
				end
			end
		
			if(trigger & ~cnt_running) begin
				// Ignition event will happen before next tooth
				if(quanta_until_expiry <= next_tooth_width + 20 && quanta_until_expiry != 0) begin
					cnt <= 0;
					//cnt_trigger = (tooth_period * (timing - (eng_phase << 3))) / 48 - 3;
					cnt_trigger = ((tooth_period * quanta_until_expiry) >> 8) - 6;
					cnt_running <= 1;
				end
			end
		end
	end
endmodule