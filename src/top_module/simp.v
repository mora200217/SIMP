`include "../src/interfaces/i2c/i2c_master.v"

module simp (
    input clk,               // FPGA built-in clock
    output scl,              // Single master I2C clock
    inout sda,               // Bidirectional I2C data line
    input start,             // Start condition signal to trigger I2C transaction
    input rst_n,             // Active-low reset signal
    output wire [3:0] state_ind, // To indicate the state of the I2C transaction
    output reg led,          // LED indicator for I2C transaction
    output reg led_active,   // LED active state indicator
    output reg led_inactive  // LED inactive state indicator
);
    
    wire sda_reg;
    wire scl_reg;
    
    // IMU Device Address and Register Addresses
    parameter [6:0] IMU_ADDR = 7'h68;  // Device address for IMU
    parameter [6:0] ACCX_LSB_ADDR = 7'h12;  // Accelerometer X low byte address
    parameter [6:0] ACCX_MSB_ADDR = 7'h13;  // Accelerometer X high byte address
    parameter [6:0] ACCY_LSB_ADDR = 7'h14;  // Accelerometer Y low byte address
    parameter [6:0] ACCY_MSB_ADDR = 7'h15;  // Accelerometer Y high byte address
    parameter [6:0] ACCZ_LSB_ADDR = 7'h16;  // Accelerometer Z low byte address
    parameter [6:0] ACCZ_MSB_ADDR = 7'h17;  // Accelerometer Z high byte address

    // Internal wires and registers for I2C operation
    wire done;
    wire busy;
    reg read_write;               // 1 = Read, 0 = Write
    reg [6:0] slave_addr;         // Slave address (IMU)
    reg [7:0] data_in;            // Data to be sent (for write operations)
    wire [7:0] data_out;          // Data received (for read operations)
    reg [6:0] reg_addr;           // Register address (e.g., for ACCX_LSB)
	    reg [7:0] clock_divider;  // Clock divider for generating I2C clock
		 reg clk_div; 
    // Default values during initialization
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            led_active <= 1;
            led_inactive <= 0;
            led <= 0;
            read_write <= 1;           // Default to read mode
            slave_addr <= IMU_ADDR;    // Set the slave address for the IMU
            reg_addr <= ACCX_LSB_ADDR; // Default to reading the accelerometer X low byte
            data_in <= 0;              // No data to write for now
        end
    end
	 
	  // Clock divider for 4generating the I2C clock (adjust for 100kHz)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clock_divider <= 8'd0;
        end else begin
            if (clock_divider == 8'd249) begin  // 50 MHz -> 100 kHz, adjust divider for your system clock
                clk_div <= ~clk_div;  // Toggle SCL to generate I2C clock
                clock_divider <= 8'd0;  // Reset divider
            end else begin
                clock_divider <= clock_divider + 1;
            end
        end
    end

    // I2C Master instance
    i2c_master i2c_master_uut (
        .clk(clk_div),
        .rst_n(rst_n),
        .start(start),
        .read_write(read_write),
        .slave_addr(slave_addr),
        .reg_addr(reg_addr),
        .data_in(data_in),
        .data_out(data_out),
        .busy(busy),
        .done(done),
        .scl(scl_reg),
        .sda(sda_reg),
        .state_ind(state_ind),
    );

    // Control logic for handling state transitions and I2C read/write operations

    // Assign I2C signals
    assign sda = sda_reg;  // Drive sda_reg for write, or release for reading
    assign scl = scl_reg;

 

endmodule
