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
        output reg [1:0] ForwardBE
    );

    reg lwstall;
    reg branchstall;

    initial begin
        StallF <= 0;
        StallD <= 0;
        ForwardAD <= 0;
        ForwardBD <= 0;
        FlushE <= 0;
        ForwardAE <= 2'b00;
        ForwardBE <= 2'b00;
        lwstall <= 0;
        branchstall <= 0;
    end

    always @(RsD or RtE or RtD or MemtoRegE) begin
        lwstall <= ((RsD == RtE) || (RtD == RtE)) && MemtoRegE;
    end 

    always @(BranchD or RegWriteE or WriteRegE or MemtoRegM or WriteRegM or RsD or RtD) begin
        branchstall <= (BranchD && RegWriteE && (WriteRegE == RsD || WriteRegE == RtD)) ||
                       (BranchD && MemtoRegM && (WriteRegM == RsD || WriteRegM == RtD));
    end
    
    always @(RsE or WriteRegM or RegWriteM) begin
        if ((RsE != 0) && (RsE == WriteRegM) && RegWriteM) begin
            ForwardAE <= 2'b10;
        end else if ((RsE != 0) && (RsE == WriteRegM) && RegWriteW) begin
            ForwardAE <= 2'b01;
        end else begin
            ForwardAE <= 2'b00;
        end
    end 

    always @(RtE or WriteRegM or RegWriteM) begin
        if ((RtE != 0) && (RtE == WriteRegM) && RegWriteM) begin
            ForwardBE <= 2'b10;
        end else if ((RtE != 0) && (RtE == WriteRegM) && RegWriteW) begin
            ForwardBE <= 2'b01;
        end else begin
            ForwardBE <= 2'b00;
        end
    end

    always @(lwstall or branchstall) begin
        StallF <= lwstall || branchstall;
        StallD <= lwstall || branchstall;
        FlushE <= lwstall || branchstall;
    end

    always @(RsD or RtD or WriteRegM or RegWriteM) begin
        ForwardAD <= (RsD != 0) && (RsD == WriteRegM) && RegWriteM;
        ForwardBD <= (RtD != 0) && (RtD == WriteRegM) && RegWriteM;
    end

    // initial begin
    //     #15;
    //     forever begin
    //         $display ($time, , "RsD=%h RtE=%h RtD=%h MemtoRegE=%h", RsD, RtE, RtD, MemtoRegE);
    //         $display ($time, , "lwstall = %h, branchstall = %h", lwstall, branchstall);
    //         #50;
    //     end
    // end
endmodule