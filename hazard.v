module Hazard 
    (
        input wire clk,
        input wire BranchD,
        input wire [4:0] RsD, 
        input wire [4:0] RtD,
        input wire [4:0] RsE, 
        input wire [4:0] RtE,
        input wire [4:0] WriteRegE, 
        input wire MemtoRegE, 
        input wire RegWriteE,
        input wire [4:0] WriteRegM,
        input wire MemtoRegM, 
        input wire RegWriteM,
        input wire [4:0] WriteRegW,
        input wire RegWriteW,
        output reg StallF, 
        output reg StallD, 
        output reg ForwardAD, 
        output reg ForwardBD, 
        output reg FlushE, 
        output reg [1:0] ForwardAE, 
        output wire [1:0] ForwardBE
    );

    wire lwstall = ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;
    wire branchstall = (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) ||
                       (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));

    initial begin 
        if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM) begin
            assign ForwardAE = 2'b10;
        end else if ((RsE != 0) && (RsE == WriteRegM) && RegWriteW) begin
            assign ForwardAE = 2'b01;
        end else begin
            assign ForwardAE = 2'b00;
        end

        StallF = lwstall || branchstall;
        StallD = lwstall || branchstall;
        FlushE = lwstall || branchstall;

        ForwardAD = (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
        ForwardBD = (RtD != 0) && (RtD == WriteRegM) && RegWriteM;
    end
endmodule