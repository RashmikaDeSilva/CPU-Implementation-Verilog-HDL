/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 05 - part 1
*/

// imports ALU module
`include "ALU.v"

// test bench module
module testBench;
    reg [7:0] DATA1_t, DATA2_t; // 8 bit reg variables for inputs DATA1 and DATA2
    reg [2:0] SELECT_t;         // 3 bit reg variable for SELECT 
    reg Cin_t;                  // 1 bit carry-in 
    wire [7:0] RESULT_t;        // 8 bit variable for output RESULT
    wire Cout_t;                // 1 bit carry-out

    // creates an instance from ALU module
    ALU testALU(DATA1_t,DATA2_t,SELECT_t,Cin_t, RESULT_t, Cout_t);

    // initial block to print output and dump data for GTK Wave
    initial
    begin
        // for command line output
        $monitor($time, "Data1_t: %b, Data2_t: %b, Select_t: %b, Result_t: %b, Cin_t: %b, Cout_t: %b",DATA1_t,DATA2_t,SELECT_t,RESULT_t,Cin_t,Cout_t);
        // dumps data to visualize in GTK Wave
        $dumpfile("wavedata_alu.vcd");
        $dumpvars(0,testBench);
    end

    // initial block for testing
    initial
    begin
        
        Cin_t = 1'b0;               // Since there's no carry in this demonstration, Cin_t in is initially set to 0
                                    // if carry-in is needed, it can be added from here.

        // test for the FORWARD funtional unit
        SELECT_t = 3'b000;
        DATA1_t = 8'b11111111;      // initially DATA2_t is set to 11111111. It can be changed
        DATA2_t = 8'b00000001;      // initially DATA1_t is set to 00000001. It can be changed
                
        #10
        // test fot the ADD functional unit
        SELECT_t = 3'b001;
        DATA1_t = 8'b01010101;      // initially DATA2_t is set to 01010101. It can be changed
        DATA2_t = 8'b00000011;      // initially DATA1_t is set to 00000011. It can be changed

        #10
        // test for OR functional unit
        SELECT_t = 3'b010;
        DATA1_t = 8'b11011011;      // initially DATA2_t is set to 11011011. It can be changed
        DATA2_t = 8'b00000111;      // initially DATA1_t is set to 00000111. It can be changed

        #10
        // test for AND funtional unit
        SELECT_t = 3'b011;
        DATA1_t = 8'b10101010;      // initially DATA2_t is set to 10101010. It can be changed
        DATA2_t = 8'b00001111;      // initially DATA1_t is set to 00001111. It can be changed
    
    end

endmodule