module oneshot_timer(clk, reset_n, trigger, out, trigger_count);
    parameter bit_length = 24;

    input clk, reset_n, trigger;
    input[bit_length-1:0] trigger_count;

    output out;

    reg [bit_length-1:0] counter = 0;

    reg cnt_en = 0;

    assign out = counter > trigger_count;

    always @(posedge clk) begin
        // Handle reset
        if(~reset_n) begin
            counter <= 0;
            cnt_en <= 0;
        end else begin
            if(trigger) begin
                cnt_en <= 1;
            end

            if(cnt_en) begin
                counter <= counter + 1;
            end

            if(counter > trigger_count) begin
                cnt_en <= 0;
            end
        end
    end
endmodule