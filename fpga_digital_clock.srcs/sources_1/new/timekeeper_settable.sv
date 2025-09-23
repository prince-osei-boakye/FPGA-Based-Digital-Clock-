`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 04:33:43 PM
// Design Name: 
// Module Name: timekeeper_settable
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


// timekeeper_settable.sv
// 24h clock with manual minute/hour increment pulses.
// Manual sets have priority over the 1 Hz tick.
module timekeeper_settable(
  input  logic clk,
  input  logic rstn,        // active-low reset
  input  logic tick_1hz,    // 1-cycle pulse each "second"
  input  logic inc_min,     // 1-cycle pulse: add 1 minute, reset seconds to 0
  input  logic inc_hour,    // 1-cycle pulse: add 1 hour (minutes unchanged)
  output logic [5:0] sec,   // 0..59
  output logic [5:0] min,   // 0..59
  output logic [4:0] hour   // 0..23
);
  // single driver for all three registers; priority: inc_min > inc_hour > tick
  always_ff @(posedge clk) begin
    if (!rstn) begin
      sec  <= 6'd0;
      min  <= 6'd0;
      hour <= 5'd0;
    end else begin
      if (inc_min) begin
        // add one minute, zero seconds
        sec <= 6'd0;
        if (min == 6'd59) begin
          min  <= 6'd0;
          hour <= (hour == 5'd23) ? 5'd0 : (hour + 5'd1);
        end else begin
          min <= min + 6'd1;
        end
      end else if (inc_hour) begin
        // add one hour, leave minutes/seconds as-is (seconds NOT zeroed here)
        hour <= (hour == 5'd23) ? 5'd0 : (hour + 5'd1);
      end else if (tick_1hz) begin
        // normal timekeeping
        if (sec == 6'd59) begin
          sec <= 6'd0;
          if (min == 6'd59) begin
            min  <= 6'd0;
            hour <= (hour == 5'd23) ? 5'd0 : (hour + 5'd1);
          end else begin
            min <= min + 6'd1;
          end
        end else begin
          sec <= sec + 6'd1;
        end
      end
      // else: no changes this cycle
    end
  end
endmodule


