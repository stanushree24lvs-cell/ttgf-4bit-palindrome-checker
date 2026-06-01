`default_nettype none
`timescale 1ns / 1ps

module tb ();

  // =========================================================
  // WAVEFORM DUMP
  // ---------------------------------------------------------
  // Generates FST file for GTKWave / Surfer debugging
  // =========================================================
  initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb);
  end

  // =========================================================
  // DUT INTERFACE SIGNALS (Tiny Tapeout IO)
  // =========================================================
  reg clk;
  reg rst_n;
  reg ena;

  reg  [7:0] ui_in;
  reg  [7:0] uio_in;

  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

`ifdef GL_TEST
  // Gate-level power pins (used only in GL simulation)
  wire VPWR = 1'b1;
  wire VGND = 1'b0;
`endif

  // =========================================================
  // DEVICE UNDER TEST
  // =========================================================
  tt_um_example dut (
`ifdef GL_TEST
    .VPWR   (VPWR),
    .VGND   (VGND),
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

  // =========================================================
  // CLOCK GENERATION
  // ---------------------------------------------------------
  // 10ns period clock (100 MHz equivalent)
  // =========================================================
  always #5 clk = ~clk;

  // =========================================================
  // RESET TASK (IMPROVED & GL-SAFE)
  // ---------------------------------------------------------
  // Ensures:
  // 1. Safe async reset assertion
  // 2. Stable reset hold time
  // 3. Synchronous release aligned to clock edge
  // 4. Post-reset stabilization cycle
  // =========================================================
  task reset_dut;
  begin
    // Initial safe state
    rst_n  = 1'b0;
    ena    = 1'b0;
    ui_in  = 8'b0;
    uio_in = 8'b0;

    // Hold reset for multiple clock cycles (ensures clean startup)
    repeat (3) @(posedge clk);

    // Synchronous reset release (avoids GL race conditions)
    @(negedge clk);
    rst_n = 1'b1;

    // Enable DUT after reset
    ena = 1'b1;

    // Allow one full cycle for internal stabilization
    @(posedge clk);
    #1;
  end
  endtask

  // =========================================================
  // INPUT STIMULUS TASK
  // =========================================================
  task apply(input [7:0] val);
  begin
    @(negedge clk);
    ui_in = val;

    @(posedge clk);
    #1;

    $display("TIME=%0t | INPUT=%b | OUTPUT=%b",
             $time, val, uo_out);
  end
  endtask

  // =========================================================
  // TEST SEQUENCE
  // =========================================================
  initial begin

    // -------------------------
    // Signal initialization
    // -------------------------
    clk   = 1'b0;
    rst_n = 1'b0;
    ena   = 1'b0;
    ui_in = 8'b0;
    uio_in = 8'b0;

    // -------------------------
    // Reset DUT (critical startup phase)
    // -------------------------
    reset_dut();

    // -------------------------
    // Functional verification vectors
    // (Palindrome checker test)
    // -------------------------
    apply(8'b00001001); // 9  -> palindrome
    apply(8'b00000110); // 6  -> palindrome
    apply(8'b00001010); // 10 -> not palindrome
    apply(8'b00001100); // 12 -> not palindrome
    apply(8'b00001111); // 15 -> palindrome

    // -------------------------
    // End simulation
    // -------------------------
    repeat (5) @(posedge clk);
    $finish;

  end

endmodule
