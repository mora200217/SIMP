`timescale 1ps/1ps
`include "src/modules/imu.v"

module imu_tb;

    reg clk, scl; 
    reg [7:0] reg_addr;  
    reg start; 
    reg rst_n; 
    inout wire sda;

    reg sda_write_slave; 
    reg sda_out; 

    wire [7:0] data_read;  
    wire busy; 
    wire done; 

    integer bit_count;

    // State encoding
    parameter IDLE            = 3'b000,
              RESET           = 3'b001,
              START_CONDITION = 3'b010,
              RECEIVE_ADDR    = 3'b011,
              SEND_ACK        = 3'b100,
              STOP_CONDITION  = 3'b101,
              FINISH          = 3'b110;

    reg [2:0] state; 

    // Clock generation
    initial clk = 0; 
    always #5 clk = ~clk; 

    // I2C SCL clock (20 ps period)
    initial scl = 0;
    always #10 scl = ~scl;

    // Open-drain emulation
    assign sda = (sda_write_slave) ? sda_out : 1'bz; 

    // Instantiate IMU module
    imu imu_uut(
        .reg_addr(reg_addr), 
        .start(start), 
        .clk(clk), 
        .rst_n(rst_n), 
        .data_buff(data_read), 
        .busy(busy), 
        .done(done),
        .sda(sda)
    ); 

    // Initial Conditions
    initial begin
        reg_addr = 8'b00100101;
        sda_write_slave = 0;
        sda_out = 0;
        start = 0;
        rst_n = 0;
        state = IDLE;  
        bit_count = 0;
    end

    // FSM Process
    always @(posedge clk) begin
        case (state)
            IDLE: begin
                state <= RESET;
            end

            RESET: begin
                rst_n <= 0;
                start <= 0;
                state <= START_CONDITION;
            end

            START_CONDITION: begin
                rst_n <= 1;
                start <= 1;
                bit_count <= 0;
                state <= RECEIVE_ADDR;
            end

            RECEIVE_ADDR: begin
                if (bit_count < 8) begin
                    bit_count <= bit_count + 1;
                end else begin
                    state <= SEND_ACK;
                    bit_count <= 0;
                end
            end

            SEND_ACK: begin
                sda_write_slave <= 1;
                sda_out <= 0; // ACK bit

                

                sda_write_slave <= 0; // Release line after ACK
                state <= STOP_CONDITION;
            end

            STOP_CONDITION: begin
                sda_out <= 1;  
                sda_write_slave <= 0;
                state <= FINISH;
            end

            FINISH: begin
                $display("End of transaction");
                $finish;
            end
        endcase
    end

    // VCD Dump for waveform analysis
    initial begin
        $dumpfile("imu_sim.vcd"); 
        $dumpvars(-1, imu_uut);  
    end

endmodule