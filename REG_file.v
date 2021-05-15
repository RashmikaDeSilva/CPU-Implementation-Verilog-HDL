/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
*/

// Please note that I have changed the names of the REG_file inputs and outputs I had given in the previously submitted REG_file module

`timescale 1ns/100ps

// register file module
module REG_file(REGWRITE, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);

input CLK, RESET, WRITEENABLE;                              // CLK, RESET and WRITE inputs
input [7:0] REGWRITE;                                       // 8 bit input stream IN
input [2:0] WRITEREG, READREG1, READREG2;                   // 3 bit address ports
output wire [7:0] REGOUT1, REGOUT2;                         // 8 bit output streams OUT1 and OUT2

integer i;                                                  // for, for-loop                           

// an array with 8, 8-bit locations
reg [7:0] register_array [0:7];

always @ (*) begin
    // resets all registers to zero when RESET is triggered
    if(RESET) begin
        #2
        for(i=0; i<8; i=i+1) begin
            register_array[i] = 0;
        end
    end
end

always @ (posedge CLK) begin
    // for storing a register with value in IN
    if(WRITEENABLE) begin
        // stores IN stream values in the respective register
        register_array[WRITEREG] = #2 REGWRITE;
    end
end   

// retrieving values stored in
assign #1 REGOUT1 =  register_array[READREG1];
assign #1 REGOUT2 =  register_array[READREG2];

endmodule

