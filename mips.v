`include "clock.v"
`include "if.v"
`include "id.v"
`include "ex.v"
`include "mem.v"
`include "control.v"
`include "hazard.v"

module mips;
    wire clk; 
    clock my_clk (clk);

    // Control Unit
    wire [5:0] Op;
    wire [5:0] Funct;
    wire EqualD;

    wire RegWriteD;
    wire MemtoRegD;
    wire MemWriteD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire RegDstD;
    wire BranchD;
    wire PCSrcD;

    wire RegWriteE;
    wire MemtoRegE;
    wire MemWriteE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;
    wire RegDstE;

    wire RegWriteM;
    wire MemtoRegM;
    wire MemWriteM;

    wire RegWriteW;
    wire MemtoRegW;

    Control my_ctrl (
        clk, 
        Op, 
        Funct, 
        EqualD, 
        PCSrcD, 
        BranchD,
        RegDstE, 
        ALUSrcE, 
        ALUControlE,
        MemtoRegE,
        MemWriteM,
        MemtoRegW,
        RegWriteW
    );

    // Hazard Unit
    wire StallF;
    wire StallD;
    wire ForwardAD;
    wire ForwardBD;
    wire FlushE;
    wire [1:0] ForwardAE;
    wire [1:0] ForwardBE;
    Hazard my_hzd (
        clk, 
        BranchD, 
        RsD,
        RtD,
        RsE,
        RtE,
        WriteRegE,
        MemtoRegE,
        RegWriteE,
        WriteRegM,
        MemtoRegM,
        RegWriteM,
        WriteRegM,
        RegWriteW,
        StallF,
        StallD,
        ForwardAD,
        ForwardBD,
        FlushE,
        ForwardAE,
        ForwardBE
    );

    wire [31:0] PCBranchD;
    wire [31:0] InstrD;
    wire [31:0] PCPlus4D;
    IF my_if (
        clk, 
        PCBranchD, 
        PCSrcD, 
        StallF, 
        StallD, 
        InstrD, 
        PCPlus4D
    );

    wire [31:0] ResultW;
    wire [31:0] ALUOutM;
    wire [4:0] WriteRegW;
    wire [31:0] SignImmE;
    wire [31:0] ID_A;
    wire [31:0] ID_B;
    wire [4:0] RsE;
    wire [4:0] RtE;
    wire [4:0] RdE;
    wire [4:0] RsD;
    wire [4:0] RtD;
    ID my_id (
        clk, 
        InstrD, 
        ResultW, 
        ALUOutM, 
        PCPlus4D, 
        WriteRegW, 
        RegWriteW, 
        ForwardAD, 
        ForwardBD,
        FlushE,
        SignImmE,
        PCBranchD,
        Op,
        Funct,
        ID_A,
        ID_B,
        RsE,
        RtE,
        RdE,
        RsD,
        RtD,
        EqualD
    );

    wire [31:0] WriteDataM;
    wire [4:0] WriteRegE;
    wire [4:0] WriteRegM;
    EX my_ex (
        clk,
        ID_A,
        ID_B,
        SignImmE,
        RtE,
        RdE,
        ResultW,
        RegDstE,
        ALUSrcE,
        ALUControlE,
        ForwardAE,
        ForwardBE,
        ALUOutM,
        WriteDataM,
        WriteRegE,
        WriteRegM
    );

    MEM my_mem (
        clk, 
        ALUOutM, 
        WriteDataM, 
        WriteRegM,
        MemWriteM, 
        MemtoRegW,
        ResultW, 
        WriteRegW
    );

    initial begin
        #1000 $finish;
    end
endmodule