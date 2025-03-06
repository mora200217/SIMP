module spi_master (
    input wire clk,        // System clock
    input wire rst,        // Reset
    input wire start,      // Start SPI communication
    input wire [7:0] mosi_data, // Data to send (optional)
    output reg sclk,       // SPI clock
    output reg cs,         // Chip Select (Active Low)
    output reg mosi,       // Master Out, Slave In (optional)
    input wire miso,       // Master In, Slave Out
    output reg [7:0] miso_data, // Received data
    output reg done        // Communication done flag
);

    parameter CLK_DIV = 10; // Adjust for SPI clock speed

    reg [3:0] bit_count;
    reg [7:0] shift_reg;
    reg [15:0] clk_counter;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk <= 0;
            cs <= 1;  // Chip Select inactive
            bit_count <= 0;
            clk_counter <= 0;
            done <= 0;
        end else if (start) begin
            cs <= 0;  // Activate slave
            done <= 0;
            
            if (clk_counter < CLK_DIV / 2)
                clk_counter <= clk_counter + 1;
            else begin
                clk_counter <= 0;
                sclk <= ~sclk; // Toggle clock
                
                if (sclk) begin
                    shift_reg <= {shift_reg[6:0], miso}; // Shift in MISO bit
                    bit_count <= bit_count + 1;
                    
                    if (bit_count == 7) begin
                        miso_data <= shift_reg;
                        done <= 1;
                        cs <= 1; // End SPI communication
                    end
                end
            end
        end
    end
endmodule
