module sync_faker(clock, vrout);
	input clock;
	output reg vrout;
	
	
	wire clock_slow;
	
	
	clk_div #(1420, 14) divider(clock, clock_slow);
	
	
	
	reg [7:0] cnt;
	initial cnt = 0;
	
	
	always @(posedge clock_slow) begin
		if(cnt == 119) begin
			cnt <= 0;
		end else begin
			cnt <= cnt + 1;
		end
		
		if(cnt < 114) begin
			vrout <= ~cnt[0];
		end else begin
			vrout <= cnt < 116;
		end
	end
	
	
endmodule
