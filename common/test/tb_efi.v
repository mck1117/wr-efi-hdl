`timescale 1ns / 1ns

module tb_efi();
	// Generated signals
	reg vrin;
	reg clk_spi, clk_efi;
	
	// Output signals
	wire ign_a, ign_b, ign_c, ign_d, inj_a, inj_b, synced, sck, miso, mosi, cs;
	
	efi_main dut(clk_efi, clk_spi, vrin, ign_a, ign_b, ign_c, ign_d, inj_a, inj_b, synced, sck, miso, mosi, cs);
	
	initial begin
		//while(1) begin
		//	#2.5 clk_spi = 0;
		//	#2.5 clk_spi = 1;
		//end
	end
	
	initial begin
		while(1) begin
			#250 clk_efi = 0;
			#250 clk_efi = 1;
		end
	end
	
	
	
	
	integer i, j;
	integer q;
	
	initial begin
		for(j = 0; j < 5; j = j + 1) begin
			for(i = 0; i < 57; i = i + 1) begin
				#200000 vrin = 1;
				#200000 vrin = 0;
			end
			
			#1000000 vrin = 1;
			#200000 vrin = 0;
		end
		
		for(i = 0; i < 12; i = i + 1) begin
				#200000 vrin = 1;
				#200000 vrin = 0;
		end
		
		#200 for(i = 0; i < 24; i = i + 1) begin
				#200000 vrin = 1;
				#200000 vrin = 0;
			 end
		
		q = 200000;
		
		while(1) begin		
			for(i = 0; i < 57; i = i + 1) begin
				#q vrin = 1;
				#q vrin = 0;
				q = q + 10000;
			end
			
			#(5 * q) vrin = 1;
			#q vrin = 0;
		end
	end
	
endmodule