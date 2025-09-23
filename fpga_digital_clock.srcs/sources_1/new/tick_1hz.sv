`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:01:57 PM
// Design Name: 
// Module Name: tick_1hz
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


module tick_1hz #(
  parameter int CLK_HZ  = 100_000_000,  // input clock frequency
  parameter int TICK_HZ = 1             // desired tick rate
)(
  input  logic clk,
  input  logic rstn,    // active-low reset
  output logic tick     // 1-cycle pulse at TICK_HZ
);
  // divider value
  localparam int DIV = (TICK_HZ > 0) ? (CLK_HZ / TICK_HZ) : 1;
  // counter width (at least 1)
  localparam int W   = (DIV <= 1) ? 1 : $clog2(DIV);

  logic [W-1:0] cnt;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      cnt  <= '0;
      tick <= 1'b0;
    end else begin
      if (cnt == DIV-1) begin
        cnt  <= '0;
        tick <= 1'b1;      // 1-cycle pulse
      end else begin
        cnt  <= cnt + 1;
        tick <= 1'b0;
      end
    end
  end
endmodule



