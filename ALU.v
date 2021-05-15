/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
*/

// Please note that I have changed the names of the ALU inputs and outputs I had given in the previously submitted ALU module
// Also removed the carry-in and carry-out which I had added, just for the sake of completeness of the ALU module,
// in the previously submitted ALU

`timescale 1ns/100ps

// 8 bit ALU module
module ALU (OPERAND1, OPERAND2, ALU_OP, ALU_RESULT, COMPARATOR);
    // ports declaration
    input [7:0] OPERAND1, OPERAND2;             // 8 bit input for operand 1 and operand 2
    input [2:0] ALU_OP;                         // 3 bit input for SELECT
        
    output reg [7:0] ALU_RESULT;                // 8 bit output
    output wire COMPARATOR;                     // additional output check if the result of substraction is zero

    wire [7:0] TEMP_FWD, TEMP_ADD, TEMP_AND, TEMP_OR; // intermediate signals to hold the calculations

    // assigning the values to the different operations
    assign #1 TEMP_FWD = OPERAND2; //forward operation  1
    assign #2 TEMP_ADD = OPERAND1 + OPERAND2; // add operation 2
    assign #1 TEMP_AND = OPERAND1 & OPERAND2; // bitwise and operation 1
    assign #1 TEMP_OR =  OPERAND1 | OPERAND2; // bitwise or operation 1


    always @ (*) 
    begin
        // case statement is used to deal with SELECT input
        case (ALU_OP)
            // FORWARD functional unit which is used by loadi and mov instructions
            3'b000: begin ALU_RESULT = TEMP_FWD; end
            
            // ADD functional unit which is used by add ans subtract instructions
            3'b001: begin ALU_RESULT = TEMP_ADD; end
            
            // OR functional unit which supports "OR" logical operation
            3'b010: begin ALU_RESULT = TEMP_OR; end

            // AND functional unit which supports "and" logical operation
            3'b011: begin ALU_RESULT = TEMP_AND; end
            
            // default case
            // if the SELECT signal doesn't match with any of the above, unknown logical value x is outputted
            default ALU_RESULT = 8'b0;
        endcase
    end

    // NOR gate
    assign COMPARATOR = ~(ALU_RESULT[0] | ALU_RESULT[1] | ALU_RESULT[2] | ALU_RESULT[3] | ALU_RESULT[4] | ALU_RESULT[5] |ALU_RESULT[6] | ALU_RESULT[7]);
    
endmodule


