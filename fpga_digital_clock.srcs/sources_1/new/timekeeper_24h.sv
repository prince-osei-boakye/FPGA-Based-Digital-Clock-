`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:48:28 PM
// Design Name: 
// Module Name: timekeeper_24h
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


module timekeeper_24h(
  input  logic clk,
  input  logic rstn,        // active-low synchronous reset
  input  logic tick_1hz,    // 1-cycle enable pulse at 1 Hz
  output logic [5:0] sec,   // 0..59
  output logic [5:0] min,   // 0..59
  output logic [4:0] hour   // 0..23
);
  logic sec_carry, min_carry, hour_carry_unused;

  // seconds: 0..59
  modn_counter #(.N(60)) u_sec (
    .clk(clk), .rstn(rstn), .en(tick_1hz),
    .q(sec), .carry(sec_carry)
  );

  // minutes: 0..59 (enabled by seconds rolling over)
  modn_counter #(.N(60)) u_min (
    .clk(clk), .rstn(rstn), .en(sec_carry),
    .q(min), .carry(min_carry)
  );

  // hours: 0..23 (enabled by minutes rolling over)
  modn_counter #(.N(24)) u_hour (
    .clk(clk), .rstn(rstn), .en(min_carry),
    .q(hour), .carry(hour_carry_unused)
  );
endmodule

