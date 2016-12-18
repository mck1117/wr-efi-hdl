module fpga_efi_de0_cv(CLOCK_50, CLOCK_50_2, CLOCK_50_3, GPIO_1);
	input CLOCK_50, CLOCK_50_2, CLOCK_50_3;
	
	inout [35:0]GPIO_1;
	
	wire clk_spi, clk_efi;
	
	pll_spi p1(CLOCK_50, 1'b0, clk_spi);		// Generates clock for SPI
	pll_mcu p3(CLOCK_50_3, 1'b0, GPIO_1[8], GPIO_1[1]);	// Generates STM32 clock input
	
	// divide SPI clock / 100
	// clk_efi = 2mhz
	clk_div(clk_spi, clk_efi);
	
	efi_main ctrl(.clk(clk_efi), .clk_spi(clk_spi),
					  .vrin(GPIO_1[10]),
					  .ign_a(GPIO_1[12]), .ign_b(GPIO_1[11]), .ign_c(GPIO_1[14]), .ign_d(GPIO_1[13]),
					  .inj_a(GPIO_1[31]), .inj_b(GPIO_1[32]),
					  
					  .sck(GPIO_1[4]), .miso(GPIO_1[6]), .mosi(GPIO_1[7]), .cs(GPIO_1[0]));
endmodule
