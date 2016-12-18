module spi_slave(clk, sck, mosi, miso, cs, addr, data_in, data_out, wr_en);
	input clk;
	input sck, mosi, cs;
	output miso;
	
	output reg [6:0] addr;
	initial addr = 7'bxxxxxxx;
	output [15:0] data_in;
	input [15:0] data_out;
	output wr_en;
	
	reg [4:0] bit_idx;
	
	reg is_write;
	initial is_write = 0;
	
	reg cs_internal;
	initial cs_internal = 1;
	
	spi_output #(18) spio(clk, sck, miso, cs_internal, {2'b0, data_out});
	spi_input #(16) spii(clk, sck, mosi, cs_internal, data_in);
	
	wire cs_trigger_fall, cs_trigger_rise;
	edge_det edcsr(clk, ~cs, cs_trigger_fall);
	edge_det edcsf(clk, cs, cs_trigger_rise);
	wire sck_trigger;
	edge_det cdsck_f(clk, ~sck, sck_trigger);
	
	reg [2:0] shift_wr_en;
	initial shift_wr_en = 3'b000;
	assign wr_en = shift_wr_en[2];
	
	always @(posedge clk) begin
		shift_wr_en[0] <= 0;
		shift_wr_en[2:1] <= shift_wr_en[1:0];
		
		if(cs_trigger_fall) begin
			bit_idx <= 0;
		end else if(cs_trigger_rise) begin
			cs_internal = 1;
			shift_wr_en[0] <= is_write;
		end else begin
			if(sck_trigger & ~cs) begin
				if(bit_idx == 7) begin
					is_write <= mosi;
				end else if (bit_idx <= 7) begin
					addr[6:1] <= addr[5:0];	// LSH 1
					addr[0] <= mosi;		// Append new bit				
				end
				
				bit_idx <= bit_idx + 1;
				
				if(bit_idx == 6) begin
					cs_internal <= 0;
				end
			end
		end
	end
		
endmodule
