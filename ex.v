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
				6:  //Subtract
					result = in1 - in2;
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
        output wire [4:0] WriteRegE,
        output reg [4:0] WriteRegM
    );

    wire [31:0] SrcAE = ForwardAE[1] ? ALUOutM : (ForwardAE[0] ? ResultW : A);
    wire [31:0] WriteDataE = ForwardBE[1] ? ALUOutM : (ForwardBE[0] ? ResultW : B);
    wire [31:0] SrcBE = ALUSrcE ? SignImmE : WriteDataE;
    assign WriteRegE = RegDstE ? RdE : RtE;
    wire [31:0] ALUResult;
    ALU my_ALU (clk, SrcAE, SrcBE, ALUControlE, ALUResult);
    always @(posedge clk) begin
        ALUOutM <= ALUResult;
        WriteDataM <= WriteDataE;
        WriteRegM <= WriteRegE;
    end
endmodule