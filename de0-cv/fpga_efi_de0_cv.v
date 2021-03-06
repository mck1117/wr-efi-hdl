module fpga_efi_de0_cv(CLOCK_50, CLOCK2_50, GPIO_1, LEDR, RESET_N);
	input CLOCK_50, CLOCK2_50;
	
	input RESET_N;
	output [9:0] LEDR;
	
	inout [35:0]GPIO_1;
	
	wire clk_spi, clk_efi;
	
	pll_spi p1(CLOCK_50, 1'b0, clk_spi);		// Generates clock for SPI, 100mhz
	pll_mcu p3(CLOCK2_50, 1'b0, GPIO_1[5], GPIO_1[7]);	// Generates STM32 clock input
	
	// divide SPI clock / 50, 7 bit counter
	// clk_efi = 2mhz
	clk_div #(100, 7) efi_divider(clk_spi, clk_efi);
		
	// Mirror VR input to LEDR[9], for diagnostic
	assign LEDR[9] = GPIO_1[10];
	
	// Mirror outputs to LEDS, for diagnostic
	assign LEDR[3:0] = { GPIO_1[13], GPIO_1[14], GPIO_1[11], GPIO_1[12]};
	assign LEDR[5:4] = { GPIO_1[32], GPIO_1[31] };

	efi_main ctrl(.clk(clk_efi), .clk_spi(clk_spi), .reset_n(RESET_N),
					  .vrin(GPIO_1[10]),
					  .ign_a(GPIO_1[12]), .ign_b(GPIO_1[11]), .ign_c(GPIO_1[14]), .ign_d(GPIO_1[13]),
					  .inj_a(GPIO_1[31]), .inj_b(GPIO_1[32]),
					  .synced(LEDR[8]),
					  .sck(GPIO_1[4]), .miso(GPIO_1[6]), .mosi(GPIO_1[7]), .cs(GPIO_1[5]));
endmodule
