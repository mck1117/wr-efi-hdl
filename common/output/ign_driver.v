module ign_driver(clk, reset_n, en, trigger, eng_phase, ign_timing, dwell_angle, cyl_phase, spk_out, next_tooth_width, tooth_period, quanta_per_revolution);	
	input clk, reset_n, en, trigger;
	
	input [15:0] eng_phase;
	input [15:0] ign_timing;
	input [15:0] dwell_angle;
	input [15:0] cyl_phase;
	input [15:0] next_tooth_width;
	input [31:0] tooth_period;
	input [15:0] quanta_per_revolution;
	
	output spk_out;
	
	wire [15:0] ign_timing_uncorrected;
	reg [15:0] ign_timing_actual;
	reg [15:0] dwell_timing_actual;
	
	assign ign_timing_uncorrected = ign_timing + cyl_phase;
	
	// Correct wraparound on timing
	always @(*) begin
		// If timing is very close to 0, then add 360
		if(ign_timing_uncorrected <= 16'd10) begin
			ign_timing_actual <= ign_timing_uncorrected + quanta_per_revolution;
		// If timing is > 360 deg, then subtract 360 deg
		end else if(ign_timing_uncorrected >= quanta_per_revolution) begin
			ign_timing_actual <= ign_timing_uncorrected - quanta_per_revolution;
		end else begin
			ign_timing_actual <= ign_timing_uncorrected;
		end
	end
	
	// Correct wraparound on dwell timing
	always @(*) begin
		// If dwell timing is < 0 (or almost < 0), add 360 deg
		if(ign_timing + cyl_phase <= dwell_angle + 16'd10) begin
			dwell_timing_actual <= (ign_timing + quanta_per_revolution) - dwell_angle + cyl_phase;
		// if dwell timing is >= 360, subtract 360 deg
		end else if (ign_timing + cyl_phase - dwell_angle >= quanta_per_revolution) begin
			dwell_timing_actual <= ign_timing - dwell_angle + cyl_phase - quanta_per_revolution;
		// Otherwise no correction
		end else begin
			dwell_timing_actual <= ign_timing - dwell_angle + cyl_phase;
		end
	end	
	
	wire spk_charge, spk_fire;
	
	// Timer to charge
	ign_timer timer_charge(clk, reset_n, trigger, dwell_timing_actual, eng_phase, next_tooth_width, tooth_period, spk_charge);
	// Timer to fire
	ign_timer timer_fire(clk, reset_n, trigger, ign_timing_actual, eng_phase, next_tooth_width, tooth_period, spk_fire);
	
	// If EN is low, force spark firing (keep low to not burn coil)
	rs_latch ign_latch(spk_fire | ~en, spk_charge, spk_out);
endmodule