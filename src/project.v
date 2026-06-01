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
    // PALINDROME LOGIC (COMBINATIONAL)
    // =========================================================
    wire is_palindrome;

    assign is_palindrome =
        (data[3] == data[0]) &&
        (data[2] == data[1]);

    // =========================================================
    // OUTPUT CONTROL
    // =========================================================
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // =========================================================
    // REGISTERED OUTPUT (GL SAFE)
    // =========================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uo_out <= 8'b0;
        else if (ena)
            uo_out <= {7'b0, is_palindrome};
    end

endmodule
