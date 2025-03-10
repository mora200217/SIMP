module simp (
    input wire rst,            // Reset signal
    input wire clk_50m,        // 50 MHz clock
    input wire wr_en,          // Write enable for transmitting data
    output wire tx,            // UART transmit line to ESP32
    output wire tx_busy,       // UART transmit busy signal
    input wire rx,             // UART receive line (not used for sending)
    output wire rdy,           // Ready signal (not used for sending)
    input wire rdy_clr         // Clear ready signal (not used for sending)
);

    // Internal wires for the outputs from the flex sensor and IMU
    wire [15:0] flex_out;      // Output from Flex Sensor
    wire [15:0] imu_out;       // Output from IMU Sensor (Roll Angle)

    // Mean of flex and IMU
    wire [15:0] mean_angle;    // Mean value of flex and imu sensor data

    // Signals for the ESP32 UART module
    wire esp32_wr_en;          // Write enable for sending data to ESP32

    // Instantiate the flex_sensor module
    // flex_sensor flex_inst (
    //     .rst(rst),               // Reset signal
    //     .decod(flex_out)         // Output to be connected to flex_out
    // );

    // Instantiate the imu_bmi160 module (IMU module for reading roll angle)
    imu_bmi160 imu_inst (
        .clk_50mhz(clk_50m),     // 50 MHz clock
        .rst(rst),               // Reset signal
        .slave_addr(8'h68),      // Example I2C address for BMI160 (can be changed)
        .acc_x(),                // Not used for roll angle, you can ignore it
        .acc_y(),                // Not used for roll angle, you can ignore it
        .acc_z(),                // Not used for roll angle, you can ignore it
        .ready(),                // Ready signal from IMU
        .roll_angle(imu_out)     // Roll angle output from IMU
    );

    // Mean calculation (simple integer mean calculation)
    assign mean_angle = (flex_out + imu_out) >> 1;  // Mean: (flex + imu) / 2

    // Instantiate the ESP32 UART module to send the mean angle
    uart_send_float_to_esp32 esp32_inst (
        .angle(mean_angle),      // The mean angle value to be sent
        .wr_en(wr_en),           // Write enable for UART transmission
        .clk_50m(clk_50m),       // Clock input
        .tx(tx),                 // UART transmit line
        .tx_busy(tx_busy),       // UART transmit busy signal
        .rx(rx),                 // UART receive line (not used here)
        .rdy(rdy),               // Ready signal (not used here)
        .rdy_clr(rdy_clr)        // Clear ready signal (not used here)
    );

endmodule
