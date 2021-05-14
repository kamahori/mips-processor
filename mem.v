module data_memory
    (
        input wire clk,
        input wire [31:0] address,
        input wire [31:0] WD,
        input wire WE,
        output reg [31:0] RD
    );

    reg [31:0] data_mem [0:1023];

    initial begin
        $readmemh("SampleData.txt", data_mem);
    end

    always @(posedge clk) begin
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
    wire [31:0] ReadDataW;
    wire [31:0] ALUOutW;
    data_memory my_data_mem (clk, ALUOutM, WriteDataM, MemWriteM, ReadData);

    always @(posedge clk) begin 
        ResultW <= MemtoRegW ? ReadDataW : ALUOutW;
        WriteRegW <= WriteRegM;
    end
endmodule