`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2025 06:58:14 PM
// Design Name: 
// Module Name: tick_1hz_ppm
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


// tick_1hz_ppm.sv
// Parametric tick with ppm trim using a fractional accumulator.
// Produces a 1-cycle pulse at TICK_HZ with average frequency corrected by TRIM_PPM.
module tick_1hz_ppm #(
  parameter int unsigned CLK_HZ   = 100_000_000,
  parameter int unsigned TICK_HZ  = 1,
  // Trim in parts-per-million: + makes tick faster, - makes it slower
  parameter int signed   TRIM_PPM = 0
)(
  input  logic clk,
  input  logic rstn,       // active-low reset
  output logic tick        // 1-cycle pulse
);
  // Base integer divider (floor)
  localparam int unsigned BASE_DIV = CLK_HZ / TICK_HZ;      // clocks per tick
  localparam int unsigned REMA     = CLK_HZ % TICK_HZ;      // remainder (if any)

  // We implement: number of input cycles per output tick =
  //   BASE_DIV (+1 occasionally if REMA>0 to cover non-integer ratios)
  // Then apply ppm trim by slightly biasing how often we add/subtract one cycle.

  // Fractional accumulators (Bresenham)
  logic [$clog2(TICK_HZ+1)-1:0] rem_acc;     // handles non-integer CLK_HZ/TICK_HZ
  // ppm accumulator uses 32-bit to be safe; ppm step per tick = CLK_HZ * TRIM_PPM / 1e6 / TICK_HZ
  // We'll approximate with an accumulator scaled by 1e6.
  logic signed [31:0] ppm_acc;
  localparam int signed ONE_MILLION = 1_000_000;

  // countdown for current tick period
  int unsigned cnt;
  int unsigned target;     // current period in input clocks

  // compute next target period:
  //   start with BASE_DIV
  //   +1 if rem_acc + REMA crosses TICK_HZ
  //   ±1 occasionally based on ppm_acc sign crossing ONE_MILLION
  function automatic int unsigned next_target(
      input int unsigned rem_acc_in,
      input logic signed [31:0] ppm_acc_in
  );
    int unsigned t = BASE_DIV;

    // add +1 some ticks to distribute fractional remainder (non-integer base ratio)
    if (REMA != 0 && (rem_acc_in + REMA) >= TICK_HZ)
      t = t + 1;

    // ppm trim: TRIM_PPM >0 => speed up => shorten period by 1 occasionally
    //           TRIM_PPM <0 => slow down => lengthen period by 1 occasionally
    if (TRIM_PPM > 0) begin
      if ((ppm_acc_in + TRIM_PPM) >= ONE_MILLION)
        t = (t > 1) ? t - 1 : 1;   // shorten by 1
    end else if (TRIM_PPM < 0) begin
      if ((ppm_acc_in + TRIM_PPM) <= -ONE_MILLION)
        t = t + 1;                 // lengthen by 1
    end
    return t;
  endfunction

  // state
  always_ff @(posedge clk) begin
    if (!rstn) begin
      cnt     <= 0;
      target  <= BASE_DIV;
      rem_acc <= '0;
      ppm_acc <= '0;
      tick    <= 1'b0;
    end else begin
      tick <= 1'b0;
      if (cnt == 0) begin
        // emit tick
        tick <= 1'b1;

        // update fractional rema accumulator
        if (REMA != 0) begin
          if ((rem_acc + REMA) >= TICK_HZ)
            rem_acc <= rem_acc + REMA - TICK_HZ;
          else
            rem_acc <= rem_acc + REMA;
        end

        // update ppm accumulator
        if (TRIM_PPM != 0) begin
          int signed next_ppm = ppm_acc + TRIM_PPM;
          if (TRIM_PPM > 0 && next_ppm >= ONE_MILLION)
            ppm_acc <= next_ppm - ONE_MILLION;
          else if (TRIM_PPM < 0 && next_ppm <= -ONE_MILLION)
            ppm_acc <= next_ppm + ONE_MILLION;
          else
            ppm_acc <= next_ppm;
        end

        // compute next period and reload
        target <= next_target(rem_acc, ppm_acc);
        cnt    <= next_target(rem_acc, ppm_acc) - 1;
      end else begin
        cnt <= cnt - 1;
      end
    end
  end
endmodule
