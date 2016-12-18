`timescale 1us / 1us

module tb_sync();
	
	reg clk, vrin;
	
	wire [15:0] eng_phase;
	wire trigger;
	wire [15:0] next_tooth_length_deg;
	wire [31:0] tooth_period;
	
	wire synced;
	
	sync dut(clk, vrin, eng_phase, trigger, synced, next_tooth_length_deg, tooth_period,
	16'd60, 16'd60, 16'd2, 16'd2700);
	
	wire zero;
	assign zero = eng_phase == 0;
	
	initial begin
		while(1) begin
			#1 clk = 0;
			#1 clk = 1;
		end
	end
	
	
	integer i, j;
	integer q;
	
	initial begin
		for(j = 0; j < 5; j = j + 1) begin
			for(i = 0; i < 57; i = i + 1) begin
				#50 vrin = 1;
				#50 vrin = 0;
			end
			
			#250 vrin = 1;
			#50 vrin = 0;
		end
		
		for(i = 0; i < 12; i = i + 1) begin
				#50 vrin = 1;
				#50 vrin = 0;
		end
		
		#200 for(i = 0; i < 24; i = i + 1) begin
				#50 vrin = 1;
				#50 vrin = 0;
			 end
		
		q = 50;
		
		while(1) begin		
			for(i = 0; i < 57; i = i + 1) begin
				#q vrin = 1;
				#q vrin = 0;
				q = q + 1;
			end
			
			#(5 * q) vrin = 1;
			#q vrin = 0;
		end
	end
endmodule
