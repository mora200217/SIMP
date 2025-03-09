module freq_div #(
    parameter N = 4,            // Division factor
    parameter COUNT_SIZE = 4    // Size of the counter (for instance, 4 bits)
) (
    input in_clk,
    output reg out_clk
);

reg [COUNT_SIZE - 1:0] count;  // Counter register

initial begin
     count = 0; 
     out_clk = 0;  // Set the initial output clock to low
end

always @(posedge in_clk) begin
    count <= count + 1;  // Use non-blocking assignment for sequential logic
    
    if (count == (N / 2 - 1)) begin  // Toggle clock every N/2 counts
        out_clk <= ~out_clk; 
        count <= 0;  // Reset counter after toggling clock
    end
end

endmodule
