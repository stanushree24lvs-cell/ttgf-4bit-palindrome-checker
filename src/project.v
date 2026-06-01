/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // inputs
    output wire [7:0] uo_out,   // outputs
    input  wire [7:0] uio_in,   // bidir input
    output wire [7:0] uio_out,  // bidir output
    output wire [7:0] uio_oe,   // output enable
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    // -----------------------------
    // Use lower 4 bits as data input
    // -----------------------------
    wire [3:0] data;
    assign data = ui_in[3:0];

    // -----------------------------
    // Palindrome logic
    // -----------------------------
    wire is_palindrome;
    assign is_palindrome = (data[3] == data[0]) &&
                            (data[2] == data[1]);

    // -----------------------------
    // Register output (safe timing)
    // -----------------------------
    reg result;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            result <= 1'b0;
        else
            result <= is_palindrome;
    end

    // -----------------------------
    // Output mapping
    // -----------------------------
    assign uo_out[0] = result;   // palindrome flag
    assign uo_out[7:1] = 7'b0;

    // unused IOs
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0;

    // silence unused warnings
    wire _unused = &{ena, clk, rst_n, ui_in[7:4], uio_in};

endmodule
