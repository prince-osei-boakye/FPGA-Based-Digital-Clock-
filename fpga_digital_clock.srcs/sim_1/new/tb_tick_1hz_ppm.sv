`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 06:59:25 PM
// Design Name: 
// Module Name: tb_tick_1hz_ppm
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


`timescale 1ns/1ps
module tb_tick_1hz_ppm;
  localparam int CLK_HZ   = 1_000_000; // 1 MHz for fast sim
  localparam int TICK_HZ  = 1000;      // 1 kHz "seconds"
  // Try a +50 ppm trim (fast); then you can try -50 too.
  localparam int TRIM_PPM = 50;

  logic clk=0; always #500 clk = ~clk; // 1 MHz
  logic rstn=0, tick;

  tick_1hz_ppm #(.CLK_HZ(CLK_HZ), .TICK_HZ(TICK_HZ), .TRIM_PPM(TRIM_PPM)) dut(
    .clk(clk), .rstn(rstn), .tick(tick)
  );

  int unsigned last, now, period, sum, count;
  initial begin
    repeat(5) @(posedge clk); rstn = 1;

    // measure 2000 ticks
    wait(tick); last = $time;
    sum = 0; count = 0;
    repeat (2000) begin
      wait(tick); now = $time;
      period = now - last;
      sum += period;
      count++;
      last = now;
    end
    $display("AVERAGE period (ns) = %0d over %0d ticks", sum/count, count);
    $finish;
  end
endmodule
