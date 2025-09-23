`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:33:59 PM
// Design Name: 
// Module Name: modn_counter
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


module modn_counter #(
  parameter int N = 60   // counter rolls over after N-1
)(
  input  logic clk,
  input  logic rstn,     // active-low synchronous reset
  input  logic en,       // count enable pulse (1 clock wide)
  output logic [$clog2((N<=1)?2:N)-1:0] q,  // counter value
  output logic carry     // 1-cycle pulse on rollover
);

  always_ff @(posedge clk) begin
    if (!rstn) begin
      q     <= '0;
      carry <= 1'b0;
    end else begin
      carry <= 1'b0;     // default
      if (en) begin
        if (q == N-1) begin
          q     <= '0;
          carry <= 1'b1; // pulse on wrap
        end else begin
          q <= q + 1;
        end
      end
    end
  end

endmodule

