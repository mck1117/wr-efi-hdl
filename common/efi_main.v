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
	
	reg [15:0] spi_output_regs [15:0];
	reg [15:0] spi_output_regs_latched [15:0];
	wire [15:0] spi_data_out;
	assign spi_data_out = spi_output_regs_latched[spi_addr];
	
	reg [15:0] spi_input_regs [15:0];
	reg [15:0] spi_input_regs_latched [15:0];
	wire [15:0] spi_data_in;
	
	wire spi_wr_en;
	
	always @(posedge clk_spi) begin
		if(~reset_internal) begin
				spi_input_regs[0] = 16'b000_0000_00_11_0111;
				spi_input_regs[1] = 16'd60;
				spi_input_regs[2] = 16'd128;
				spi_input_regs[3] = 16'd2;
				spi_input_regs[4] = 16'd0;
				spi_input_regs[5] = 16'd7680;
				spi_input_regs[6] = 16'd0;		// phase a
				spi_input_regs[7] = 16'd2560;	// phase b
				spi_input_regs[8] = 16'd5120;	// phase c
				spi_input_regs[9] = 16'd0;
				
				spi_input_regs[10] = 16'd342;	// 10 deg btdc
				spi_input_regs[11] = 16'd342;  // 4ms deg dwell
				
				spi_input_regs[12] = 16'd2000;	// 1ms pulse width
				spi_input_regs[13] = 16'd0;		// 0ms pulse (disabled)
				
				spi_input_regs[14] = 0;
				spi_input_regs[15] = 0;
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
	
	
	wire [15:0] rpm;
	
	always @(posedge clk) begin
		spi_output_regs[0] <= {15'd0, synced};
		spi_output_regs[1] <= synced ? rpm : 16'd0;
	end
	
	
	wire [31:0] rpm_sum;
	
	// 1 minute takes 120 million cycles
	// We're averageing 32 teeth width, which means we need 32/60 of minute
	// 120e6 * 32 / 60 = 64 million		
	assign rpm = 26'd64_000_000 / rpm_sum[19:0];
			
	
	spi_slave spi(clk_spi, sck, mosi, miso, cs, spi_addr, spi_data_in, spi_data_out, spi_wr_en);
	
	wire distributor_mode;
	
	wire [1:0] en_inj;
	wire [3:0] en_ign;
	
	wire [15:0] conf_tooth_cnt;		// How many teeth are there?
	wire [15:0] conf_teeth_missing;	// How many teeth are missing?
	wire [15:0] conf_quanta_per_rev;	// How many quanta in a full rev?
	
	wire [15:0] ign_phase_a;	// Cylinder phasing, quanta, relative to 0*
	wire [15:0] ign_phase_b;	// Cylinder phasing, quanta, relative to 0*
	wire [15:0] ign_phase_c;	// Cylinder phasing, quanta, relative to 0*
	wire [15:0] ign_phase_d;	// Cylinder phasing, quanta, relative to 0*
	
	wire [15:0] ign_timing;		// Ignition timing, quanta
	wire [15:0] dwell;			// Dwell, quanta
	
	wire [15:0] inj_a_pw, inj_b_pw;
	
	
	assign { distributor_mode, en_inj, en_ign } = spi_input_regs_latched[0][6:0];
	
	assign conf_tooth_cnt = spi_input_regs_latched[1];
	assign conf_teeth_missing = spi_input_regs_latched[3];
	assign conf_quanta_per_rev = conf_tooth_cnt * 16'd256;
	
	assign ign_phase_a = spi_input_regs_latched[6];
	assign ign_phase_b = spi_input_regs_latched[7];
	assign ign_phase_c = spi_input_regs_latched[8];
	assign ign_phase_d = spi_input_regs_latched[9];
	
	assign ign_timing = spi_input_regs_latched[10];
	assign dwell = spi_input_regs_latched[11];
	
	assign inj_a_pw = spi_input_regs_latched[12];
	assign inj_b_pw = spi_input_regs_latched[13];
	
	// ***********************************
	//            Synchronizer
	// ***********************************
	
	wire trigger;
	wire [15:0] eng_phase;
	wire [15:0] next_tooth_length_deg;
	
	// Stores how long the previous tooth took, in clock cycles
	// a tooth of 5.3ms would be 5.3ms * 2000 tick/ms = 10600 count
	wire [31:0] tooth_period;
	
	wire vrin_sync;
	
	synchronizer vrin_syncer(clk, vrin, vrin_sync);
	sync synchronizer(clk, reset_internal, vrin_sync, eng_phase, trigger, synced, next_tooth_length_deg, tooth_period, conf_tooth_cnt, conf_teeth_missing);
	
	// RPM averager
	rpm_shift_reg summer(clk, reset_n, trigger, tooth_period, rpm_sum);
	
	// ***********************************
	//          Ignition Drivers
	// ***********************************
	
	wire ign_a_internal, ign_b_internal, ign_c_internal, ign_d_internal;
	
	// If in distributor mode, OR all outputs to the A channel, and disable the rest
	assign ign_a = distributor_mode ? (ign_a_internal | ign_b_internal | ign_c_internal | ign_d_internal) : ign_a_internal;
	assign ign_b = distributor_mode ? 1'b0 : ign_b_internal;
	assign ign_c = distributor_mode ? 1'b0 : ign_c_internal;
	assign ign_d = distributor_mode ? 1'b0 : ign_d_internal;
	
	ign_driver ignm_a(clk, reset_internal, synced & en_ign[0], trigger, eng_phase, ign_timing, dwell, ign_phase_a, ign_a_internal, next_tooth_length_deg, tooth_period, conf_quanta_per_rev);
	ign_driver ignm_b(clk, reset_internal, synced & en_ign[1], trigger, eng_phase, ign_timing, dwell, ign_phase_b, ign_b_internal, next_tooth_length_deg, tooth_period, conf_quanta_per_rev);
	ign_driver ignm_c(clk, reset_internal, synced & en_ign[2], trigger, eng_phase, ign_timing, dwell, ign_phase_c, ign_c_internal, next_tooth_length_deg, tooth_period, conf_quanta_per_rev);
	ign_driver ignm_d(clk, reset_internal, synced & en_ign[3], trigger, eng_phase, ign_timing, dwell, ign_phase_d, ign_d_internal, next_tooth_length_deg, tooth_period, conf_quanta_per_rev);
	
	// ***********************************
	//          Injector Drivers
	// ***********************************
	
	inj_driver injm_a(clk, reset_internal, synced & en_inj[0], trigger, eng_phase, 1'b0, {16'd0, inj_a_pw}, inj_a);
	inj_driver injm_b(clk, reset_internal, synced & en_inj[1], trigger, eng_phase, 1'b0, {16'd0, inj_b_pw}, inj_b);
	
	
	
endmodule


