module clock 
    (
        output reg clock
    );
    initial clock = 0;

    always begin
        #50 clock = ~clock;
    end
endmodule