`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:56:31 PM
// Design Name: 
// Module Name: tb_seg7_decoder
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



module tb_seg7_decoder;
  logic [3:0] nibble;
  logic [6:0] seg;

  seg7_decoder dut (.nibble(nibble), .seg(seg));

  initial begin
    // Sweep through digits 0–9
    for (int i = 0; i < 10; i++) begin
      nibble = i[3:0];
      #10;
      $display("Digit %0d -> seg=%b", i, seg);
    end
    $finish;
  end
endmodule
