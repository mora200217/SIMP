`timescale 1ps/1ps
`include "simp.v"

module simp_tb;

reg clk; 
wire scl; 
wire  sda;
reg start; 

initial clk = 0; 
always #5 clk = ~clk; 

// instances 
simp simp_uut(clk, scl, sda, start); 

initial begin
     
     start = 1; 
     #50; 
     $finish; 


end 


initial begin:TB
     $dumpfile("simp_sim.vcd"); 
     $dumpvars(1, simp_uut); 
end
    
endmodule