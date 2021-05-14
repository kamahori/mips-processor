module Control
    (
        input clk,
        input wire [5:0] Op, 
        input wire [5:0] Funct,
        input wire EqualD,
        output wire PCSrcD, 
        output wire BranchD,
        output reg RegDstE, 
        output reg ALUSrcE, 
        output reg [2:0] ALUControlE,
        output reg MemWriteM,
        output reg MemtoRegW, 
        output reg RegWriteW
    );
    
    wire RegWriteD = ((Op == 6'b100011) || // lw
                      (Op == 6'b001000));  // addi
    wire MemtoRegD = (Op == 6'b100011);
    wire MemWriteD = (Op == 6'b101011);
    reg [2:0] ALUControlD;
    wire ALUSrcD = ((Op == 6'b100011) || // lw
                    (Op == 6'b101011) || // sw
                    (Op == 6'b001000));  // addi
    wire RegDstD = (Op == 6'b000000);
    assign BranchD = (Op == 6'b000011); // beq

    initial begin
        if (Op == 6'b0) begin
            ALUControlD = 2'b10;
        end else if (Op == 6'b000100 || Op == 6'b000101) begin
            // BEQ, BNE
            ALUControlD = 2'b01;
        end else if (Op == 6'b100011 || 6'b101011) begin
            // LW, SW
            ALUControlD = 2'b00;
        end else if (Op == 6'b001000) begin
            // ADDI
            ALUControlD = 2'b10;
        end
    end

    reg RegWriteE;
    reg MemtoRegE;
    reg MemWriteE;

    reg RegWriteM;
    reg MemtoRegM;

    assign PCSrcD = BranchD && EqualD;

    always @(posedge clk) begin
        RegWriteE <= RegWriteD;
        MemtoRegE <= MemtoRegD;
        MemWriteE <= MemWriteD;
        ALUControlE <= ALUControlD;
        ALUSrcE <= ALUSrcD;
        RegDstE <= RegDstD;
    end

    always @(posedge clk) begin
        RegWriteM <= RegWriteE;
        MemtoRegM <= MemtoRegE;
        MemWriteM <= MemWriteE;
    end

    always @(posedge clk) begin
        RegWriteW <= RegWriteM;
        MemtoRegW <= MemtoRegM;
    end

endmodule