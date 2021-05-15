/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
    
*/

// Cache memory module
`timescale 1ns/100ps

module Instruct_Cache_Controller(INSTRUCT_ADDRESS, INSTRUCT_MEM_BUSYWAIT, INSTRUCT_MEM_READDATA, INSTRUCT_CACHE_BUSYWAIT, INSTRUCT_MEM_READENABLE, INSTRUCTION, INSTRUCT_MEM_ADDRESS, CLK, RESET);

    /*  inputs to the instruction cache  */
    input CLK, RESET;
    input INSTRUCT_MEM_BUSYWAIT; 
    input [9:0] INSTRUCT_ADDRESS;
    input [127:0] INSTRUCT_MEM_READDATA;

    /*  outputs of instruction cache */
    output reg INSTRUCT_CACHE_BUSYWAIT, INSTRUCT_MEM_READENABLE;
    output reg [31:0] INSTRUCTION;
    output reg [5:0] INSTRUCT_MEM_ADDRESS;

    wire Cache_HIT;                    // cache hit signal
    wire Activator;

    reg [127:0] Cache_table [7:0];       // cache table
    reg [2:0] Tag_array [7:0];          // array that holds corresponding tag values cache table
    reg [7:0] ValidBit_array;           // array that holds corresponding valid bits of tag array  

    // variables to store extracted data, tag, valid and dirty bits
    wire [2:0] TAG;
    wire VALID;
    
    integer i;

    assign Activator = (RESET) ? 0 : 1;
    
    // valid bit array is initially set to zero at reset
    always @ (RESET) begin
      if(RESET) begin
        for(i=0; i<8; i = i+1) begin
            ValidBit_array[i] = 1'b0;
        end
      end
    end

    /*  Combinational part for indexing, tag comparison for hit deciding, etc.  */
   
    assign #1 TAG = Tag_array[INSTRUCT_ADDRESS[6:4]];            // extracted Tag
    assign #1 VALID = ValidBit_array[INSTRUCT_ADDRESS[6:4]];     // extracted valid bit

    // activates busy wait if an address change is detected
    always @ (INSTRUCT_ADDRESS) begin
        INSTRUCT_CACHE_BUSYWAIT = 1'b1;
    end
    
    // tag comparison, validation and hit status determining
    assign #0.9 Cache_HIT = (TAG == INSTRUCT_ADDRESS[9:7] && VALID) ? 1 : 0;

    // asynchronous data word extraction from the cache table. This extracted data word is directly sent to the CPU
    always @ (*) begin
        #1
        // extracts relevant data word based on the byte offset
        case(INSTRUCT_ADDRESS[3:2])
            2'b00: begin INSTRUCTION = Cache_table[INSTRUCT_ADDRESS[6:4]][31:0]; end
            2'b01: begin INSTRUCTION = Cache_table[INSTRUCT_ADDRESS[6:4]][63:32]; end
            2'b10: begin INSTRUCTION = Cache_table[INSTRUCT_ADDRESS[6:4]][95:64]; end
            2'b11: begin INSTRUCTION = Cache_table[INSTRUCT_ADDRESS[6:4]][127:96]; end
        endcase
    end  

    // if cache hit is detected
    always @ (posedge CLK) begin
        if(Cache_HIT) begin
            INSTRUCT_CACHE_BUSYWAIT = 1'b0;                  // de-asserts cache busy wait at the posedge CLK
        end
    end

    // cache update after memory read is done
    always @ (INSTRUCT_MEM_READDATA, INSTRUCT_MEM_BUSYWAIT) begin
        //#1
        if(!INSTRUCT_MEM_BUSYWAIT) begin
            #1
            Cache_table[INSTRUCT_ADDRESS[6:4]] = INSTRUCT_MEM_READDATA;         // updated the respective entry in the cache table with the fetched data block from the memory
            Tag_array[INSTRUCT_ADDRESS[6:4]] = INSTRUCT_ADDRESS[9:7];           // tag entry is also updated with corresponding new tag
            ValidBit_array[INSTRUCT_ADDRESS[6:4]] = 1'b1;                       // valid bit is set to high
            INSTRUCT_MEM_READENABLE = 1'b0;                                     // de-asserts the instruction data memory readenable
        end
    end

    // if cache miss is detected
    always @ (posedge CLK) begin
        if(!Cache_HIT) begin
            INSTRUCT_MEM_READENABLE = 1'b1;
            INSTRUCT_MEM_ADDRESS = INSTRUCT_ADDRESS[9:4];
        end
    end
endmodule

