`timescale 1ps/1ps
`include "src/utils/cdu.v"

module segment_display(); 
    // Registers 
    reg [6:0] val; 
    reg clk; 

    // Salidas esperadas 
    wire [3:0] u; 
    wire [3:0] d; 
    wire [3:0] c; 

    // instancia 
    cdu cdu_uut(
        .decimal_value(val), 
        .u(u), 
        .d(d),
        .c(c),
        .clk(clk)
    ); 

    initial clk = 1; 
    always #5 clk = ~clk; 


    initial begin
        #10 val = 0; 
        #10 val = 23; 
        #10 val = 89; 
        #10 val = 112; 
        #10 val = 56; 
        #10 val = 34; 
        $finish; 
    end 


    initial begin:TEST
    $dumpfile("segment_display.vcd");
        $dumpvars(-1, cdu_uut); 
    end 

endmodule