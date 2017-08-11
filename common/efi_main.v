module efi_main(clk, reset_n, clk_spi, vrin, ign_a, ign_b, ign_c, ign_d, inj_a, inj_b, synced, sck, miso, mosi, cs);
	input clk, reset_n, vrin;
	output ign_a, ign_b, ign_c, ign_d, inj_a, inj_b, synced;

	input clk_spi;
	
	input sck, mosi, cs;
	output miso;
	
	
	// ***********************************
	//    Latch reset_n to internal reset
	// ***********************************
	
	reg reset_internal = 1;
	
	always @(posedge clk) begin
		reset_internal <= reset_n;
	end
	
	
	// ***********************************
	//          SPI Configuration
	// ***********************************
	
	wire [6:0] spi_addr;
	
	reg [63:0] spi_output_regs [15:0];
	reg [63:0] spi_output_regs_latched [15:0];
	wire [63:0] spi_data_out;
	assign spi_data_out = spi_output_regs_latched[spi_addr];
	
	reg [63:0] spi_input_regs [15:0];
	reg [63:0] spi_input_regs_latched [15:0];
	wire [63:0] spi_data_in;
	
	wire spi_wr_en;
	
	
	
	initial begin
		// Disable all outputs at reset
		spi_input_regs[0] = 64'd0;
	end
	
	
	
	
	
	always @(posedge clk_spi) begin
		if(~reset_internal) begin
				spi_input_regs[0] = 64'b000_0000_00_11_0111;
				spi_input_regs[1] = 64'd60;	// teeth per rev
				spi_input_regs[2] = 64'd2;	// missing teeth

				spi_input_regs[3] = { 8'd57, 8'd1, 24'd0, 24'd0 };	// start/end tooth + start/end counts
				spi_input_regs[4] = { 8'd4, 8'd5, 24'd0, 24'd0 };	// start/end tooth + start/end counts
				spi_input_regs[5] = { 8'd8, 8'd9, 24'd0, 24'd0 };	// start/end tooth + start/end counts
				spi_input_regs[6] = { 8'd12, 8'd13, 24'd0, 24'd0 };	// start/end tooth + start/end counts
				
//				spi_input_regs[11] = 0;
//				spi_input_regs[12] = 0;
		end else begin
			if(spi_wr_en) spi_input_regs[spi_addr] <= spi_data_in;
		end
	end
	
	// Latch SPI input/output data to avoid long combinational path between clock domains
	integer i;
	always @(posedge clk) begin
		for(i = 0; i < 16; i = i + 1) begin
			spi_input_regs_latched[i] <= spi_input_regs[i];
			spi_output_regs_latched[i] <= spi_output_regs[i];
		end		
	end
	
	
	wire [31:0] rpm_sum;

	always @(posedge clk) begin
		spi_output_regs[0] <= {15'd0, synced};
		spi_output_regs[1] <= synced ? (rpm_sum[31:16]) : 16'd0;
	end
	
	
	spi_slave spi(clk_spi, sck, mosi, miso, cs, spi_addr, spi_data_in, spi_data_out, spi_wr_en);
	
	wire distributor_mode;
	
	wire [1:0] en_inj;
	wire [3:0] en_ign;
	
	wire [7:0] conf_tooth_cnt;		// How many teeth are there?
	wire [7:0] conf_teeth_missing;	// How many teeth are missing?
	
	wire [7:0] ign_a_start_tooth, ign_a_end_tooth, ign_b_start_tooth, ign_b_end_tooth, ign_c_start_tooth, ign_c_end_tooth, ign_d_start_tooth, ign_d_end_tooth;
	wire [23:0] ign_a_start_count, ign_a_end_count, ign_b_start_count, ign_b_end_count, ign_c_start_count, ign_c_end_count, ign_d_start_count, ign_d_end_count;
	
	assign { distributor_mode, en_inj, en_ign } = spi_input_regs_latched[0][6:0];
	
	assign conf_tooth_cnt = spi_input_regs_latched[1];
	assign conf_teeth_missing = spi_input_regs_latched[2];
	
	assign { ign_a_start_tooth, ign_a_end_tooth, ign_a_start_count, ign_a_end_count } = spi_input_regs_latched[3];	// Channel A settings
	assign { ign_b_start_tooth, ign_b_end_tooth, ign_b_start_count, ign_b_end_count } = spi_input_regs_latched[4];	// Channel B settings
	assign { ign_c_start_tooth, ign_c_end_tooth, ign_c_start_count, ign_c_end_count } = spi_input_regs_latched[5];	// Channel C settings
	assign { ign_d_start_tooth, ign_d_end_tooth, ign_d_start_count, ign_d_end_count } = spi_input_regs_latched[6];	// Channel D settings
	
	// ***********************************
	//            Synchronizer
	// ***********************************
	
	wire trigger;
	wire [7:0] eng_phase;
	
	// Stores how long the previous tooth took, in clock cycles
	// a tooth of 5.3ms would be 5.3ms * 2000 tick/ms = 10600 count
	wire [31:0] tooth_period;
	
	wire vrin_sync;
	
	synchronizer vrin_syncer(clk, vrin, vrin_sync);
	sync synchronizer(clk, reset_internal, vrin_sync, eng_phase, trigger, synced, tooth_period, conf_tooth_cnt, conf_teeth_missing);
	
	// RPM averager
	rpm_shift_reg summer(clk, reset_n, trigger, tooth_period[15:0], rpm_sum);
	
	// ***********************************
	//          Ignition Drivers
	// ***********************************
	
	wire ign_a_internal, ign_b_internal, ign_c_internal, ign_d_internal;
	
	// If in distributor mode, OR all outputs to the A channel, and disable the rest
	assign ign_a = distributor_mode ? (ign_a_internal | ign_b_internal | ign_c_internal | ign_d_internal) : ign_a_internal;
	assign ign_b = distributor_mode ? 1'b0 : ign_b_internal;
	assign ign_c = distributor_mode ? 1'b0 : ign_c_internal;
	assign ign_d = distributor_mode ? 1'b0 : ign_d_internal;
	
	output_driver ignm_a(clk, reset_internal, synced & en_ign[0], eng_phase, trigger, ign_a_start_tooth, ign_a_end_tooth, ign_a_start_count, ign_a_end_count, ign_a_internal);
	output_driver ignm_b(clk, reset_internal, synced & en_ign[0], eng_phase, trigger, ign_b_start_tooth, ign_b_end_tooth, ign_b_start_count, ign_b_end_count, ign_b_internal);
	output_driver ignm_c(clk, reset_internal, synced & en_ign[0], eng_phase, trigger, ign_c_start_tooth, ign_c_end_tooth, ign_c_start_count, ign_c_end_count, ign_c_internal);
	output_driver ignm_d(clk, reset_internal, synced & en_ign[0], eng_phase, trigger, ign_d_start_tooth, ign_d_end_tooth, ign_d_start_count, ign_d_end_count, ign_d_internal);

	// ***********************************
	//          Injector Drivers
	// ***********************************
	
	//inj_driver injm_a(clk, reset_internal, synced & en_inj[0], trigger, eng_phase, 1'b0, {16'd0, inj_a_pw}, inj_a);
	//inj_driver injm_b(clk, reset_internal, synced & en_inj[1], trigger, eng_phase, 1'b0, {16'd0, inj_b_pw}, inj_b);
	
	
	
endmodule


