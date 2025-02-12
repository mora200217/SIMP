// This code implements the master controller for I2C Protocol
// author: Andrés Morales 


module i2c_master (
    input wire clk,           // System clock
    input wire rst_n,         // Active-low reset
    input wire start,         // Start condition
    input wire read_write,    // 1 = Read, 0 = Write
    input wire [6:0] slave_addr,  // 7-bit slave address
    input wire [7:0] data_in, // Data to send (for write)
    input wire [6:0] reg_addr, 
    output reg [7:0] data_out,// Received data (for read)
    output reg busy,          // Busy flag
    output reg done,          // Transaction complete flag
    output reg scl,           // Serial Clock Line
    inout wire sda            // Serial Data Line (Bidirectional)
);

    reg [3:0] state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg sda_out;
    reg sda_enable;

    assign sda = sda_enable ? sda_out : 1'bz;  // Open-drain SDA line

    localparam IDLE  = 4'b0000,
               START = 4'b0001,
               ADDR  = 4'b0010,
               RW    = 4'b0011,
               ACK1  = 4'b0100,
               WRITE = 4'b0101,
               ACK2  = 4'b0110,
               READ  = 4'b0111,
               STOP  = 4'b1000;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            scl <= 1;
            sda_out <= 1;
            sda_enable <= 1;
            busy <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    data_out <= 0; 
                    if (start) begin
                        state <= START;
                        busy <= 1;
                    end
                end

                START: begin
                    sda_out <= 0; // Start condition
                    scl <= 1;
                    state <= ADDR;
                    shift_reg <= {slave_addr, read_write}; // Address + R/W bit
                    bit_count <= 8;
                end

                ADDR: begin
                    if (bit_count > 0) begin
                        sda_out <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end else begin
                        sda_enable <= 0; // Release SDA for ACK
                        state <= ACK1;
                    end
                end

                ACK1: begin
                    if (!sda) begin // Slave ACK received
                        sda_enable <= 1;
                        state <= (read_write) ? READ : WRITE;
                        shift_reg <= data_in;
                        bit_count <= 8;
                    end
                end

                WRITE: begin
                    if (bit_count > 0) begin
                        sda_out <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end else begin
                        sda_enable <= 0; // Release SDA for ACK
                        state <= ACK2;
                    end
                end

                ACK2: begin
                    if (!sda) begin // Slave ACK received
                        state <= STOP;
                    end
                end

                READ: begin
                    if (bit_count > 0) begin
                        sda_enable <= 0; // Release SDA for reading
                        data_out <= {data_out[6:0], sda};
                        bit_count <= bit_count - 1;
                    end else begin
                        state <= STOP;
                    end
                end

                STOP: begin
                    sda_out <= 0;
                    scl <= 1;
                    sda_out <= 1; // Stop condition
                    done <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

