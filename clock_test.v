// module clock 
//     (
//         output reg clock
//     );
//     initial clock = 0;

//     always begin
//         #50 clock = ~clock;
//     end
// endmodule

module clock_test;
    wire clk;
    clock c0 (clk);

    initial begin
        forever begin
            #20;
            $display ($time, , "clock = %b", clk);
        end
        
    end
    
    initial begin
        #1000 $finish;
    end
endmodule