module ALU 
    (
        input wire clk,
        input wire signed [31:0] in1, 
        input wire signed [31:0] in2, 
        input wire [2:0] ALUControl,
        output reg signed [31:0] result
    );

    reg signed [63:0] HiLo;
	// assign zero = (result == 0);
	//Initialize internal register
	
	initial begin
        HiLo = 0;
        result <= 32'b0;
    end
	//Calculate combinational operations: Forward, Or, add, sub, and MFHI/LO
	always @(in1 or in2 or ALUControl)
		begin
			casex (ALUControl)
				0:  //No ALU operation, forward input 1
					result = in1;
				1:  //Bitwise OR
					result = in1 | in2;
				2:  //Add
					result = in1 + in2;
				3:  //MFHI
					result = HiLo[63:32];
				4:  //MFLO
					result = HiLo[31:0];
                5:  //Multiplication
                    result = in1 * in2;
				6:  //Subtract
					result = in1 - in2;
                // 7:  //Divison
                //     resutl = in1 / in2;
			endcase
			
		end
	//Multiply and divide results are only stored at clock falling edge.
	always @(negedge clk)
		begin
			if(ALUControl == 5) //Multiply
				HiLo = in1 * in2;
			if(ALUControl == 7) 
				begin//Divide
					HiLo[31:0] = in1 / in2;
					HiLo[63:32] = in1 % in2;
				end
				
		end
endmodule

// execution
module EX 
    (
        input wire clk,
        input wire [31:0] A,
        input wire [31:0] B,
        input wire [31:0] SignImmE,
        input wire [4:0] RtE, 
        input wire [4:0] RdE,
        input wire [31:0] ResultW,
        input wire RegDstE,
        input wire ALUSrcE,
        input wire [2:0] ALUControlE,
        input wire [1:0] ForwardAE,
        input wire [1:0] ForwardBE,
        output reg [31:0] ALUOutM,
        output reg [31:0] WriteDataM,
        output reg [4:0] WriteRegE,
        output reg [4:0] WriteRegM
    );

    reg [31:0] SrcAE;
    reg [31:0] WriteDataE;
    reg [31:0] SrcBE;
    wire [31:0] ALUResult;
    ALU my_ALU (clk, SrcAE, SrcBE, ALUControlE, ALUResult);

    initial begin
        ALUOutM <= 32'b0;
        WriteDataM <= 32'b0;
        WriteRegE <= 5'b0;
        WriteRegM <= 5'b0;

        SrcAE <= 32'b0;
        WriteDataE <= 32'b0;
        SrcBE <= 32'b0;
    end

    always @(ForwardAE or ALUOutM or ResultW or A) begin
        SrcAE <= ForwardAE[1] ? ALUOutM : (ForwardAE[0] ? ResultW : A);
    end

    always @(ForwardBE or ALUOutM or ResultW or B) begin
        WriteDataE <= ForwardBE[1] ? ALUOutM : (ForwardBE[0] ? ResultW : B);
    end 

    always @(ALUSrcE or SignImmE or WriteDataE) begin
        SrcBE <= ALUSrcE ? SignImmE : WriteDataE;
    end 

    always @(RegDstE or RdE or RtE) begin
        WriteRegE <= RegDstE ? RdE : RtE;
    end

    always @(posedge clk) begin
        ALUOutM <= ALUResult;
        WriteDataM <= WriteDataE;
        WriteRegM <= WriteRegE;
    end
endmodule