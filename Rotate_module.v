`timescale 1ns/100ps

// module to rotate right
module Rotate_Right(INPUT, SHIFTED_OUTPUT, SHIFT_AMOUNT);
    input [7:0] INPUT;                  // input
    input [2:0] SHIFT_AMOUNT;           // shift distance
    output reg [7:0] SHIFTED_OUTPUT;    // output

    always @ (*) begin
      #2                // 2 time unit delay

      // all possible rotate-right conditions are analyzed via case statements and output is generated accordingly
      case(SHIFT_AMOUNT)

        3'b000: begin SHIFTED_OUTPUT = INPUT; end

        3'b001: begin SHIFTED_OUTPUT = {INPUT[0], INPUT[7:1]}; end

        3'b010: begin SHIFTED_OUTPUT = {INPUT[1:0], INPUT[7:2]}; end

        3'b011: begin SHIFTED_OUTPUT = {INPUT[2:0], INPUT[7:3]}; end

        3'b100: begin SHIFTED_OUTPUT = {INPUT[3:0], INPUT[7:4]}; end

        3'b101: begin SHIFTED_OUTPUT = {INPUT[4:0], INPUT[7:5]}; end

        3'b110: begin SHIFTED_OUTPUT = {INPUT[5:0], INPUT[7:6]}; end

        3'b111: begin SHIFTED_OUTPUT = {INPUT[6:0], INPUT[7]}; end
      endcase
    end
endmodule