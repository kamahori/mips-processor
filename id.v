module register_file 
    (
        input wire clk,
        input wire [4:0] A1,
        input wire [4:0] A2,
        input wire [4:0] A3,
        input wire [31:0] WD3,
        input wire WE3,
        output reg [31:0] RD1,
        output reg [31:0] RD2
    );

    reg [31:0] reg_file [0:31];

    initial begin
        $readmemh("SampleReg.txt", reg_file);
    end

    always @(posedge clk) begin
        RD1 <= reg_file[A1];
        RD2 <= reg_file[A2];
        if (WE3) begin
            reg_file[A3] <= WD3;
        end
    end
endmodule 

module sign_extend 
    (
        input wire [15:0] in, 
        output wire [31:0] out 
    );
    
    assign out = {{16{in[15]}}, in};
    
endmodule 

// InstrDuction decode 
module ID 
    (
        input wire clk, 
        input wire [31:0] InstrD,
        input wire [31:0] ResultW, 
        input wire [31:0] ALUOutM,
        input wire [31:0] PCPlus4D,
        input wire [4:0] WriteRegW,
        input wire RegWriteW,
        input wire ForwardAD,
        input wire ForwardBD,
        input wire FlushE,
        output reg [31:0] SignImmE,
        output wire [31:0] PCBranchD,
        output reg [5:0] Op,
        output reg [5:0] Funct,
        output reg [31:0] A,
        output reg [31:0] B,
        output reg [4:0] RsE, 
        output reg [4:0] RtE, 
        output reg [4:0] RdE, 
        output wire [4:0] RsD,
        output wire [4:0] RtD,
        output wire EqualD
    );

    wire [4:0] A1 = InstrD[25:21];
    wire [4:0] A2 = InstrD[20:16];
    wire [4:0] A3 = WriteRegW;
    wire [31:0] WD3 = ResultW;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] RD1_ = ForwardAD ? ALUOutM : RD1;
    wire [31:0] RD2_ = ForwardBD ? ALUOutM : RD2;
    assign EqualD = (RD1_ == RD2_);
    // wire [4:0] RsD = InstrD[25:21];
    // wire [4:0] RtD = InstrD[20:16];
    wire [4:0] RdD = InstrD[15:11];
    wire [31:0] SignImmD;
    assign PCBranchD = SignImmD * 4 + PCPlus4D;
    register_file my_reg_file (clk, A1, A2, A3, WD3, RegWriteW, RD1, RD2);
    sign_extend my_sign_ex (InstrD[15:0], SignImmD);

    always @(posedge clk) begin
        if (~FlushE) begin 
            A <= RD1_;
            B <= RD2_;
            Op <= InstrD[31:26];
            Funct <= InstrD[5:0];

            RsE <= RsD;
            RtE <= RtD;
            RdE <= RdD;
            SignImmE <= SignImmD;
        end
    end
endmodule 