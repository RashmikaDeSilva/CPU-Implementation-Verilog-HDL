/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 06 - part 1
    
*/

`include "CPU.v"                            // imports CPU module
`include "Data_Memory.v"                    // imports Data Memory module
`include "Cache_Controller.v"               // imports Cache Controller
`include "Instruction_Data_Memory.v"        // imports Instruction Data Memory
`include "Instruction_Cache_Controller.v"   // imports Instruction Cache Controller

`timescale 1ns/100ps

// testbench module
module testbench;

    reg CLK, RESET;               // CLK and RESET
    wire [31:0] PC;               // program counter 
    wire [7:0] ALU_RESULT, REGOUT1, CACHE_READDATA, ADDRESS, CACHE_WRITEDATA;
    wire READENABLE_CACHE, WRITEENABLE_CACHE, CACHE_BUSYWAIT, READENABLE_MEM, WRITEENABLE_MEM, MEM_BUSYWAIT, INSTRUCT_MEM_READENABLE, INSTRUCT_MEM_BUSYWAIT, INSTRUCT_CACHE_BUSYWAIT;
    wire [5:0] MEM_ADDRESS, INSTRUCT_MEM_ADDRESS;
    wire [31:0] MEM_READDATA, MEM_WRITEDATA, INSTRUCTION;
    wire [127:0] INSTRUCT_MEM_READDATA;
    wire [9:0] INSTRUCT_ADDRESS;
    




    // 8x1024 instruction memory
    //reg [7:0] instr_mem [0:1023];
    
    // initializes instruction memory with pre-defined instructions 
    //initial
    //begin
    //  {instr_mem[0], instr_mem[1], instr_mem[2], instr_mem[3]} = 32'b00000001000000000000000000001010;      // loadi 0 0xA
    //  {instr_mem[4], instr_mem[5], instr_mem[6], instr_mem[7]} = 32'b00000001000000010000000000010100;      // loadi 1 0x14
    //  {instr_mem[8], instr_mem[9], instr_mem[10], instr_mem[11]} = 32'b00000001000000100000000000110010;    // loadi 2 0x32
    //  {instr_mem[12], instr_mem[13], instr_mem[14], instr_mem[15]} = 32'b00000010000000110000000000000001;  // add 3 0 1
    //  {instr_mem[16], instr_mem[17], instr_mem[18], instr_mem[19]} = 32'b00000011000001000000001000000001;  // sub 4 2 1
      
    //  {instr_mem[20], instr_mem[21], instr_mem[22], instr_mem[23]} = 32'b00000110000000000000000000000000;  // j 0x0
    //  {instr_mem[24], instr_mem[25], instr_mem[26], instr_mem[27]} = 32'b00001111000000000000010000000011;  // swi 4 0x03
    //  {instr_mem[28], instr_mem[29], instr_mem[30], instr_mem[31]} = 32'b00010000000000000000001100000010;  // swd 3 2
    //  {instr_mem[32], instr_mem[33], instr_mem[34], instr_mem[35]} = 32'b00001101000001010000000000000011;  // lwi 5 0x03
    //  {instr_mem[36], instr_mem[37], instr_mem[38], instr_mem[39]} = 32'b00001110000001100000000000000010;  // lwd 6 2
      
     
  //00010000000000000000001100000010;  // swd 3 2
  //00001110000001100000000000000010;  // lwd 6 2
  //00000110000000000000000000000000;  // j 0x0
  //00001101000001010000000000000011;  // lwi 5 0x03
  //00010000000000000000001100000001;  // swd 3 2
  //00001110000001100000000000000010;  // lwd 6 2
  //00000001000000010000000000010100;  // loadi 1 0x14
  //00000001000000000000000000001010;  // loadi 0 0xA
  //00000001000000100000000000110010;  // loadi 2 0x32
  //00010000000000000000001000000001;  // swd 2 1
  //00001111000000000000001000000001;  // swi 2 0x01
  //00001110000001100000000000000001;  // lwd 6 1
  
  // 00000001000000000000000000001010;  // loadi 0 0xA
  // 00000001000000010000000000010100;  // loadi 1 0x14
  // 00000001000000100000000000110010;  // loadi 2 0x32
  // 00000010000000110000000000000001;  // add 3 0 1
  // 00000011000001000000001000000001;  // sub 4 2 1
  // 00000110000000000000000000000000;  // j 0x0
  // 00001111000000000000010000000011;  // swi 4 0x03
  // 00010000000000000000001100000010;  // swd 3 2
  // 00001101000001010000000000000011;  // lwi 5 0x03
  // 00001110000001100000000000000010;  // lwd 6 2


  //  end
  /*
    // instruction fetching from the instruction memory as PC increments
    always @ (PC) begin
        #2 
        // four 8-bit chuncks which makes one instruction, are outputted as PC increments by 4 
        INSTRCT_ARRAY = {instr_mem[PC], instr_mem[PC+1], instr_mem[PC+2], instr_mem[PC+3]};
    end
  */

    assign INSTRUCT_ADDRESS = PC[9:0];

    // instantiating CPU module
    CPU myCPU(PC, INSTRUCTION, CLK, RESET, READENABLE_CACHE, WRITEENABLE_CACHE, ALU_RESULT, REGOUT1, CACHE_READDATA, CACHE_BUSYWAIT, INSTRUCT_CACHE_BUSYWAIT);
    
    // instantiating Instruction data memory
    Instruction_Data_Memory myInstruction_Data_Memory(CLK, INSTRUCT_MEM_READENABLE, INSTRUCT_MEM_ADDRESS, INSTRUCT_MEM_READDATA, INSTRUCT_MEM_BUSYWAIT);

    // instantiates Instruction Cache Controller
    Instruct_Cache_Controller myInstruct_Cache_Controller(INSTRUCT_ADDRESS, INSTRUCT_MEM_BUSYWAIT, INSTRUCT_MEM_READDATA, INSTRUCT_CACHE_BUSYWAIT, INSTRUCT_MEM_READENABLE, INSTRUCTION, INSTRUCT_MEM_ADDRESS, CLK, RESET);
    
    // instantiates Data Memory module
    Data_Memory myData_Memory(CLK, RESET, READENABLE_MEM, WRITEENABLE_MEM, MEM_ADDRESS, MEM_WRITEDATA, MEM_READDATA, MEM_BUSYWAIT);

    // instantiates Cache Controller
    Cache_Controller myCache_Controller(ALU_RESULT, REGOUT1, MEM_READDATA, MEM_BUSYWAIT, READENABLE_CACHE, WRITEENABLE_CACHE,
                                        MEM_ADDRESS, MEM_WRITEDATA, READENABLE_MEM, WRITEENABLE_MEM, CACHE_BUSYWAIT, CACHE_READDATA,
                                        CLK, RESET);


    initial
    begin
      
      // generates files needed to plot the waveform using GTKWave
      $dumpfile("cpu_wavedata.vcd");
	    $dumpvars(0, testbench);
        
      CLK = 1'b0;
      
      RESET = 1'b1;
      #2
      RESET = 1'b0;     // pulse is given to RESET to start the programme execution

      #5000              // terminates execution after 500 time units
      $finish;
    end

    // clock signal generation
    always
        #4 CLK = ~CLK;
    
endmodule