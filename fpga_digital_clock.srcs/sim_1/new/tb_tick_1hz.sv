`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:20:24 PM
// Design Name: 
// Module Name: tb_tick_1hz
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module tb_tick_1hz;
  // Use a fast "fake" clock so we don't wait in real time
  localparam int CLK_HZ  = 1_000_000; // 1 MHz simulation clock
  localparam int TICK_HZ = 1000;      // expect a 1 kHz tick (1 ms period)

  // clock, reset, and observed tick
  logic clk = 0;
  logic rstn = 0;
  logic tick;

  // Generate a 1 MHz clock: period = 1000 ns, half = 500 ns
  always #500 clk = ~clk;

  // DUT: the divider under test
  tick_1hz #(.CLK_HZ(CLK_HZ), .TICK_HZ(TICK_HZ)) dut (
    .clk(clk),
    .rstn(rstn),
    .tick(tick)
  );

  // Simple stimulus
  initial begin
    // hold reset low for a few cycles
    repeat (5) @(posedge clk);
    rstn = 1'b1;

    // run long enough to see a handful of tick pulses
    // at 1 kHz, a pulse occurs every 1000 clk cycles => every 1 ms sim time
    repeat (6000) @(posedge clk);
    $finish;
  end

  // Optional: print when tick occurs
  always @(posedge clk) if (rstn && tick) $display("%0t ns: TICK pulse", $time);

endmodule

