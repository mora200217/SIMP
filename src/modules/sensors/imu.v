module imu_bmi160 (
    input wire clk_50mhz,              // 50 MHz clock input
    input wire rst,                    // Reset input
    input wire [7:0] slave_addr,       // I2C slave address (BMI160 address)
    output reg [15:0] acc_x,           // Accelerometer X axis data
    output reg [15:0] acc_y,           // Accelerometer Y axis data
    output reg [15:0] acc_z,           // Accelerometer Z axis data
    output reg ready,                  // Ready signal
    output reg [7:0] roll_angle       // Roll angle output (placeholder for now)
);
    // Internal signals
    reg [7:0] reg_addr_x, reg_addr_y, reg_addr_z;  // Register addresses
    wire scl, sda;                  // I2C clock and data lines
    wire [7:0] data_out;            // Data received from BMI160
    wire ack;                       // ACK signal from I2C master

    // I2C master instance
    i2c_master imu_i2c (
        .clk_50mhz(clk_50mhz),
        .rst(rst),
        .slave_addr(slave_addr),
        .data_out(data_out),
        .ready(ready),
        .ack(ack),
        .scl(scl),
        .sda(sda)
    );

    // State machine to manage reading accelerometer data
    reg [2:0] state;               // State machine for reading accelerometer data
    reg [7:0] byte_count;          // Byte count for reading data

    // States
    localparam IDLE = 3'b000;
    localparam READ_ACC_X = 3'b001;
    localparam READ_ACC_Y = 3'b010;
    localparam READ_ACC_Z = 3'b011;

    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            acc_x <= 16'b0;
            acc_y <= 16'b0;
            acc_z <= 16'b0;
            byte_count <= 8'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (ready) begin
                        state <= READ_ACC_X;  // Start reading accelerometer data
                    end
                end
                READ_ACC_X: begin
                    if (ack) begin
                        reg_addr_x <= 8'h12;  // Address for ACC_X_LSB register
                        // Request to read ACC_X
                        state <= READ_ACC_Y;
                    end
                end
                READ_ACC_Y: begin
                    if (ack) begin
                        reg_addr_y <= 8'h14;  // Address for ACC_Y_LSB register
                        // Request to read ACC_Y
                        state <= READ_ACC_Z;
                    end
                end
                READ_ACC_Z: begin
                    if (ack) begin
                        reg_addr_z <= 8'h16;  // Address for ACC_Z_LSB register
                        // Request to read ACC_Z
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

    // Assign roll_angle as a placeholder for the accelerometer data (it could be calculated externally)
    always @(posedge clk_50mhz or posedge rst) begin
        if (rst) begin
            roll_angle <= 8'b0;
        end else begin
            // You can calculate the roll angle externally using the acc_x, acc_y, and acc_z values
            // For now, we'll just output the accelerometer data (you can modify this as needed)
            roll_angle <= acc_x[7:0]; // Placeholder for now
        end
    end

endmodule
