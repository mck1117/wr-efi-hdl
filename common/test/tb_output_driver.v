`timescale 1ns / 1ns

module tb_output_driver();
	// Generated signals
	wire vrin;

	// Output signals
	wire ign_a;
	
	reg rst_n = 1;
	
	reg clk;

	sync_faker sfaker(clk, vrin);
	
	wire [7:0] eng_phase;
	wire trigger;
	wire [31:0] tooth_period;
	
	wire synced;

	sync dut_sync(clk, 1'b1, vrin, eng_phase, trigger, synced, 8'd60, 8'd2);
	
	output_driver dut_output(clk, 1'b1, synced, eng_phase, trigger, 8'd30, 8'd30, 24'd1000, 24'd5000, ign_a);
	
	
	
	
	
	initial begin
		while(1) begin
			#100 clk = 0;
			#100 clk = 1;
		end
	end
	
	
	
	
	/*efi_main dut(.clk(clk_efi), .reset_n(rst_n), .clk_spi(clk_spi),
				 .vrin(vrin),
				 .ign_a(ign_a), .ign_b(ign_b), .ign_c(ign_c), .ign_d(ign_d),
				 .inj_a(inj_a), .inj_b(inj_b), 
				 .synced(synced));*/
	

	/*initial begin
		rst_n = 0;
		#91366000 rst_n = 1;
	end*/
	
endmodule