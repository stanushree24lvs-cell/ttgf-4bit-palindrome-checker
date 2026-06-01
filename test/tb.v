`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // -----------------------------
  // Wave dump
  // -----------------------------
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
  end

  // -----------------------------
  // DUT signals
  // -----------------------------
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // -----------------------------
  // DUT instantiation
  // -----------------------------
  tt_um_example dut (
`ifdef GL_TEST
      .VPWR(VPWR),
      .VGND(VGND),
`endif

      .ui_in   (ui_in),
      .uo_out  (uo_out),
      .uio_in  (uio_in),
      .uio_out (uio_out),
      .uio_oe  (uio_oe),
      .ena     (ena),
      .clk     (clk),
      .rst_n   (rst_n)
  );

  // -----------------------------
  // Clock generation (10ns period)
  // -----------------------------
  always #5 clk = ~clk;

  // -----------------------------
  // Stimulus
  // -----------------------------
  initial begin
    // init
    clk   = 0;
    rst_n = 0;
    ena   = 1;
    ui_in = 0;
    uio_in = 0;

    // reset pulse
    #20;
    rst_n = 1;

    // -----------------------------
    // Test cases (4-bit palindrome)
    // -----------------------------

    // 1001 = 9 → palindrome
    ui_in = 8'b00001001;
    #20;

    // 0110 = 6 → palindrome
    ui_in = 8'b00000110;
    #20;

    // 1010 → not palindrome
    ui_in = 8'b00001010;
    #20;

    // 1100 → not palindrome
    ui_in = 8'b00001100;
    #20;

    // 1111 → palindrome
    ui_in = 8'b00001111;
    #20;

    // finish
    #20;
    $finish;
  end

endmodule
