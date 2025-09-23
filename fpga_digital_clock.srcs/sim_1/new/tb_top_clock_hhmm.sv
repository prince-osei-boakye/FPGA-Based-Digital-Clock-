`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 11:25:52 PM
// Design Name: 
// Module Name: tb_top_clock_hhmm
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







module tb_top_clock_hhmm;
  // Simulation parameters
  localparam int CLK_HZ_SIM  = 1_000_000; // 1 MHz clock
  localparam int TICK_HZ_SIM = 1000;      // 1 kHz tick (1 ms = 1 sec)
  localparam int REFRESH_SIM = 500;       // slow down refresh for easier sampling

  // DUT I/O
  logic clk = 0; always #500 clk = ~clk;  // 1 MHz
  logic rstn = 0;
  logic [3:0] an;
  logic [6:0] seg;
  logic       dp;

  // Instantiate DUT
  top_clock #(
    .CLK_HZ(CLK_HZ_SIM),
    .TICK_HZ(TICK_HZ_SIM),
    .REFRESH_HZ(REFRESH_SIM)
  ) dut (
    .clk(clk), .rstn(rstn),
    .an(an), .seg(seg), .dp(dp)
  );

  // Segment decode (active-low)
  function automatic int seg_to_digit(input logic [6:0] s);
    case (s)
      7'b1000000: seg_to_digit = 0;
      7'b1111001: seg_to_digit = 1;
      7'b0100100: seg_to_digit = 2;
      7'b0110000: seg_to_digit = 3;
      7'b0011001: seg_to_digit = 4;
      7'b0010010: seg_to_digit = 5;
      7'b0000010: seg_to_digit = 6;
      7'b1111000: seg_to_digit = 7;
      7'b0000000: seg_to_digit = 8;
      7'b0010000: seg_to_digit = 9;
      default:    seg_to_digit = -1;
    endcase
  endfunction

  // Wait until specific anode is active, then sample seg
  task automatic capture_digit(input logic [3:0] want_an, output int digit);
    digit = -1;
    // wait until anode is selected
    while (an != want_an) @(posedge clk);
    // wait a little for seg stable
    repeat (5) @(posedge clk);
    digit = seg_to_digit(seg);
  endtask

  // Snapshot all 4 digits and print HH:MM
  task automatic snapshot_display;
    int D3, D2, D1, D0;
    capture_digit(4'b0111, D3); // leftmost
    capture_digit(4'b1011, D2);
    capture_digit(4'b1101, D1);
    capture_digit(4'b1110, D0); // rightmost
    $display("DISPLAY  %0d%0d:%0d%0d", D3, D2, D1, D0);
  endtask

  initial begin
    // Release reset
    repeat (5) @(posedge clk);
    rstn = 1;

    // Take snapshots every 50 ms (~50 simulated seconds)
    repeat (10) begin
      #(50_000_000);
      snapshot_display();
    end

    $finish;
  end
endmodule
