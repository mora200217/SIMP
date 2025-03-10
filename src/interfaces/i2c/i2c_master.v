module i2c_master (
    input wire clk_50mhz,         // 50 MHz clock input
    input wire rst,               // Reset input
    input wire [7:0] slave_addr,  // Slave address
    input wire [7:0] reg_addr,    // Register address to read from
    output reg [7:0] data_out,    // Data read from the register
    output reg scl,               // I2C Clock line (SCL)
    inout wire sda,               // I2C Data line (SDA)
    output reg ready,             // Ready signal to indicate that I2C transaction is done
    output reg ack                // Acknowledgment signal
);

    // Internal registers for state machine and timing
    reg [7:0] byte_data;          // Data byte for I2C transfer
    reg [7:0] byte_count;         // Byte count for read operation
    reg [7:0] read_data;          // Data read from slave
    reg [3:0] state;              // State machine state
    reg [15:0] clock_divider;     // Clock divider for generating 100 kHz clock from 50 MHz

    // Clock divider for generating 100 kHz clock from 50 MHz input clock
    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            clock_divider <= 0;
            scl <= 1; // Default state for SCL (idle)
        end else if (clock_divider == 499) begin
            scl <= ~scl;  // Toggle SCL every 500 clock cycles (100 kHz)
            clock_divider <= 0;  // Reset the clock divider
        end else begin
            clock_divider <= clock_divider + 1;
        end
    end

    // Tri-state the SDA line
    assign sda = (state == 4'd0) ? 1'bz : byte_data[7];  // High-Z when idle

    // State machine for I2C transactions
    always @(posedge scl or posedge rst) begin
        if (rst) begin
            state <= 4'd0;          // Reset state machine to idle state
            ready <= 1'b1;          // Indicate that the module is ready
            ack <= 1'b0;            // Clear ACK
            byte_count <= 8'd0;     // Reset byte counter
        end else begin
            case (state)
                4'd0: begin // Idle State - Wait for Start Condition
                    ready <= 1'b1;
                    if (ready) begin
                        state <= 4'd1;  // Transition to start condition state
                    end
                end
                4'd1: begin // Start condition
                    byte_data <= {1'b0, slave_addr, 1'b0};  // Send Start bit and slave address
                    state <= 4'd2;  // Move to transmit state
                end
                4'd2: begin // Transmit slave address
                    ack <= sda;  // Check for ACK from slave
                    if (ack) begin
                        byte_data <= reg_addr;  // Send register address to read from
                        state <= 4'd3;  // Move to register address transmit state
                    end else begin
                        state <= 4'd0;  // Go back to idle state if no ACK
                    end
                end
                4'd3: begin // Transmit register address
                    ack <= sda;  // Check for ACK from slave
                    if (ack) begin
                        state <= 4'd4;  // Move to read data state
                    end else begin
                        state <= 4'd0;  // Go back to idle state if no ACK
                    end
                end
                4'd4: begin // Read data from slave
                    read_data <= sda;  // Read 1 bit of data from slave
                    byte_count <= byte_count + 1; // Increment byte counter
                    if (byte_count == 8'd7) begin
                        data_out <= read_data; // Store the received data
                        state <= 4'd5;  // Move to stop condition state
                    end
                end
                4'd5: begin // Stop condition
                    byte_data <= 8'b11111111;  // Send stop condition (SDA high while SCL is high)
                    state <= 4'd0;  // Go back to idle state
                end
                default: begin
                    state <= 4'd0;  // Default to idle state
                end
            endcase
        end
    end

endmodule
