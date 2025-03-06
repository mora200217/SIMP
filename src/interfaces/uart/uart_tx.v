module uart_tx (
    input wire clk,        // System clock
    input wire rst,        // Reset
    input wire tx_start,   // Start transmission
    input wire [7:0] data, // Data to send
    output reg tx,         // UART TX line
    output reg busy        // Transmission busy flag
);
    
    parameter CLK_PER_BIT = 868; // Adjust based on baud rate (50 MHz / 115200)
    
    reg [3:0] bit_index;
    reg [8:0] shift_reg;
    reg [15:0] baud_counter;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 0;
            tx <= 1;
            bit_index <= 0;
            baud_counter <= 0;
        end else if (tx_start && !busy) begin
            busy <= 1;
            shift_reg <= {1'b1, data, 1'b0}; // Start + Data + Stop
            bit_index <= 0;
            baud_counter <= 0;
        end else if (busy) begin
            if (baud_counter < CLK_PER_BIT - 1)
                baud_counter <= baud_counter + 1;
            else begin
                baud_counter <= 0;
                tx <= shift_reg[0]; // Send bit
                shift_reg <= shift_reg >> 1;
                bit_index <= bit_index + 1;
                if (bit_index == 9)
                    busy <= 0;
            end
        end
    end
endmodule
