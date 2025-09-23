`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:49:55 PM
// Design Name: 
// Module Name: tb_timekeeper_24h
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



module tb_timekeeper_24h;
  // Fast sim clock so we don't wait in real time
  localparam int CLK_HZ  = 1_000_000;  // 1 MHz clock
  localparam int TICK_HZ = 1000;       // "1 Hz" tick accelerated to 1 kHz
  // => 1 "second" = 1 ms sim time; 1 "minute" = 60 ms; 1 "hour" = 3.6 s

  logic clk = 0;
  always #500 clk = ~clk;              // 1 MHz => 1000 ns period

  logic rstn = 0;
  logic tick;

  logic [5:0] sec, min;
  logic [4:0] hour;

  // divider generates our fast "seconds" enable pulse
  tick_1hz #(.CLK_HZ(CLK_HZ), .TICK_HZ(TICK_HZ)) u_tick (
    .clk(clk), .rstn(rstn), .tick(tick)
  );

  // device under test
  timekeeper_24h dut (
    .clk(clk), .rstn(rstn), .tick_1hz(tick),
    .sec(sec), .min(min), .hour(hour)
  );

  // release reset, run long enough to see multiple minute/hour rollovers
  initial begin
    repeat (5) @(posedge clk);
    rstn = 1'b1;

    // Run ~0.5 seconds of sim time = ~500 "seconds" => >8 minutes
    #0.5s;

    // Print final time state
    $display("FINAL  H:%0d  M:%0d  S:%0d", hour, min, sec);
    $finish;
  end

  // Basic safety assertions
  always @(posedge clk) if (rstn) begin
    assert (sec  < 60) else $error("sec out of range: %0d", sec);
    assert (min  < 60) else $error("min out of range: %0d", min);
    assert (hour < 24) else $error("hour out of range: %0d", hour);
  end

  // Optional: print when key rollovers occur
  logic [5:0] sec_d, min_d; logic [4:0] hour_d;
  always @(posedge clk) if (rstn) begin
    sec_d  <= sec;  min_d  <= min;  hour_d <= hour;
    if (sec==0  && sec_d==59) $display("%0t ns: minute++  (sec 59->0)", $time);
    if (min==0  && min_d==59) $display("%0t ns: hour++    (min 59->0)", $time);
    if (hour==0 && hour_d==23) $display("%0t ns: day wrap (hour 23->0)", $time);
  end
endmodule
