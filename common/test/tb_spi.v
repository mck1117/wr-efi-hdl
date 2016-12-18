`timescale 1ns/1ps

module tb_spi();
	
	
	reg clk, sck, cs;
	
	wire miso, mosi;
	
	wire[6:0] addr;
	
	// These fake the master
	spi_output #(24) test_gen(clk, sck, mosi, cs, 24'h05_BEEF);
	wire [23:0] recv_data;
	spi_input #(24) test_recv(clk, sck, miso, cs, recv_data);
	
	wire [15:0] data_in, data_out;
	reg[15:0] regs[15:0];
	
	initial begin
		regs[0] = 16'h00;
		regs[1] = 16'h11;
		regs[2] = 16'h22;
		regs[3] = 16'h33;
		regs[4] = 16'h44;
		regs[5] = 16'h55;
		regs[6] = 16'h66;
		regs[7] = 16'h77;
		regs[8] = 16'h88;
		regs[9] = 16'h99;
		regs[10] = 16'hAA;
		regs[11] = 16'hBB;
		regs[12] = 16'hCC;
		regs[13] = 16'hDD;
		regs[14] = 16'hEE;
		regs[15] = 16'hFF;
	end
	
	// This is the slave under test
	spi_slave dut(clk, sck, mosi, miso, cs, addr, data_in, data_out, wr_en);

	
	assign data_out = regs[addr];
	
	always @(posedge clk) begin
		if(wr_en) regs[addr] <= data_in;
	end
	

	initial begin
		while(1) begin
			#1 clk = 1;
			#1 clk = 0;
		end
	end
	
	initial sck = 1;
	initial cs = 1;
	
	integer i;
	
	initial begin
		#100 cs = 0;
	
		#100 for(i = 0; i < 24; i = i + 1) begin
			#50 sck = 0;
			#50 sck = 1;
		end
		
		#200 cs = 1;
	end
		
endmodule
