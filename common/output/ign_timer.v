module ign_timer(clk, trigger, timing, eng_phase, next_tooth_width, tooth_period, out);
	input clk, trigger;
	
	input [15:0] timing;
	input [15:0] eng_phase;
	input [15:0] next_tooth_width;
	input [31:0] tooth_period;
	
	output reg out;
	
	initial out <= 0;
	
	reg [31:0] cnt = 0;
	reg [31:0] cnt_trigger = 0;
	reg cnt_running = 0;
	
		
	always @(posedge clk) begin
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
			if(timing > eng_phase && timing <= (eng_phase + next_tooth_width + 2)) begin
				cnt <= 0;
				//cnt_trigger = (tooth_period * (timing - (eng_phase << 3))) / 48 - 3;
				cnt_trigger = ((tooth_period * (timing - eng_phase)) >> 7) - 3;
				cnt_running <= 1;
			end
		end
	end
endmodule