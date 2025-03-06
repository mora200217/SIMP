module bcd (
    input wire [3:0] bin,  // 4-bit input (0-F)
    output wire [6:0] seg  // 7-segment output (active LOW)
);
    assign seg = (bin == 4'h0) ? 7'b1000000 :
                 (bin == 4'h1) ? 7'b1111001 :
                 (bin == 4'h2) ? 7'b0100100 :
                 (bin == 4'h3) ? 7'b0110000 :
                 (bin == 4'h4) ? 7'b0011001 :
                 (bin == 4'h5) ? 7'b0010010 :
                 (bin == 4'h6) ? 7'b0000010 :
                 (bin == 4'h7) ? 7'b1111000 :
                 (bin == 4'h8) ? 7'b0000000 :
                 (bin == 4'h9) ? 7'b0010000 :
                 (bin == 4'hA) ? 7'b0001000 :
                 (bin == 4'hB) ? 7'b0000011 :
                 (bin == 4'hC) ? 7'b1000110 :
                 (bin == 4'hD) ? 7'b0100001 :
                 (bin == 4'hE) ? 7'b0000110 :
                 (bin == 4'hF) ? 7'b0001110 :
                                7'b1111111; // Default: All segments off
endmodule
