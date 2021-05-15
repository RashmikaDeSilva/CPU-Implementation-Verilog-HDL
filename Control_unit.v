/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
    
*/

/* 
  IMPORTANT : TO WHOM IT MAY CONCERN

   PLEASE NOTE THAT TO SUPPORT THE NEWLY ADDED INSTRUCTION FOR MEMORY MODULE, OP CODES OF INSTRUCTIONS
  ( BITS 31-24 ) WERE COMPLETED RECONFIGURED AND CHANGED IN THIS IMPLEMENTATION. OP CODES USED IN LAB 05 ( 4 BIT COMBINATION )
  ARE NOT THE SAME AS USED IN THIS LAB 06 ( 5 BIT COMBINATION ). ALSO NOTE THAT ALU OP CODE GIVEN IN THE LAB SHEET, REMAIN UNCHANGED.
  NEWLY DESIGNED OP CODES ARE GIVEN BELOW.

*/

// This file contains the Control unit module

`timescale 1ns/100ps

// Control unit module
module Control_unit(
    INSTRCT_ARRAY, newPC, PC, 
    IM_INPUT, PC_offset, SHIFT_LSL, SHIFT_LSR, SHIFT_ASR, SHIFT_ROR, 
    READREG1, READREG2, WRITEREG, ALU_OP, SHIFT_AMOUNT, 
    WRITEENABLE,  ImMUX_SELECT, InvtMUX_SELECT, jump_SELECT, BEQ_SELECT, BNE_SELECT, SELECT_32x1, 
    READENABLE_CACHE, WRITEENABLE_CACHE, CACHE_BUSYWAIT, RegFileInMUX_SEL, INSTRUCT_CACHE_BUSYWAIT, 
    CLK, RESET
);

input CLK, RESET, CACHE_BUSYWAIT, INSTRUCT_CACHE_BUSYWAIT;        // clock and reset inputs
input [31:0] INSTRCT_ARRAY, newPC;                                // instruction set and temporary variable to  hold incremented PC

output reg [31:0] PC;           // program counter
output reg [2:0]  ALU_OP;       // 3-bit alu opcode
output reg [2:0] SELECT_32x1;   // 3-bit 32x1 mux select signal

// 1 bit select signal for multiplexers and logic gates
output reg ImMUX_SELECT, InvtMUX_SELECT, jump_SELECT, BEQ_SELECT, BNE_SELECT, RegFileInMUX_SEL; 

// 1 bit select signals related to Cache controller module
output reg READENABLE_CACHE, WRITEENABLE_CACHE;   

// read and write register indices and ALU op code signals                                     
output wire [2:0] READREG1, READREG2, WRITEREG, SHIFT_AMOUNT;

// immediate input (source register 2)
output wire  [7:0] IM_INPUT, PC_offset, SHIFT_LSL, SHIFT_LSR, SHIFT_ASR, SHIFT_ROR;   

// write enable signal for REG file
output reg WRITEENABLE;                 

// resets PC to -4 when RESET is high
always @ (*) begin
  if(RESET) begin
    PC = -4;
  end
end

// updates PC by 4 in every positive clock edge
always @ (posedge CLK) begin
  #1
  if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin
    PC = newPC;
  end
end

assign WRITEREG = INSTRCT_ARRAY[18:16];     // write reg address
assign READREG1 = INSTRCT_ARRAY[10:8];      // read reg address 1
assign READREG2 = INSTRCT_ARRAY[2:0];       // read reg address2
assign IM_INPUT = INSTRCT_ARRAY[7:0];       // assign immediate value to immediate mux input, if any
assign PC_offset = INSTRCT_ARRAY[23:16];    // PC offset
     
assign #2 SHIFT_AMOUNT = INSTRCT_ARRAY[7:0];  // shift distance

// instruction decoding
always @ (INSTRCT_ARRAY) begin
  READENABLE_CACHE = 1'b0;  // flushes the input fed in the previous instruction
  WRITEENABLE_CACHE = 1'b0; // flushes the input fed in the previous instruction
  #1
  // OP_CODE bits are used to deocode instruction
  // custom OP_CODE definitions are used to handle respective instructions
  case(INSTRCT_ARRAY[28:24])
    
    // mov instruction
    5'b00000: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select 

      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end
    end

    // loadi instruction
    5'b00001: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b1;              // immediate mux select is set to output immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end
    end

    // add instruction
    5'b00010: begin
      ALU_OP = 3'b001;                  // sets ALU op code to ADD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end
    end

    // sub instruction
    5'b00011: begin
      ALU_OP = 3'b001;                  // sets ALU op code to ADD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b1;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // OR instruction
    5'b00100: begin
      ALU_OP = 3'b010;                  // sets ALU op code to OR function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // AND instruction
    5'b00101: begin
      ALU_OP = 3'b011;                  // sets ALU op code to AND function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // jump instruction
    5'b00110: begin
      ALU_OP = 3'b111;                  // default case 

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b1;               // jump instruction select is set to 1
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      //if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      WRITEENABLE = 1'b0;

    end

    // branch-equal instruction
    5'b00111: begin
      ALU_OP = 3'b001;                  // sets ALU op code to ADD function

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b1;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b1;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      //if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      WRITEENABLE = 1'b0;

    end

    // branch-not equal instruction
    5'b01000: begin
      ALU_OP = 3'b001;                  // sets ALU op code to ADD function

      BNE_SELECT = 1'b1;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b1;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      //if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      WRITEENABLE = 1'b0;

    end  

    // logical shift left instruction
    5'b01001: begin
      ALU_OP = 3'b111;                  // defualt case

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b001;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // logical shift right instruction
    5'b01010: begin
      ALU_OP = 3'b111;                  // defualt case

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b010;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // arithmetic shift right instruction
    5'b01011: begin
      ALU_OP = 3'b111;                  // defualt case

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b011;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // rotate right instruction
    5'b01100: begin
      ALU_OP = 3'b111;                  // defualt case

      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 1 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0
      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input
      SELECT_32x1 = 3'b100;             // 3-bit 32x1 mux select signal
      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b0;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // load word immediate instruction
    5'b01101: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0

      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b1;              // immediate mux select is set to output non-immediate input

      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal

      READENABLE_CACHE = 1'b1;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b1;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // load word direct instruction
    5'b01110: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0

      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input

      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal

      READENABLE_CACHE = 1'b1;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b0;       // data memory write enable
      RegFileInMUX_SEL = 1'b1;          // REG file IN mux select
      
      if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      else begin WRITEENABLE = 1'b0; end

    end

    // store word immediate instruction
    5'b01111: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0

      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b1;              // immediate mux select is set to output non-immediate input

      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal

      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b1;       // data memory write enable
      RegFileInMUX_SEL = 1'b1;          // REG file IN mux select

      //if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      WRITEENABLE = 1'b0;

    end

    // store word direct instruction
    5'b10000: begin
      ALU_OP = 3'b000;                  // sets ALU op code to FORWARD function
      
      BNE_SELECT = 1'b0;
      BEQ_SELECT = 1'b0;                // branch instruction select is set to 0 
      jump_SELECT = 1'b0;               // jump instruction select is set to 0

      InvtMUX_SELECT = 1'b0;            // 2's compliment mux select is set to output non-inverted input
      ImMUX_SELECT = 1'b0;              // immediate mux select is set to output non-immediate input

      SELECT_32x1 = 3'b000;             // 3-bit 32x1 mux select signal

      READENABLE_CACHE = 1'b0;        // data memory read enable signal
      WRITEENABLE_CACHE = 1'b1;       // data memory write enable
      RegFileInMUX_SEL = 1'b1;          // REG file IN mux select

      //if(!(CACHE_BUSYWAIT | INSTRUCT_CACHE_BUSYWAIT)) begin WRITEENABLE = 1'b1; end
      WRITEENABLE = 1'b0;

    end     
      
    default ;
  endcase
end
endmodule




















