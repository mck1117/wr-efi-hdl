module spi_output(clk, sck, miso, cs, data);
	parameter LENGTH = 64;
	
	input clk, sck, cs;
	output reg miso;
	initial miso = 0;
	
	input [LENGTH - 1:0] data;
	reg [LENGTH - 1:0] data_latched;
	
	wire cs_trigger, sck_trigger;
	edge_det edge_cs(clk, ~cs, cs_trigger);
	edge_det edge_sck(clk, sck, sck_trigger);
	
	
	
	always @(posedge clk) begin
		if(cs_trigger) begin
			miso <= data[LENGTH - 1];
			data_latched[LENGTH - 1:1] <= data[LENGTH - 2:0];
			data_latched[0] <= 0;
		end
		
		if(~cs & sck_trigger) begin
			miso <= data_latched[LENGTH - 1];
			data_latched[LENGTH - 1:1] <= data_latched[LENGTH - 2:0];	// Shift data over one
			data_latched[0] <= 0;
		end
	end
endmodule