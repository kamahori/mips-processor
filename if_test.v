`include "clock.v"
`include "if.v"

module IF_test;
    wire clk;
    clock c0 (clk);
    reg [31:0] PCBranchD;
    reg PCSrcD;
    reg StallF;
    reg StallD;
    wire [31:0] InstrD;
    wire [31:0] PCPlus4D;

    initial begin
        PCBranchD <= 23'b0;
        PCSrcD <= 1;
        StallF <= 0;
        StallD <= 0;
    end

    IF my_if (
        clk, 
        PCBranchD, 
        PCSrcD, 
        StallF, 
        StallD, 
        InstrD, 
        PCPlus4D
    );

    initial begin
        #75;
        // PCSrcD <= 0;
        forever begin
            $display ($time, , "PC = %b, instr = %h", PCBranchD, InstrD);
            #50;
            PCSrcD <= 0;
        end
        
    end
    
    initial begin
        #400 $finish;
    end
endmodule