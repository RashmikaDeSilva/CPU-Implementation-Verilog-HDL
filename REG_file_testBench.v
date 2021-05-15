/*
    Name            : De Silva K.R
    Index Number    : E/16/068
    Lab             : Lab 05 - part 2
*/

// imports REG_file module
`include "REG_file.v"

// test bench module
module REG_file_testBench;
    
    reg CLK_t, RESET_t, WRITE_t;                            // CLK, RESET and WRITE inputs 
    reg [7:0] IN_t;                                         // 8 bit input stream IN
    reg [2:0] INADDRESS_t, OUTADDRESS1_t, OUTADDRESS2_t;    // 3 bit address ports
    wire [7:0] OUT1_t, OUT2_t;                              // 8 bit output streams OUT1 and OUT2
    
    // creates an instance from REG_file module
    REG_file myregfile(IN_t, OUT1_t, OUT2_t, INADDRESS_t, OUTADDRESS1_t, OUTADDRESS2_t, WRITE_t, CLK_t, RESET_t);
       
    initial
    begin
        CLK_t = 1'b1;
        
        // generates files needed to plot the waveform using GTKWave
        $dumpfile("REG_file_wavedata.vcd");
		$dumpvars(0, REG_file_testBench);
        
        // assigns values with time to input signals  
        RESET_t = 1'b0;
        WRITE_t = 1'b0;
        
        #1
        RESET_t = 1'b1;
        OUTADDRESS1_t = 3'd1;
        OUTADDRESS2_t = 3'd5;
        
        #8
        RESET_t = 1'b0;
        
        #5
        INADDRESS_t = 3'd1;
        IN_t = 8'd50;
        WRITE_t = 1'b1;
        
        #10
        WRITE_t = 1'b0;
        
        #1
        OUTADDRESS1_t = 3'd3;
        
        #9
        INADDRESS_t = 3'd4;
        IN_t = 8'd80;
        WRITE_t = 1'b1;
        OUTADDRESS1_t = 3'd4;
        
        #10
        WRITE_t = 1'b0;
        
        #10
        INADDRESS_t = 3'd4;
        IN_t = 8'd60;
        WRITE_t = 1'b1;
        
        #10
        IN_t = 8'd40;
        WRITE_t = 1'b1;
        
        #10
        WRITE_t = 1'b0;
        
        #6
        INADDRESS_t = 3'd7;
        IN_t = 8'd20;
        WRITE_t = 1'b1;
        
        #5
        WRITE_t = 1'b0;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #5 CLK_t = ~CLK_t;
        

endmodule
