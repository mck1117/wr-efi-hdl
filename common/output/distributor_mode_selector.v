module distributor_mode_selector(inputs, outputs, distributor_mode);
    parameter CHANNEL_COUNT = 4;

    input [CHANNEL_COUNT - 1:0] inputs;
    output [CHANNEL_COUNT - 1:0] outputs;

    input distributor_mode;

    // If in distributor mode, OR all outputs to the A channel, and disable the rest
    assign outputs[0] = distributor_mode ? (|inputs) : inputs[0];

	genvar i_dizzy;

	generate for (i_dizzy = 1; i_dizzy < CHANNEL_COUNT; i_dizzy = i_dizzy + 1) begin : generate_dizzy_mode
		assign outputs[i_dizzy] = distributor_mode ? 1'b0 : inputs[i_dizzy];
	end endgenerate

endmodule
