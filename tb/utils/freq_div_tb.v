`timescale 1ps/1ps
`include "src/utils/freq_div.v"

module moduleName;

reg clk; // Clock de la FPGA 
wire clk_div; 

initial clk = 0; 
always #5 clk = ~clk; 

freq_div freq_div_uut(clk, clk_div); 

initial #500 $finish;

initial begin:TEST
    $dumpfile("freq_div.vcd"); 
    $dumpvars(1, freq_div_uut); 
end


endmodule