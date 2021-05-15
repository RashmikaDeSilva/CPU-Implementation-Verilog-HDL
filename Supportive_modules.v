/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
*/

`timescale 1ns/100ps

// 2's compliment unit
module Inverter(INPUT, COMPLIMENT);
  input [7:0] INPUT;              // 8 bit input
  output reg [7:0] COMPLIMENT;    // output as the compliment of input

  always @ (*) begin
    #1
    // input is inverted
    COMPLIMENT = ~INPUT + 8'b00000001;
  end
endmodule


// 2's compliment mux module
module Inverter_MUX(INPUT, INVRTD_INPUT, OUTPUT, InvtMUX_SELECT);
  input [7:0] INPUT, INVRTD_INPUT;        // 8 inputs
  input InvtMUX_SELECT;                   // InvtMUX_SELECT = 1 to get inverted input as output
  output reg [7:0] OUTPUT;                // output

  always @ (*) begin 
    // if select is 1, inverted input is outputted 
    if(InvtMUX_SELECT) begin OUTPUT = INVRTD_INPUT; end
    // else,  non-inverted output is outputted
    else begin OUTPUT = INPUT; end
  end
endmodule


// immediate mux module
module Immediate_MUX(IM_INPUT, INPUT, OUTPUT, ImMUX_SELECT);
  input [7:0] IM_INPUT, INPUT;          // 8 bit inputs
  input ImMUX_SELECT;                   // SELECT = 1 to get immediate input as output 
  output reg [7:0] OUTPUT;              // output

  always @ (*) begin
    // if SELECT is 1, immediate input is outputted
    if(ImMUX_SELECT) begin OUTPUT = IM_INPUT; end
    // else, other input (output from inverter mux) is outputted
    else begin OUTPUT = INPUT; end
  end
endmodule


// dedicated adder to increment PC
module PC_incrementer(PC, updatedPC);
  input [31:0] PC;
  output reg [31:0] updatedPC;   // temporary variable to hold updated PC value

  always @ (PC) begin
    #1
    updatedPC = PC + 32'd4;
  end
endmodule


// adder to update PC value according to j or beq instruction
module PC_updater(updatedPC, PC_offset, offsettedPC);
  input [31:0] updatedPC;           // updatedPC -  normally incremented PC value by 4
  input [7:0] PC_offset;            // PC_offset -  offset value to be added to PC from j and beq instruction
  output reg [31:0] offsettedPC;    // newly updated PC value with added offset

  always @ (updatedPC) begin
    #2
    offsettedPC = updatedPC + {{24{PC_offset[7]}}, PC_offset, 2'b00};
  end
endmodule


// PC mux module
module PC_MUX(updatedPC, offsettedPC, PC_SELECT, newPC);
  input [31:0] updatedPC, offsettedPC;        // inputs - regularly updated PC (increment by 4) and offsetted PC
  input PC_SELECT;                            // select input of PC_MUX
  output reg [31:0] newPC;                    // output

  always @ (*) begin
    // if select is true offsetted PC is outputted
    if(PC_SELECT) begin
      newPC = offsettedPC;
    end
    // else, regularly updated PC is outputted
    else begin newPC = updatedPC; end
  end
endmodule


// MUX module to select correct write signal to be written to REG file
module SELECT_32x8_MUX(ALU_RESULT, LSL_SHIFTER_OUT, LSR_SHIFTER_OUT, ASR_SHIFTER_OUT, ROR_SHIFTER_OUT, SELECT_32x1, SELECT_32x1_MUXOUT);
  input [7:0] ALU_RESULT, LSL_SHIFTER_OUT, LSR_SHIFTER_OUT, ASR_SHIFTER_OUT, ROR_SHIFTER_OUT;   // outputs of shifters
  input [2:0] SELECT_32x1;                  // mux select signal
  output reg [7:0] SELECT_32x1_MUXOUT;      // output of the 32x1 mux

  always @ (*) begin

    // to get ALU result
    if(SELECT_32x1 == 3'b000) begin SELECT_32x1_MUXOUT = ALU_RESULT; end

    // to get logical left shift result
    else if(SELECT_32x1 == 3'b001) begin SELECT_32x1_MUXOUT = LSL_SHIFTER_OUT; end

    // to get logical right shift result 
    else if(SELECT_32x1 == 3'b010) begin SELECT_32x1_MUXOUT = LSR_SHIFTER_OUT; end

    // to get arithmetic right shift result
    else if(SELECT_32x1 == 3'b011) begin SELECT_32x1_MUXOUT = ASR_SHIFTER_OUT; end

    // to get rotate right result
    else if(SELECT_32x1 == 3'b100) begin SELECT_32x1_MUXOUT = ROR_SHIFTER_OUT; end
  end
endmodule

// MUX to select input to written to REG file 
module REGIN_MUX(SELECT_32x1_MUXOUT, DataMem_READDATA, RegFileInMUX_SEL, REGWRITE_FINAL);
  input [7:0] SELECT_32x1_MUXOUT, DataMem_READDATA;   // inputs from REG file and ALU
  input RegFileInMUX_SEL;                             // selection input
  output reg [7:0] REGWRITE_FINAL;                    // final output to be written to reg file

  always @ (*) begin
    // if mux selector is high data is read from data memory and assigned to the output stream
    if(RegFileInMUX_SEL) begin
      REGWRITE_FINAL = DataMem_READDATA;
    end
    // else output from the 32x1 mux is assigned to the output stream
    else begin
      REGWRITE_FINAL = SELECT_32x1_MUXOUT;
    end
  end
endmodule