module instruction_memory
    (
        input wire clk,
        input wire [31:0] address,
        output reg [31:0] RD
    );
    
    reg valid;
    reg [31:0] inst_mem [0:31];

    initial begin
        $readmemh("SampleInst.txt", inst_mem);
    end

    initial begin
        valid <= 0;
        RD <= 32'b0;
    end

    always @(address) begin
        if (valid) begin
            RD <= inst_mem[address];
        end 
        if (!valid) begin
            RD <= 32'b0;
            valid <= 1;
        end
        
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
    
    reg [31:0] PCF;
    reg [31:0] PCPlus4F;
    reg [31:0] PC_;
    wire [31:0] RD;
    instruction_memory my_inst_mem (clk, PCF, RD);

    initial begin
        PCF <= 32'b0;
        PCPlus4F <= 32'b0;
        PC_ <= 32'b0;
        InstrD <= 32'b0;
        PCPlus4D <= 32'b0;
    end

    always @(PCSrcD or PCBranchD or PCPlus4F) begin
        PC_ <= (PCSrcD) ? PCBranchD : PCPlus4F;
    end

    always @(posedge clk) begin
        if (~StallF) begin
            PCF <= PC_;
            PCPlus4F <= PCF + 1;
        end
    end
    
    always @(posedge clk) begin
        if (~StallD) begin
            InstrD <= RD;
            PCPlus4D <= PCPlus4F;
        end
        if (PCSrcD) begin 
            InstrD <= 32'b0;
            PCPlus4D <= 32'b0;
        end
    end
endmodule