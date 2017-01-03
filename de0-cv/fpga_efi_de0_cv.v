module fpga_efi_de0_cv(CLOCK_50, CLOCK2_50, GPIO_1, LEDR, RESET_N, SW);
	input CLOCK_50, CLOCK2_50;
	
	input [9:0] SW;
	input RESET_N;
	output [9:0] LEDR;
	
	inout [35:0]GPIO_1;
	
	wire clk_spi, clk_efi;
	
	pll_spi p1(CLOCK_50, 1'b0, clk_spi);		// Generates clock for SPI, 100mhz
	//pll_mcu p3(CLOCK2_50, 1'b0, GPIO_1[8]);	// Generates STM32 clock input
	
	// divide SPI clock / 50, 7 bit counter
	// clk_efi = 2mhz
	//clk_div #(50, 7) (clk_spi, clk_efi);
	
	wire vrout;
	//assign GPIO_1[10] = vrout & SW[0];
	
	//sync_faker(clk_efi, vrout);
	
	
	
	
	
	wire [5:0] x;
	
	assign GPIO_1[35] = x[5];
	assign GPIO_1[34] = x[4];
	assign GPIO_1[33] = x[3];
	assign GPIO_1[32] = x[2];
	assign GPIO_1[31] = x[1];
	assign GPIO_1[30] = x[0];
	
	
	
	reg [15:0] spi_input_regs [3:0];
	wire [15:0] spi_data_in;
	wire [6:0] spi_addr;
	wire spi_wr_en;
	
	
	spi_slave spi(.clk(clk_spi), .mosi(GPIO_1[7]), .miso(GPIO_1[6]), .sck(GPIO_1[4]), .cs(GPIO_1[5]),
					  .addr(spi_addr), .data_in(spi_data_in), .data_out({6'd0, SW}), .wr_en(spi_wr_en));
	
	
	
	always @(posedge clk_spi) begin
		if(spi_wr_en) begin
			spi_input_regs[spi_addr] <= spi_data_in;
		end
	end
	
	assign LEDR = spi_input_regs[0];
	assign x = spi_input_regs[1];
	
	
	
	
	//assign LEDR[3:0] = { GPIO_1[13], GPIO_1[14], GPIO_1[11], GPIO_1[12]};
	//assign LEDR[5:4] = { GPIO_1[32], GPIO_1[31] };

	//assign GPIO_1[32] = RESET_N;
	
	/*efi_main ctrl(.clk(clk_efi), .clk_spi(clk_spi), .reset_n(RESET_N),
					  // .vrin(GPIO_1[10]),
					  .vrin(vrout & SW[0]),
					  .ign_a(GPIO_1[12]), .ign_b(GPIO_1[11]), .ign_c(GPIO_1[14]), .ign_d(GPIO_1[13]),
					  .inj_a(GPIO_1[31]), .inj_b(GPIO_1[32]),
					  .synced(GPIO_1[2]),
					  .sck(GPIO_1[4]), .miso(GPIO_1[6]), .mosi(GPIO_1[7]), .cs(GPIO_1[0]));*/
endmodule
