
`include "Barrel_Shifter.v"
    `timescale 1ns / 1ps

    module barrelShifter_tb;

     // Inputs

     reg [7:0] INPUT;

     reg [2:0] SHIFT_AMOUNT;

     // Outputs

     wire [7:0] OUTPUT;

     // Instantiate the Unit Under Test (UUT)

     barrelShifter uut (INPUT, OUTPUT, SHIFT_AMOUNT);

     initial begin

      // Initialize Inputs

      INPUT    = 8'd0;

      SHIFT_AMOUNT = 3'd0;

      // Wait 100 ns for global reset to finish

      #100;

      // Add stimulus here

      INPUT    = 8'd16;

      SHIFT_AMOUNT = 3'd2;

      #20;

      INPUT    = 8'd4;

      SHIFT_AMOUNT = 3'd2;

     end

    endmodule


