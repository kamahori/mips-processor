module instruction_memory
    (
        input wire clk,
        input wire [31:0] address,
        output reg [31:0] RD
    );

    reg [31:0] inst_mem [0:35];

    initial begin
        $readmemh("SampleInst.txt", inst_mem);
    end

    always @(posedge clk) begin
        RD <= inst_mem[address];
    end
endmodule


// instruction fetch
module IF
    (
        input wire clk,
        input wire [31:0] PCBranchD,
        input wire PCSrcD,
        input wire StallF,
        input wire StallD,
        output reg [31:0] InstrD,
        output reg [31:0] PCPlus4D
    );

    wire [31:0] PCPlus4F;
    reg [31:0] PCF;
    wire [31:0] PC_ = (PCSrcD) ? PCBranchD : PCPlus4F;
    wire [31:0] RD;
    instruction_memory my_inst_mem (clk, PCF, RD);

    assign PCPlus4F = PCF + 4;

    always @(posedge clk) begin
        if (~StallF) begin
            assign PCF = PC_;
            // assign PCPlus4F = PCF + 4;
        end
    end
    
    always @(posedge clk) begin
        if (~StallD && ~PCSrcD) begin
            assign InstrD = RD;
            assign PCPlus4D = PCPlus4F;
        end
    end
endmodule