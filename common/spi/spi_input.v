module spi_input(clk, sck, mosi, cs, data);
	parameter LENGTH = 8;

	input clk, sck, mosi, cs;
	output reg [LENGTH - 1:0] data;

	reg [LENGTH - 1:0] data_sr;
	initial data_sr <= {LENGTH{1'b0}};
	
	wire cs_trigger;
	edge_det edge_cs(clk, cs, cs_trigger);
	
	wire sck_trigger;
	edge_det edge_sck(clk, ~sck, sck_trigger);
	
	always @(posedge clk) begin
		if(cs_trigger) begin
			data <= data_sr;
		end
		
		if(sck_trigger) begin
			if(~cs) begin
				data_sr[0] <= mosi;
				data_sr[LENGTH - 1:1] <= data_sr[LENGTH - 2:0];
			end
		end
	end
	
	
	/*wire cs_trigger, sck_trigger;
	
	edge_det edge_sck(clk, ~sck, sck_trigger);
	
	always @(posedge clk) begin
		// CS was released, latch data
		if(cs_trigger) begin
			data <= data_sr;
		end
	
		if(~cs & sck_trigger) begin
			data_sr[0] <= mosi;
			data_sr[LENGTH - 1:1] <= data_sr[LENGTH - 2:0];
		end
	end*/
endmodule
