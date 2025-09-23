`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 11:10:34 PM
// Design Name: 
// Module Name: tb_top_clock
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

module tb_top_clock;
  localparam int CLK_HZ  = 1_000_000; // fast sim clock
  logic clk=0; always #500 clk = ~clk; // 1 MHz
  logic rstn=0;
  logic [3:0] an;
  logic [6:0] seg;
  logic dp;

  top_clock #(.CLK_HZ(CLK_HZ)) dut (
    .clk(clk), .rstn(rstn),
    .an(an), .seg(seg), .dp(dp)
  );

  initial begin
    repeat (5) @(posedge clk); rstn=1;
    // run ~120 simulated "seconds" = 2 minutes
    #120ms;
    $finish;
  end

  // watch rollover
  always @(posedge clk) if (rstn) begin
    $display("%0t ns: an=%b seg=%b", $time, an, seg);
  end
endmodule

