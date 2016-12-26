module inj_driver(clk, en, trigger, eng_phase, mode, on_cycles, inj_out);
	input clk, en, trigger, mode;
	input [15:0] eng_phase;

	input [31:0] on_cycles;
	output inj_out;
	
	reg inj_out_int;
	initial inj_out_int <= 0;
	
	assign inj_out = inj_out_int & en;
	
	reg [31:0] cnt = 0;
	reg [31:0] on_cycles_latched = 0;
	
	reg cnt_en = 0;
	
	reg flp = 0;
	
	always @(posedge clk) begin
		if(trigger && eng_phase == 0 && on_cycles != 16'd0) begin
			flp <= ~flp;
			
			if(flp) begin		
				cnt <= 0;
				inj_out_int <= 1;
				on_cycles_latched <= on_cycles;
				cnt_en <= 1;
			end
		end
		
		if(cnt > on_cycles_latched && cnt_en) begin
			inj_out_int <= 0;
			cnt_en <= 0;
		end else begin
			if(cnt_en) begin
				cnt <= cnt + 1;
			end
		end

	end
endmodule
