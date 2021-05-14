`include "clock.v"
`include "if.v"

module instruction_memory_test;
    wire clk;
    clock c0 (clk);
    reg [4:0] PC = 5'b0;
    wire [4:0] ALUOut = 5'b0;
    wire IorD = 0;
    wire MemWrite = 0;
    wire IRWrite = 1;
    wire WD = 0;
    wire [31:0] Instr;
    wire [31:0] Data;

    IF my_IF (clk, PC, ALUOut, IorD, MemWrite, IRWrite, WD, Instr, Data);

    initial begin
        #70;
        forever begin
            $display ($time, , "PC = %b, instr = %h", PC, Instr);
            PC <= PC + 1;
            #50;
        end
        
    end
    
    initial begin
        #1000 $finish;
    end
endmodule