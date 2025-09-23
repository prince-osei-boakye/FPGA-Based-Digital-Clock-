`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 04:37:15 PM
// Design Name: 
// Module Name: tb_top_clock_set
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

module tb_top_clock_set;

  localparam int CLK_HZ_SIM     = 1_000_000;  // 1 MHz
  localparam int TICK_HZ_SIM    = 1000;       // 1 kHz tick (fast sim)
  localparam int REFRESH_SIM    = 1000;       // 1 kHz refresh
  localparam int BTN_DB_MS_SIM  = 1;          // 1 ms debounce

  logic clk = 0, rstn;
  logic btn_min_raw, btn_hour_raw;
  logic [3:0] an;
  logic [6:0] seg;
  logic dp;

  // Clock gen
  always #500 clk = ~clk;   // 1 MHz clock

  // Reset
  initial begin
    rstn = 0;
    repeat (5) @(posedge clk);
    rstn = 1;
  end

  // DUT
  top_clock #(
    .CLK_HZ(CLK_HZ_SIM),
    .TICK_HZ(TICK_HZ_SIM),
    .REFRESH_HZ(REFRESH_SIM),
    .BTN_DB_MS(BTN_DB_MS_SIM)
  ) dut (
    .clk(clk), .rstn(rstn),
    .btn_min_raw(btn_min_raw),
    .btn_hour_raw(btn_hour_raw),
    .an(an), .seg(seg), .dp(dp)
  );

  // Stimulus
  initial begin
    btn_min_raw = 0; btn_hour_raw = 0;
    @(posedge rstn);

    // Press MIN three times
    #10ms; btn_min_raw = 1; #12ms; btn_min_raw = 0;
    #10ms; btn_min_raw = 1; #12ms; btn_min_raw = 0;
    #10ms; btn_min_raw = 1; #12ms; btn_min_raw = 0;

    // Press HOUR once
    #20ms; btn_hour_raw = 1; #12ms; btn_hour_raw = 0;

    // Run a bit longer
    #200ms;
   $finish;
  end

endmodule
