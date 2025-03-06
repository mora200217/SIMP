module i2c_master (
    input wire clk,           // 50 MHz system clock
    input wire rst_n,         // Active-low reset
    input wire start,         // Start condition
    input wire read_write,    // 1 = Read, 0 = Write
    input wire [6:0] slave_addr,  // 7-bit slave address
    input wire [7:0] data_in, // Data to send (for write)
    output reg [7:0] data_out, // Received data (for read)
    output reg busy,          // Busy flag
    output reg done,          // Transaction complete flag
    output wire scl,          // Serial Clock Line (Generated)
    inout wire sda            // Serial Data Line (Bidirectional)
);

    // I2C Clock Divider: Generate 100 kHz from 50 MHz
    reg [8:0] clk_div;  // 9-bit counter for 50 MHz to 100 kHz division
    reg scl_int;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_div <= 0;
            scl_int <= 1;
        end else if (clk_div == 249) begin  // 50M / (2 * 100k) - 1 = 249
            clk_div <= 0;
            scl_int <= ~scl_int; // Toggle to generate 100 kHz clock
        end else begin
            clk_div <= clk_div + 1;
        end
    end

    assign scl = scl_int;  // Assign SCL output

    // FSM State Definitions
    typedef enum logic [3:0] {
        IDLE  = 4'b0000,
        START = 4'b0001,
        ADDR  = 4'b0010,
        ACK1  = 4'b0011,
        WRITE = 4'b0100,
        ACK2  = 4'b0101,
        READ  = 4'b0110,
        STOP  = 4'b0111
    } state_t;

    state_t state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg sda_out;
    reg sda_enable;

    assign sda = (sda_enable) ? sda_out : 1'bz;  // Open-drain SDA line

    always @(posedge scl_int or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            busy <= 0;
            done <= 0;
            sda_enable <= 1;
            sda_out <= 1;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    if (start) begin
                        busy <= 1;
                        state <= START;
                    end
                end

                START: begin
                    sda_out <= 0;  // Start condition: SDA goes low while SCL is high
                    state <= ADDR;
                    shift_reg <= {slave_addr, read_write}; // Load address and R/W bit
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
                    if (!sda) begin // ACK received (SDA low)
                        state <= (read_write) ? READ : WRITE;
                        shift_reg <= data_in;
                        bit_count <= 8;
                    end else begin
                        state <= STOP; // NACK detected
                    end
                end

                WRITE: begin
                    if (bit_count > 0) begin
                        sda_enable <= 1;
                        sda_out <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end else begin
                        sda_enable <= 0; // Release SDA for ACK
                        state <= ACK2;
                    end
                end

                ACK2: begin
                    if (!sda) begin // ACK received
                        state <= STOP;
                    end else begin
                        state <= STOP; // NACK detected
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
                    sda_enable <= 1;
                    sda_out <= 0;
                    sda_out <= 1;  // Stop condition
                    done <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
