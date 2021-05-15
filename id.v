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
        reg_file[0] <= 32'b0;
        RD1 <= 32'b0;
        RD2 <= 32'b0;
    end

    always @(A1 or A2 or A3 or WE3 or WD3) begin
        RD1 <= reg_file[A1];
        RD2 <= reg_file[A2];
        if (WE3) begin
            reg_file[A3] <= WD3;
        end
    end

    integer i;
    initial begin
        #50;
        forever begin
            $display ($time, , "t0: %h", reg_file[8][31:0]);
            $display ($time, , "t1: %h", reg_file[9][31:0]);
            $display ($time, , "s0: %h", reg_file[16][31:0]);
            // for (i = 0; i < 32; i = i + 1) begin
            //     $display ($time, , "%h: %h", i, reg_file[i][31:0]);
            // end
            // $display ($time, , "WE3: %h, WD3: %h", WE3, WD3);
            $display ("");
            #200;
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
        output reg [31:0] PCBranchD,
        output wire [5:0] Op,
        output wire [5:0] Funct,
        output reg [31:0] A,
        output reg [31:0] B,
        output reg [4:0] RsE, 
        output reg [4:0] RtE, 
        output reg [4:0] RdE, 
        output wire [4:0] RsD,
        output wire [4:0] RtD,
        output reg EqualD
    );

    assign Op = InstrD[31:26];
    assign Funct = InstrD[5:0];
    wire [4:0] A1 = InstrD[25:21];
    wire [4:0] A2 = InstrD[20:16];
    wire [4:0] A3 = WriteRegW;
    wire [31:0] WD3 = ResultW;
    wire [31:0] RD1;
    wire [31:0] RD2;
    reg [31:0] RD1_;
    reg [31:0] RD2_;
    // assign EqualD = (RD1_ == RD2_);
    assign RsD = InstrD[25:21];
    assign RtD = InstrD[20:16];
    wire [4:0] RdD = InstrD[15:11];
    wire [31:0] SignImmD;
    // assign PCBranchD = SignImmD * 4 + PCPlus4D;
    register_file my_reg_file (clk, A1, A2, A3, WD3, RegWriteW, RD1, RD2);
    sign_extend my_sign_ex (InstrD[15:0], SignImmD);

    initial begin
        SignImmE <= 32'b0;
        PCBranchD <= 32'b0;
        A <= 5'b0;
        B <= 5'b0;
        RsE <= 5'b0;
        RtE <= 5'b0;
        RdE <= 5'b0;
        EqualD <= 0;

        RD1_ <= 32'b0;
        RD2_ <= 32'b0;
        // RsD <= 5'b0;
        // RtD <= 5'b0;
    end

    always @(SignImmD or PCPlus4D) begin
        PCBranchD <= SignImmD * 4 + PCPlus4D;
    end

    always @(ForwardAD or ForwardBD or ALUOutM or RD1 or RD2) begin
        RD1_ <= ForwardAD ? ALUOutM : RD1;
        RD2_ <= ForwardBD ? ALUOutM : RD2;
    end

    always @(RD1_ or RD2_) begin
        EqualD <= (RD1_ == RD2_);
    end
    
    always @(posedge clk) begin
        if (~FlushE) begin 
            A <= RD1_;
            B <= RD2_;
            // Op <= InstrD[31:26];
            // Funct <= InstrD[5:0];

            RsE <= RsD;
            RtE <= RtD;
            RdE <= RdD;
            SignImmE <= SignImmD;
        end
    end

    // initial begin
    //     #15;
    //     forever begin
    //         $display ($time, , "A = %h, B = %h, SignImmE = %h", A, B, SignImmE);
    //         $display ($time, , "A1=%h, A2=%h, A3=%h, RD1=%h, RD2=%h", A1, A2, A3, RD1, RD2);
    //         // $display ($time, , "RsD = %h, RtD = %h, RdD = %h", RsD, RtD, RdD);
    //         $display ($time, , "RsE = %h, RtE = %h, RdE = %h", RsE, RtE, RdE);
    //         #100;
    //     end
    // end
endmodule 