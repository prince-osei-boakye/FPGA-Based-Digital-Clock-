`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 04:30:33 PM
// Design Name: 
// Module Name: tb_btn_pulse
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



module tb_btn_pulse;
  localparam int CLK_HZ  = 1_000_000;  // fast sim clock
  localparam int DB_MS   = 2;          // short debounce for sim

  logic clk=0; always #500 clk = ~clk; // 1 MHz
  logic rstn=0, btn_raw=0, pulse;

  btn_pulse #(.CLK_HZ(CLK_HZ), .DB_MS(DB_MS)) dut (
    .clk(clk), .rstn(rstn), .btn_raw(btn_raw), .pulse(pulse)
  );

  initial begin
    repeat (5) @(posedge clk); rstn = 1;

    // press with bounce: 1-0-1-0-1 then hold
    btn_raw = 1; #5000; btn_raw = 0; #3000; btn_raw = 1; #2000; btn_raw = 0; #2000; btn_raw = 1;
    #20ms;     // hold 20 ms
    btn_raw = 0;

    // second press
    #10ms; btn_raw = 1; #15ms; btn_raw = 0;

    #10ms; $finish;
  end
endmodule

