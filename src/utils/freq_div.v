module freq_div #(
    parameter N = 4,
    parameter COUNT_SIZE = 4
) (
    input in_clk,
    output reg out_clk
);

reg [COUNT_SIZE - 1:0] count;  // 4 bits predeterminado

initial begin
     count = 0; 
     out_clk = 1; 
end

always @(posedge in_clk ) begin
    count = count + 1; 
    if (count % (N-1) == 0) begin
        out_clk <= ~out_clk; 
    end 
end
    
endmodule