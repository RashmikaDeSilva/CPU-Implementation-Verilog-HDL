/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
    
*/

// Cache memory module
`timescale 1ns/100ps

module Cache_Controller(ADDRESS, CACHE_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT, READENABLE_CACHE, WRITEENABLE_CACHE,
                        MEM_ADDRESS, MEM_WRITEDATA, READENABLE_MEM, WRITEENABLE_MEM, CACHE_BUSYWAIT, CACHE_READDATA,
                        CLK, RESET);

    /*  inputs to the Cache memory  */
    input CLK, RESET;
    input READENABLE_CACHE, WRITEENABLE_CACHE, MEM_BUSYWAIT;
    input [7:0] CACHE_WRITEDATA, ADDRESS;
    input [31:0] MEM_READDATA;

    /*  outputs of cache memory */
    output reg CACHE_BUSYWAIT ; 
    output reg READENABLE_MEM, WRITEENABLE_MEM;
    output reg [7:0] CACHE_READDATA;
    output reg [31:0] MEM_WRITEDATA;
    output reg [5:0] MEM_ADDRESS;

     wire Cache_HIT;                    // cache hit signal

    reg [31:0] Cache_table [7:0];       // cache table
    reg [2:0] Tag_array [7:0];          // array that holds corresponding tag values cache table
    reg [7:0] ValidBit_array;           // array that holds corresponding valid bits of tag array
    reg [7:0] DirtyBit_array;           // array that holds corresponding dirty bits of tag array      

    // variables to store extracted data, tag, valid and dirty bits
    wire [2:0] TAG;
    wire VALID, DIRTY, TAG_COMPARED;
    
    integer i;

    // valid bit array is initially set to zero at reset
    always @ (RESET) begin
      if(RESET) begin
        for(i=0; i<8; i = i+1) begin
            ValidBit_array[i] = 1'b0;
        end
        CACHE_BUSYWAIT = 1'b0;
      end
    end

    // dirty bit array is initially set to one at reset
    always @ (RESET) begin
      if(RESET) begin
        for(i=0; i<8; i = i+1) begin
            DirtyBit_array[i] = 1'b1;
        end
      end
    end 

  
    /*  Combinational part for indexing, tag comparison for hit deciding, etc.  */
   
    assign #1 TAG = Tag_array[ADDRESS[4:2]];            // extracted Tag
    assign #1 VALID = ValidBit_array[ADDRESS[4:2]];     // extracted valid bit
    assign #1 DIRTY = DirtyBit_array[ADDRESS[4:2]];     // extracted dirty bit

    // activates busy wait if cache read or write signal is detected
    always @ (READENABLE_CACHE, WRITEENABLE_CACHE) begin
      if(READENABLE_CACHE || WRITEENABLE_CACHE ) begin
            CACHE_BUSYWAIT = 1'b1;
      end
      else begin
            CACHE_BUSYWAIT = 1'b0;
      end   
    end

    
    // tag comparison, validation and hit status determining
    assign #0.9 Cache_HIT = (TAG == ADDRESS[7:5] && VALID) ? 1 : 0;

    // asynchronous data word extraction from the cache table. This extracted data word is directly sent to the CPU
    always @ (*) begin
        #1
        // extracts relevant data word based on the byte offset
        case(ADDRESS[1:0])
            2'b00: begin CACHE_READDATA = Cache_table[ADDRESS[4:2]][7:0]; end
            2'b01: begin CACHE_READDATA = Cache_table[ADDRESS[4:2]][15:8]; end
            2'b10: begin CACHE_READDATA = Cache_table[ADDRESS[4:2]][23:16]; end
            2'b11: begin CACHE_READDATA = Cache_table[ADDRESS[4:2]][31:24]; end
        endcase
    end  

    // if read hit is detected
    always @ (posedge CLK) begin
        if(Cache_HIT && READENABLE_CACHE) begin
            CACHE_BUSYWAIT = 1'b0;                  // de-asserts cache busy wait at the posedge CLK
        end
    end

    // if write hit is detected
    always @ (posedge CLK) begin
        // if cache hit and write enable is detected
        if(Cache_HIT && WRITEENABLE_CACHE) begin
            // cache busy wait is de-asserted at the posedge CLK
            CACHE_BUSYWAIT = 1'b0; 
            
            #1                                              // 1 time unit latency for writing operation                                                
            ValidBit_array[ADDRESS[4:2]] = 1'b1;            // updates valid bit to 1
            DirtyBit_array[ADDRESS[4:2]] = 1'b1;            // updates dirty bit to 1

            // based on the byte offset data word written to the respective locations using a case statement
            case(ADDRESS[1:0])
                2'b11: begin Cache_table[ADDRESS[4:2]][31:24] = CACHE_WRITEDATA; end
                2'b10: begin Cache_table[ADDRESS[4:2]][23:16] = CACHE_WRITEDATA; end
                2'b01: begin Cache_table[ADDRESS[4:2]][15:8] = CACHE_WRITEDATA; end
                2'b00: begin Cache_table[ADDRESS[4:2]][7:0] = CACHE_WRITEDATA; end
            endcase
        end
    end

    // cache update after memory read is done
    always @ (MEM_READDATA, MEM_BUSYWAIT) begin
        //#1
        if(!MEM_BUSYWAIT) begin
            #1
            Cache_table[ADDRESS[4:2]] = MEM_READDATA;       // updated the respective entry in the cache table with the fetched data block from the memory
            Tag_array[ADDRESS[4:2]] = ADDRESS[7:5];         // tag entry is also updated with corresponding new tag
            DirtyBit_array[ADDRESS[4:2]] = 1'b0;            // dirty bit is set to zero
            ValidBit_array[ADDRESS[4:2]] = 1'b1;            // valid bit is set to high
        end
    end


    /* 
        FINITE STATE MACHINE IS USED TO CONTROL THE BEHAVIOR OF THE CACHE MEMORY.
        THIS FSM CONSISTS 3 STATES, NAMELY IDLE, MEM_READ AND WRITEBACK.

        IN IDLE STATE, READ HIT AND WRITE HIT CASES ARE HANDLED AND RELEVANT CACHE UPDATES ARE PERFORMED

        IN MEM_READ STATE, FETCHING DATA BLOCKS FROM THE MEMORY ARE DONE IN DIRTY = 0 STATE.

        IN WRITEBACK STATE, WRITTING DATA BLOCK BACK TO THE MAIN MEMORY IS DONE IN DIRTY = 1 STATE.
    
    */

    /* Cache Controller FSM Start */

    // 4 states of FSM
    parameter IDLE = 2'b00, MEM_READ = 2'b01, MEM_WRITEBACK = 2'b10;
    
    reg [1:0] state, next_state;

    // combinational next state logic
    always @ (*)
    begin
        case (state)
            IDLE:
                if((READENABLE_CACHE || WRITEENABLE_CACHE) && !DIRTY && !Cache_HIT)  
                    next_state = MEM_READ;
                else if((READENABLE_CACHE || WRITEENABLE_CACHE) && DIRTY && !Cache_HIT)
                    next_state = MEM_WRITEBACK;
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!MEM_BUSYWAIT)
                    next_state = IDLE;
                else  
                    // stays in MEM_READ state until data memory finishes its operations  
                    next_state = MEM_READ;
            
            MEM_WRITEBACK:
                if(!MEM_BUSYWAIT)
                    next_state = MEM_READ;
                else
                    // stays in MEM_WRITE state until data memory finishes its operations
                    next_state = MEM_WRITEBACK;
        endcase
    end

    // combinational output logic
    always @ (*)
    begin
        case(state)
            IDLE:
            begin
                READENABLE_MEM = 1'b0;                      // data memory readenable
                WRITEENABLE_MEM = 1'b0;                     // data memory readenable
                MEM_ADDRESS = 8'dx;
                MEM_WRITEDATA = 8'dx;
            end
         
            MEM_READ: 
            begin
                READENABLE_MEM = 1'b1;                      // data memory readenable
                WRITEENABLE_MEM = 1'b0;                     // data memory readenable
                MEM_ADDRESS = ADDRESS[7:2];                 // new address of the cache table location
                MEM_WRITEDATA = 32'd0;
            end

            MEM_WRITEBACK:
            begin
                READENABLE_MEM = 1'b0;                      // data memory readenable
                WRITEENABLE_MEM = 1'b1;                     // data memory writeenable
                MEM_ADDRESS = {TAG, ADDRESS[4:2]};          // address of the memory location in cache table
                MEM_WRITEDATA = Cache_table[ADDRESS[4:2]];  // extracted data word from cache table   
            end
            
        endcase
    end

    // sequential logic for state transitioning 
    always @(posedge CLK, RESET)
    begin
        if(RESET)
            state = IDLE;
        else
            state = next_state;
    end

    /* Cache Controller FSM End */

endmodule



