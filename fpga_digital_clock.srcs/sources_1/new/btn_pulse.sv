`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 04:29:24 PM
// Design Name: 
// Module Name: btn_pulse
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


// Debounce + one-pulse generator for active-high pushbuttons
module btn_pulse #(
  parameter int CLK_HZ  = 100_000_000,
  parameter int DB_MS   = 5                // debounce time in milliseconds
)(
  input  logic clk,
  input  logic rstn,        // active-low reset
  input  logic btn_raw,     // asynchronous, noisy (active-high)
  output logic pulse        // 1-clock pulse on each clean press
);
  // 2-FF synchronizer
  logic s0, s1;
  always_ff @(posedge clk) begin
    if (!rstn) begin
      s0 <= 1'b0; s1 <= 1'b0;
    end else begin
      s0 <= btn_raw;
      s1 <= s0;
    end
  end

  // Debounce timer: require stable level for DB_MS
  localparam int DB_TICKS = (CLK_HZ / 1000) * DB_MS;
  localparam int W = (DB_TICKS <= 1) ? 1 : $clog2(DB_TICKS);
  logic [W-1:0] db_cnt;
  logic debounced, s1_d;

  always_ff @(posedge clk) begin
    if (!rstn) begin
      db_cnt    <= '0;
      debounced <= 1'b0;
      s1_d      <= 1'b0;
    end else begin
      s1_d <= s1;

      if (s1 == debounced) begin
        db_cnt <= '0;              // no change, counter idle
      end else begin
        if (db_cnt == DB_TICKS-1) begin
          debounced <= s1;         // accept new stable level
          db_cnt    <= '0;
        end else begin
          db_cnt <= db_cnt + 1;
        end
      end
    end
  end

  // One-clock pulse on rising edge of debounced signal
  logic debounced_d;
  always_ff @(posedge clk) begin
    if (!rstn) begin
      debounced_d <= 1'b0;
      pulse       <= 1'b0;
    end else begin
      debounced_d <= debounced;
      pulse       <= (debounced && !debounced_d);
    end
  end
endmodule

