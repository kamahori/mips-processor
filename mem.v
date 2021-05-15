module data_memory
    (
        input wire clk,
        input wire [31:0] address,
        input wire [31:0] WD,
        input wire WE,
        output reg [31:0] RD
    );

    reg [31:0] data_mem [0:7];

    initial begin
        $readmemh("SampleData.txt", data_mem);
        RD <= 0;
    end

    always @(address or WD or WE) begin
        if (WE) begin
            data_mem[address] <= WD;
        end
        RD <= data_mem[address];
    end
endmodule

module MEM 
    (
        input wire clk,
        input wire [31:0] ALUOutM, 
        input wire [31:0] WriteDataM, 
        input wire [4:0] WriteRegM, 
        input wire MemWriteM, 
        input wire MemtoRegW,
        output reg [31:0] ResultW, 
        output reg [4:0] WriteRegW
    );

    wire [31:0] ReadData;
    reg [31:0] ReadDataW;
    reg [31:0] ALUOutW;
    data_memory my_data_mem (clk, ALUOutM, WriteDataM, MemWriteM, ReadData);

    initial begin
        ResultW <= 32'b0;
        WriteRegW <= 5'b0;

        ReadDataW <= 32'b0;
        ALUOutW <= 32'b0;
    end

    always @(posedge clk) begin
        ReadDataW <= ReadData;
        ALUOutW <= ALUOutM;
        WriteRegW <= WriteRegM;
    end

    always @(MemtoRegW or ReadDataW or ALUOutW) begin 
        ResultW <= MemtoRegW ? ReadDataW : ALUOutW;
    end

    // initial begin
    //     #15;
    //     forever begin
    //         $display ($time, , "ReadDataW = %h, ALUOutW = %h, WriteRegW = %h", ReadDataW, ALUOutW, WriteRegW);
    //         $display ($time, , "ResultW = %h, MemtoRegW = %h", ResultW, MemtoRegW);
    //         #100;
    //     end
    // end
endmodule