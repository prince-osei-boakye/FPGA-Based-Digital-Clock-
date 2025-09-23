`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 11:02:29 PM
// Design Name: 
// Module Name: tb_sevenseg_mux
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



module tb_sevenseg_mux;
  localparam int CLK_HZ     = 1_000_000; // 1 MHz sim clock
  localparam int REFRESH_HZ = 2000;      // fast scan in sim

  logic clk = 0; always #500 clk = ~clk; // 1 MHz => 1000 ns period
  logic rstn = 0;
  logic [3:0] an; logic [6:0] seg; logic dp;

  // Show digits D3..D0 = 1,2,3,4 (left→right)
  logic [3:0] d3 = 4'd1, d2 = 4'd2, d1 = 4'd3, d0 = 4'd4;

  sevenseg_mux #(.CLK_HZ(CLK_HZ), .REFRESH_HZ(REFRESH_HZ)) dut (
    .clk(clk), .rstn(rstn),
    .d3(d3), .d2(d2), .d1(d1), .d0(d0),
    .an(an), .seg(seg), .dp(dp)
  );

  // decode active-low 7-seg to a digit (0..9 or -1)
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

  // capture a full frame (all 4 digits once)
  task automatic snapshot_display;
    int D3=-1, D2=-1, D1=-1, D0=-1;
    // step through several scan slots to catch each an
    repeat (16) begin
      @(posedge clk);
      if (an == 4'b0111) D3 = seg_to_digit(seg); // leftmost
      if (an == 4'b1011) D2 = seg_to_digit(seg);
      if (an == 4'b1101) D1 = seg_to_digit(seg);
      if (an == 4'b1110) D0 = seg_to_digit(seg); // rightmost
    end
    $display("DISPLAY  %0d%0d:%0d%0d", D3, D2, D1, D0);
  endtask

  initial begin
    repeat (5) @(posedge clk);
    rstn = 1'b1;

    // take a few snapshots
    repeat (5) begin
      #5ms;       // wait a bit of sim time
      snapshot_display();
    end
    $finish;
  end
endmodule
