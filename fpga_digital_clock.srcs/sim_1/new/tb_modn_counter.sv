`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:39:34 PM
// Design Name: 
// Module Name: tb_modn_counter
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



module tb_modn_counter;
  localparam int N = 10;   // small for fast sim

  logic clk = 0;
  always #10 clk = ~clk;   // 50 MHz clock (20 ns period)

  logic rstn = 0;
  logic en   = 0;
  logic [$clog2((N<=1)?2:N)-1:0] q;
  logic carry;

  modn_counter #(.N(N)) dut (
    .clk(clk), .rstn(rstn), .en(en),
    .q(q), .carry(carry)
  );

  initial begin
    // hold reset for a few cycles
    repeat (5) @(posedge clk);
    rstn = 1'b1;

    // enable counting
    en = 1'b1;

    // run long enough to see >1 rollover
    repeat (30) @(posedge clk);

    $finish;
  end

  always @(posedge clk) if (rstn) begin
    assert (q < N) else $error("q out of range: %0d", q);

    if (carry) $display("%0t ns: CARRY pulse, q reset to 0", $time);
  end
endmodule

