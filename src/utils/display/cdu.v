// Centenas - decenas - unidades 

module cdu(
    input [6:0] decimal_value, 
    input clk,
    // Cada uno de los valores tiene 4 bits para poder recorrer de 0-9
    output reg [3:0] c, 
    output reg [3:0] d, 
    output reg [3:0] u
); 

    always @(posedge clk ) begin
        u = decimal_value % 10; 
        d = (decimal_value / 10) % 10 ; 
        c = (decimal_value / 100);     
    end

endmodule