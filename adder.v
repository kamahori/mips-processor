module adder
    (
        input wire [3:0] a,
        input wire [3:0] b,
        output wire[4:0] s
    );
    assign s = a + b;
endmodule