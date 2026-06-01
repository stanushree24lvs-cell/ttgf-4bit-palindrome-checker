`default_nettype none

module tt_um_palindrome (
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    // =========================================================
    // INPUT DECODE
    // =========================================================
    wire [3:0] data;
    assign data = ui_in[3:0];

    // =========================================================
    // PALINDROME LOGIC
    // =========================================================
    wire is_palindrome;

    assign is_palindrome =
        (data[3] == data[0]) &&
        (data[2] == data[1]);

    // =========================================================
    // UNUSED IO
    // =========================================================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // =========================================================
    // OUTPUT LOGIC (FIXED)
    // =========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uo_out <= 8'd0;
        end
        else if (ena) begin
            // IMPORTANT FIX: match cocotb expectation
            if (is_palindrome)
                uo_out <= 8'd50;   // REQUIRED by your test
            else
                uo_out <= 8'd0;
        end
        else begin
            uo_out <= 8'd0;
        end
    end

endmodule

`default_nettype wire
