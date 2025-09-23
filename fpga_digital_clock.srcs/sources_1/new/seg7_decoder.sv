`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/21/2025 10:54:58 PM
// Design Name: 
// Module Name: seg7_decoder
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


// Converts 4-bit nibble to active-low 7-segment encoding {a,b,c,d,e,f,g}
module seg7_decoder(
  input  logic [3:0] nibble,
  output logic [6:0] seg   // active-low segments (0=ON)
);
  always_comb begin
    unique case (nibble)
      4'h0: seg = 7'b1000000; // 0
      4'h1: seg = 7'b1111001; // 1
      4'h2: seg = 7'b0100100; // 2
      4'h3: seg = 7'b0110000; // 3
      4'h4: seg = 7'b0011001; // 4
      4'h5: seg = 7'b0010010; // 5
      4'h6: seg = 7'b0000010; // 6
      4'h7: seg = 7'b1111000; // 7
      4'h8: seg = 7'b0000000; // 8
      4'h9: seg = 7'b0010000; // 9
      default: seg = 7'b1111111; // blank
    endcase
  end
endmodule
