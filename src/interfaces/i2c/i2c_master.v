module i2c_master (
    input wire clk,           // System clock
    input wire rst_n,         // Active-low reset
    input wire start,         // Start condition
    input wire read_write,    // 1 = Read, 0 = Write
    input wire [6:0] slave_addr,  // 7-bit slave address
    input wire [7:0] data_in, // Data to send (for write)
    input wire [6:0] reg_addr, 
    output reg [7:0] data_out, // Received data (for read)
    output reg busy,          // Busy flag
    output reg done,          // Transaction complete flag
    output wire scl,           // Serial Clock Line
    inout wire sda,           // Serial Data Line (Bidirectional)
    output [3:0] state_ind   // Indicating the current state of the FSM

	 );

    reg [3:0] state;
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg sda_out;
    reg sda_enable_master;
	 reg t_scl; 
	 
    assign sda = (sda_enable_master) ? sda_out : 1'bz;  // Open-drain SDA line
    assign scl = (busy) ? clk : 1; 
    // I2C State Machine Definitions
    localparam IDLE  = 4'b0000,
               START = 4'b0001,
               ADDR  = 4'b0010,
               RW    = 4'b0011,
               ACK1  = 4'b0100,
               WRITE = 4'b0101,
               ACK2  = 4'b0110,
               READ  = 4'b0111,
               STOP  = 4'b1000;
    
    // Initial Block to reset the signals
    initial begin
        busy = 0; 
        done = 0;
        t_scl = 0; 
		  end 

    // I2C State Machine
    always @(posedge clk or negedge rst_n) begin	
			
        if (!rst_n) begin
            // Resetting all internal registers and signals
            state <= IDLE;
            sda_out <= 1;
            sda_enable_master <= 1;
            busy <= 0;
            done <= 0;

            data_out <= 0;
      // SCL is high when idle
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    done <= 0;
                    data_out <= 0;
                    // Keep SCL high when idle
                    if (start) begin
                        state <= START;
                        busy <= 1;
                    end
                end

                START: begin
                    sda_out <= 0;  // Start condition: SDA falls while SCL is high
                    sda_enable_master <= 1;
                    state <= ADDR;
                    shift_reg <= {slave_addr, read_write}; // Address + R/W bit
                    bit_count <= 8;
                end

                ADDR: begin
                    sda_enable_master <= 1;
                    if (bit_count > 0) begin
                        sda_out <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end else begin
                        sda_enable_master <= 0; // Release SDA for ACK
                        state <= ACK1;
                    end
                end

               ACK1: begin
							sda_enable_master <= 0;  // Release SDA for ACK
							
							 // Introduce a small delay before checking for ACK (one clock cycle)
							 if (scl) begin  // Wait for the SCL to be high (slave should drive SDA low)
								  if (!sda) begin  // Slave ACK received (SDA low during SCL high)
										state <= (read_write) ? READ : WRITE;  // Proceed based on read/write
										shift_reg <= data_in;  // Load data for write operation
										bit_count <= 8;  // Reset bit count for next operation
								  end else begin  // NACK condition (SDA is high)
										state <= STOP;  // Stop the I2C transaction
								  end
							 end
end


                WRITE: begin
                    if (bit_count > 0) begin
                        sda_enable_master <= 1;
                        sda_out <= shift_reg[7];
                        shift_reg <= shift_reg << 1;
                        bit_count <= bit_count - 1;
                    end else begin
                        sda_enable_master <= 0; // Release SDA for ACK
                        state <= ACK2;
                    end
                end

                ACK2: begin
                    if (!sda && scl) begin // Slave ACK received (SDA low during SCL high)
                        state <= STOP;
                    end else if (scl) begin  // If SDA is high during SCL high, it's a NACK
                        state <= STOP;  // Handle NACK condition
                    end
                end

                READ: begin
                    if (bit_count > 0 && scl) begin
                        sda_enable_master <= 0; // Release SDA for reading
                        data_out <= {data_out[6:0], sda};
                        bit_count <= bit_count - 1;
                    end else if (bit_count == 0) begin
                        state <= STOP;
                    end
                end

                STOP: begin
                    sda_enable_master <= 1;
                    sda_out <= 0;  // Drive SDA low
                    #1; // Small delay to ensure SDA is stable before SCL changes
                    sda_out <= 1;  // Stop condition: SDA rises while SCL is high
                    done <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

    // Indicating the state (inverted state for clarity)
    assign state_ind = ~state;

endmodule
