`include "src/interfaces/uart/baud_rate_gen.v"
`include "src/interfaces/uart/receiver.v"
`include "src/interfaces/uart/transmitter.v"

module uart_send_float_to_esp32 (
    input wire [31:0] angle,  // 32-bit float represented as an integer (IEEE-754 format)
    input wire wr_en,          // Write enable for UART transmission
    input wire clk_50m,        // 50 MHz clock
    output wire tx,            // UART transmit line
    output wire tx_busy,       // UART busy signal
    input wire rx,             // UART receive line (not used for sending)
    output wire rdy,           // Ready signal (not used for sending)
    input wire rdy_clr         // Clear ready signal (not used for sending)
);

    wire rxclk_en, txclk_en;

    // Baud rate generator for the transmitter and receiver clock enables
    baud_rate_gen uart_baud(
        .clk_50m(clk_50m),
        .rxclk_en(rxclk_en),
        .txclk_en(txclk_en)
    );

    // Transmitter for sending the float (as 4 bytes) to ESP32
    reg [7:0] byte_data;        // 8-bit data to send via UART
    reg [1:0] byte_count;       // Counter for sending 4 bytes of the float

    // Logic for converting the float to bytes and sending over UART
    always @(posedge clk_50m) begin
        if (wr_en) begin
            case (byte_count)
                2'b00: byte_data <= angle[31:24];  // First byte: MSB
                2'b01: byte_data <= angle[23:16];  // Second byte
                2'b10: byte_data <= angle[15:8];   // Third byte
                2'b11: byte_data <= angle[7:0];    // Fourth byte: LSB
            endcase
        end
    end

    always @(posedge clk_50m) begin
        if (wr_en && !tx_busy) begin
            // Send the byte through UART
            if (byte_count < 2'b11) begin
                byte_count <= byte_count + 1;  // Increment to send the next byte
            end
            else begin
                byte_count <= 2'b00;           // Reset byte counter after sending 4 bytes
            end
        end
    end

    // Instantiate the UART transmitter
    transmitter uart_tx(
        .din(byte_data),          // Data to be transmitted (current byte of the float)
        .wr_en(wr_en),            // Write enable signal
        .clk_50m(clk_50m),        // Clock input
        .clken(txclk_en),         // Clock enable for UART transmission
        .tx(tx),                  // UART transmit line
        .tx_busy(tx_busy)         // UART transmit busy signal
    );

endmodule
