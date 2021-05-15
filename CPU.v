/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
    
*/
`timescale 1ns/100ps
`include "ALU.v"                    // imports ALU module
`include "REG_file.v"               // imports REG_file module
`include "Control_unit.v"           // imports Control_unit module
`include "Supportive_modules.v"     // imports Supportive module file which contains all the sub modules required; such as adders and multiplexers
`include "Barrel_Shifter.v"         // imports Barrel Shifter file which contains barrel shifters for LSL, LSR and ASR
`include "Rotate_module.v"          // imports Rotate- right module

// CPU module
module CPU(PC, INSTRCT_ARRAY, CLK, RESET, READENABLE_CACHE, WRITEENABLE_CACHE, ALU_RESULT, REGOUT1, CACHE_READDATA, CACHE_BUSYWAIT, INSTRUCT_CACHE_BUSYWAIT);

    input [31:0] INSTRCT_ARRAY;                                         // 32 bit array of instruction
    input CLK, RESET, CACHE_BUSYWAIT, INSTRUCT_CACHE_BUSYWAIT;          // clock and reset
    input [7:0] CACHE_READDATA;                                         // input from memory module

    output [31:0] PC;                   // program counter
    output wire READENABLE_CACHE, WRITEENABLE_CACHE;  // outputs from cpu for data memory module (inputs of data memory module) 
    output wire [7:0] ALU_RESULT, REGOUT1;            // outputs from cpu for data memory module                 
    
    // 8-bit inputs and outputs of imported modules
    // REG file and ALU
    wire [7:0] /*REGOUT1,*/ REGOUT2, OPERAND1, OPERAND2, /*ALU_RESULT,*/ REGWRITE_FINAL;    

    // inputs and outputs of shifters
    wire [7:0] SHIFT_LSL, SHIFT_LSR, SHIFT_ASR, SHIFT_ROR, LSL_SHIFTER_OUT, LSR_SHIFTER_OUT, ASR_SHIFTER_OUT, ROR_SHIFTER_OUT;
    
    // inputs and outputs of multiplxers
    wire [7:0] COMPLIMENT, Inverter_MUX_OUT, IM_INPUT, PC_offset;
    
    wire [7:0] SELECT_32x1_MUXOUT;      // output of 32x1 mux
    //wire [7:0] CACHE_READDATA;        // output of Data Memory module

    // 3-bit register addresses and ALU OP code    
    wire [2:0] READREG1, READREG2, WRITEREG, ALU_OP, SHIFT_AMOUNT;

    wire [2:0] SELECT_32x1;                
    
    // 1-bit activation signals for sub module
    wire WRITEENABLE, InvtMUX_SELECT, ImMUX_SELECT, PC_SELECT, COMPARATOR, beqAND_OUT, jump_SELECT, BEQ_SELECT, BNE_SELECT;
    
    // activation signal for Data Memory
    //wire DataMem_WRITEENABLE, DataMem_READENABLE, BUSYWAIT;
    
    // select signal for REG file IN mux
    wire RegFileInMUX_SEL;          
        
    wire [31:0] updatedPC, offsettedPC, newPC;    // temporary varibale to hold incremented PC value

    assign #2 SHIFT_LSL = REGOUT1;  // LSL input - 2 time unit delay added here is the artificial latency added to barrel shifter
    assign #2 SHIFT_LSR = REGOUT1;  // LSR input - 2 time unit delay added here is the artificial latency added to barrel shifter
    assign #2 SHIFT_ASR = REGOUT1;  // ASR input - 2 time unit delay added here is the artificial latency added to barrel shifter
    assign  SHIFT_ROR = REGOUT1;    // ROR input 

    // PC incrementer
    PC_incrementer myPC_Incrementer(PC, updatedPC);

    // PC updater to add PC offset value
    PC_updater myPC_updater(updatedPC, PC_offset, offsettedPC);

    // PC mux
    PC_MUX myPC_MUX(updatedPC, offsettedPC, PC_SELECT, newPC);
    
    // instantiates Control unit module
    Control_unit myControl_unit(
        INSTRCT_ARRAY, newPC, PC, 
        IM_INPUT, PC_offset, SHIFT_LSL, SHIFT_LSR, SHIFT_ASR, SHIFT_ROR, 
        READREG1, READREG2, WRITEREG, ALU_OP, SHIFT_AMOUNT, 
        WRITEENABLE,  ImMUX_SELECT, InvtMUX_SELECT, jump_SELECT, BEQ_SELECT, BNE_SELECT, SELECT_32x1, 
        READENABLE_CACHE, WRITEENABLE_CACHE, CACHE_BUSYWAIT, RegFileInMUX_SEL, INSTRUCT_CACHE_BUSYWAIT, 
        CLK, RESET );

    // instantiates Register file module
    REG_file myREG_file(REGWRITE_FINAL, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
    
    // instantiates 2's compliment module
    Inverter myInverter(REGOUT2, COMPLIMENT);
    
    // instantiates 2's compliment mux
    Inverter_MUX myInverter_MUX(REGOUT2, COMPLIMENT, Inverter_MUX_OUT, InvtMUX_SELECT);
    
    // instantaties immediate mux
    Immediate_MUX myImmediate_MUX(IM_INPUT, Inverter_MUX_OUT, OPERAND2, ImMUX_SELECT); 
    
    // instantiates Barrel shifter for logical left shift
    barrelShifter_LSL myBarrelShifter_LSL(SHIFT_LSL, LSL_SHIFTER_OUT, SHIFT_AMOUNT);

    // instantiates Barrel shifter for logical right shift
    barrelShifter_LSR myBarrelShifter_LSR(SHIFT_LSR, LSR_SHIFTER_OUT, SHIFT_AMOUNT);

    // instantiates Barrel shifter for arithmetic right shift
    barrelShifter_ASR myBarrelShifter_ASR(SHIFT_ASR, ASR_SHIFTER_OUT, SHIFT_AMOUNT);

    // instantiates Rotate-right module
    Rotate_Right myRotate_Right(SHIFT_ROR, ROR_SHIFTER_OUT, SHIFT_AMOUNT);

    // instantiates ALU module
    ALU myALU(REGOUT1, OPERAND2, ALU_OP, ALU_RESULT, COMPARATOR);

    // WRITE FINAL select mux
    SELECT_32x8_MUX mySELECT_32x8_MUX(ALU_RESULT, LSL_SHIFTER_OUT, LSR_SHIFTER_OUT, ASR_SHIFTER_OUT, ROR_SHIFTER_OUT, SELECT_32x1, SELECT_32x1_MUXOUT);
    
    // instantiate REG file IN mux
    REGIN_MUX myREGIN_MUX(SELECT_32x1_MUXOUT, CACHE_READDATA, RegFileInMUX_SEL, REGWRITE_FINAL);

    // AND gate to perfome & operation on COMPARATOR and BEQ signal
    and myAND_BEQ(beqAND_OUT, COMPARATOR, BEQ_SELECT);

    //  AND gate to performe & operation on COMPARATOR signal and BNE signal
    and myAND_BNE(bneAND_OUT, ~COMPARATOR, BNE_SELECT); 

    // OR gate for selection
    or myOR(PC_SELECT, beqAND_OUT, bneAND_OUT, jump_SELECT);
    
endmodule