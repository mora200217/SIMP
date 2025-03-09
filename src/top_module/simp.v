// `include "../src/interfaces/i2c/i2c_controller_master.v"
`include "src/utils/freq_div.v"
`include "src/interfaces/i2c/i2c_master.v"

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
	 
     /* 
    
     */ 
    
    // Commnunication interfaes 
    // i2c 

    // i2c_controller_master master_uut(
    //     .clk(clk), // clk principal sin division de freq 
    //     .rst(!rst_n), // reset no negado 
    //     .addr(slave_addr), // Direccion de esclavo para abrir el bus de comununicacion 
    //     .data_in(data_in), 
    //     .enable(start), 
    //     .rw(read_write), 
    //     .data_out(data_out), 
    //     .ready(done), 
    //     .i2c_sda(sda), 
    //     .i2c_scl(scl)
    // ); 

    wire [2:0] o_status; 
    wire [7:0] o_data; 
    wire strobe; 


    freq_div #(
        .N(500),                   // Divide by 500
        .COUNT_SIZE(9)             // 9-bit counter (since 500 < 2^9)
    ) clk_div_inst (
        .in_clk(clk),         // 50 MHz input clock
        .out_clk(clk_100kHz)        // 100 kHz output clock
    );

    i2c_master master_uut(
    .i_addr_data(slave_addr),		// Address and Data
    .i_cmd(read_write),			// Command (r/w)
    .i_strobe(strobe),			// Latch inputs
    .i_clk(clk_100kHz),
    .io_sda(sda),
    .io_scl(scl),
    .o_data(o_data),		// Output data on reads
    .o_status(o_status)
    ); 


    // Control logic for handling state transitions and I2C read/write operations

    // Assign I2C signals
    // assign sda = sda_reg;  // Drive sda_reg for write, or release for reading
    // assign scl = scl_reg;

 

endmodule
