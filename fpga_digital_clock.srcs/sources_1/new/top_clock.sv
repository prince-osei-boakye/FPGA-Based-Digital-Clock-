`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 11:08:41 PM
// Design Name: 
// Module Name: top_clock
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


// top_clock.sv  -  Parametric top for Basys-3 (or sim)
// Drives a 4-digit 7-segment display with HH:MM (24-hour)



// top_clock.sv - HH:MM on 4-digit 7-seg with set-time buttons
module top_clock #(
  parameter int CLK_HZ     = 100_000_000,
  parameter int TICK_HZ    = 1,
  parameter int REFRESH_HZ = 1000,
  parameter int BTN_DB_MS  = 5     // debounce ms
)(
  input  logic clk,
  input  logic rstn,
  input  logic btn_min_raw,
  input  logic btn_hour_raw,
  output logic [3:0] an,
  output logic [6:0] seg,
  output logic       dp
);

  // One-pulse signals
  logic inc_min_p, inc_hour_p;

  // Generate 1 Hz tick
  logic tick;
  tick_1hz #(.CLK_HZ(CLK_HZ), .TICK_HZ(TICK_HZ)) u_tick (
    .clk(clk), .rstn(rstn), .tick(tick)
  );

  // Debounced one-pulse for MINUTE button
  btn_pulse #(.CLK_HZ(CLK_HZ), .DB_MS(BTN_DB_MS)) u_btn_min (
    .clk(clk), .rstn(rstn), .btn_raw(btn_min_raw), .pulse(inc_min_p)
  );

  // Debounced one-pulse for HOUR button
  btn_pulse #(.CLK_HZ(CLK_HZ), .DB_MS(BTN_DB_MS)) u_btn_hour (
    .clk(clk), .rstn(rstn), .btn_raw(btn_hour_raw), .pulse(inc_hour_p)
  );

  // Timekeeper with settable buttons
  logic [5:0] sec, min;
  logic [4:0] hour;
  timekeeper_settable u_time (
    .clk(clk), .rstn(rstn),
    .tick_1hz(tick),
    .inc_min(inc_min_p), .inc_hour(inc_hour_p),
    .sec(sec), .min(min), .hour(hour)
  );

  // 7-seg multiplexer (HH:MM)
  sevenseg_mux #(.CLK_HZ(CLK_HZ), .REFRESH_HZ(REFRESH_HZ)) u_mux (
    .clk(clk), .rstn(rstn),
    .d3(hour/10), .d2(hour%10),
    .d1(min/10),  .d0(min%10),
    .an(an), .seg(seg), .dp(dp)
  );

endmodule
