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
        output reg MemtoRegE,
        output reg MemWriteM,
        output reg MemtoRegW, 
        output reg RegWriteW
    );
    
    wire RegWriteD = ((Op == 6'b100011) || // lw
                      (Op == 6'b001000) || // addi
                      (Op == 6'b000000));  // R type
    wire MemtoRegD =  (Op == 6'b100011);   // lw
    wire MemWriteD =  (Op == 6'b101011);   // sw
    wire   ALUSrcD = ((Op == 6'b100011) || // lw
                      (Op == 6'b101011) || // sw
                      (Op == 6'b001000));  // addi
    wire   RegDstD =  (Op == 6'b000000);   // R type
    assign BranchD =  (Op == 6'b000100);   // beq

    reg [2:0] ALUControlD;

    initial begin
        RegDstE <= 0;
        ALUSrcE <= 0;
        ALUControlE <= 3'b0;
        MemtoRegE <= 0;
        MemWriteM <= 0;
        MemtoRegW <= 0;
        RegWriteW <= 0;

        ALUControlD <= 2'b0;
        RegWriteE <= 0;
        MemWriteE <= 0;
        RegWriteM <= 0;
        MemtoRegM <= 0;
    end

    always @(Op) begin
        if (Op == 6'b000000) begin
            // R type
            ALUControlD = 2'b10;
            casex (Funct)
                // or
                // 6'b101010: ALUControlD = 3'b001;

                // add 
                6'b100000: ALUControlD = 3'b010;

                // nop
                6'b000000: ALUControlD = 3'b000;

                // subtract
                6'b100010: ALUControlD = 3'b110;

                // mult
                6'b011000: ALUControlD = 3'b101;

                // div
                // 6'b011010: ALUControlD = 3'b111;

            endcase
        end 
        
        if (Op == 6'b000100) begin
            // beq
            ALUControlD = 3'b110;
        end 
        
        if (Op == 6'b100011 || 6'b101011) begin
            // lw, sw
            ALUControlD = 3'b010;
        end 
        
        if (Op == 6'b001000) begin
            // addi
            ALUControlD = 3'b010;
        end
    end

    reg RegWriteE;
    // reg MemtoRegE;
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

    // initial begin
    //     #15;
    //     forever begin
    //         $display ($time, , "MemtoRegD = %h", MemtoRegD);
    //         $display ($time, , "ALUControlD = %h, ALUControlE = %h", ALUControlD, ALUControlE);
    //         #100;
    //     end
    // end
endmodule