`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // -----------------------------
  // Waveform dump
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
  // DUT
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
  // Clock (100 MHz equivalent)
  // -----------------------------
  always #5 clk = ~clk;

  // -----------------------------
  // RESET task
  // -----------------------------
  task reset_dut;
  begin
    rst_n = 0;
    ui_in = 0;
    uio_in = 0;
    ena = 0;

    repeat (3) @(posedge clk);
    rst_n = 1;
    ena   = 1;

    @(posedge clk);
  end
  endtask

  // -----------------------------
  // Apply stimulus (safe sync)
  // -----------------------------
  task apply(input [7:0] val);
  begin
    @(negedge clk);
    ui_in = val;

    @(posedge clk);
    #1;

    $display("time=%0t input=%b output=%b",
             $time, val, uo_out);
  end
  endtask

  // -----------------------------
  // Test sequence
  // -----------------------------
  initial begin
    clk   = 0;
    rst_n = 0;
    ena   = 0;
    ui_in = 0;
    uio_in = 0;

    reset_dut();

    // -----------------------------
    // Palindrome test cases
    // -----------------------------
    apply(8'b00001001); // 9  -> 1
    apply(8'b00000110); // 6  -> 1
    apply(8'b00001010); // 10 -> 0
    apply(8'b00001100); // 12 -> 0
    apply(8'b00001111); // 15 -> 1

    // -----------------------------
    // Finish
    // -----------------------------
    repeat (5) @(posedge clk);
    $finish;
  end

endmodule
