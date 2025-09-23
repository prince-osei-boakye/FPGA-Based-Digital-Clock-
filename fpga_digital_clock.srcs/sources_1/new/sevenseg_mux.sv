`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 11:01:08 PM
// Design Name: 
// Module Name: sevenseg_mux
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


module sevenseg_mux #(
  parameter int CLK_HZ     = 100_000_000,
  parameter int REFRESH_HZ = 1000                  // overall frame rate
)(
  input  logic clk,
  input  logic rstn,                               // active-low reset
  input  logic [3:0] d3, d2, d1, d0,               // left→right digits
  output logic [3:0] an,                           // active-low anodes
  output logic [6:0] seg,                          // active-low segments
  output logic       dp                            // active-low decimal point
);
  // ticks per DIGIT (4 digits per frame). Guard width when small.
  localparam int TPD = (REFRESH_HZ > 0) ? (CLK_HZ / (REFRESH_HZ * 4)) : 1;
  localparam int W   = (TPD <= 1) ? 1 : $clog2(TPD);

  logic [W-1:0] r_cnt;
  logic [1:0]   sel;
  logic [3:0]   cur;

  // refresh counter & digit selector
  always_ff @(posedge clk) begin
    if (!rstn) begin
      r_cnt <= '0;
      sel   <= 2'd0;
    end else begin
      if (r_cnt == TPD-1) begin
        r_cnt <= '0;
        sel   <= sel + 2'd1;
      end else begin
        r_cnt <= r_cnt + 1;
      end
    end
  end

  // choose current digit and drive anodes (active-low)
  always_comb begin
    an = 4'b1111;   // all off by default
    dp = 1'b1;      // decimal point off (active-low)
    unique case (sel)
      2'd0: begin an = 4'b1110; cur = d0; end // rightmost
      2'd1: begin an = 4'b1101; cur = d1; end
      2'd2: begin an = 4'b1011; cur = d2; end
      2'd3: begin an = 4'b0111; cur = d3; end // leftmost
    endcase
  end

  // reuse decoder from previous step
  seg7_decoder u_dec (.nibble(cur), .seg(seg));
endmodule
