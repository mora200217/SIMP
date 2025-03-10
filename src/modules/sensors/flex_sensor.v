module flex_sensor (
    input         rst,         // Reset signal
    input         clk,         // Clock signal
    input         i_Clk,       // System clock for SPI
    input         i_Rst_L,     // Active low reset for SPI
    input [7:0]   i_TX_Byte,  // Byte to send on MOSI (SPI data)
    input         i_TX_DV,     // Data Valid pulse for SPI transmission
    output reg    decod,       // Decoded output for flex sensor value
    output wire   o_SPI_Clk,   // SPI Clock
    output wire   o_SPI_MOSI,  // SPI MOSI line
    input wire    i_SPI_MISO   // SPI MISO line (data received from ADC)
);

    // Internal wires and signals
    wire o_TX_Ready;           // SPI ready signal
    reg [7:0] r_ADC_Value;     // Register to store ADC value (8-bit)
    reg [7:0] r_TX_Byte_Internal;  // Internal TX byte for SPI communication
    reg r_TX_DV_Internal;      // Internal data valid signal for SPI transmission

    // Instantiate the SPI Master Module
    SPI_Master #(
        .SPI_MODE(0),                 // Mode 0: CPOL = 0, CPHA = 0
        .CLKS_PER_HALF_BIT(4)         // Adjust as needed for SPI frequency
    ) spi_master_inst (
        .i_Rst_L(i_Rst_L),         // Reset signal
        .i_Clk(i_Clk),             // System clock
        .i_TX_Byte(r_TX_Byte_Internal), // Data to transmit (MOSI)
        .i_TX_DV(r_TX_DV_Internal),    // Data valid signal
        .o_TX_Ready(o_TX_Ready),       // Ready signal for transmission
        .o_RX_DV(),                // Data valid for received data (not used here)
        .o_RX_Byte(),              // Received byte (not used here)
        .o_SPI_Clk(o_SPI_Clk),         // SPI Clock
        .i_SPI_MISO(i_SPI_MISO),       // MISO line input from ADC
        .o_SPI_MOSI(o_SPI_MOSI)        // MOSI line output to ADC
    );

    // State machine or control logic to initiate SPI transaction
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            r_TX_Byte_Internal <= 8'h00;  // Default byte value
            r_TX_DV_Internal <= 1'b0;     // No data valid initially
            r_ADC_Value <= 8'h00;         // Reset ADC value
            decod <= 0;                   // Reset the decoded output
        end
        else begin
            // Start SPI transaction to read ADC (assuming 8-bit ADC value)
            if (o_TX_Ready) begin
                r_TX_Byte_Internal <= 8'h01; // Example SPI command (0x01)
                r_TX_DV_Internal <= 1'b1;    // Indicate data is valid for transmission
            end
            else if (i_SPI_MISO) begin
                r_ADC_Value <= i_SPI_MISO;  // Capture the received ADC value
                decod <= r_ADC_Value;       // Output the decoded value
                r_TX_DV_Internal <= 1'b0;   // Clear the data valid flag
            end
        end
    end

endmodule
