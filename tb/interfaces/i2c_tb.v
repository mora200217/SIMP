`timescale 1ns / 1ps
`include "src/interfaces/i2c/i2c_master.v"

module tb_i2c_master;

    reg clk;
    reg rst_n;
    reg start;
    reg read_write;
    reg [6:0] slave_addr;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire busy, done;
    wire scl;
    wire sda;

    reg sda_slave;   // Simulated slave SDA line
    reg sda_from_slave; 


    // Instantiate I2C Master
    i2c_master uut(
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .read_write(read_write),
        .slave_addr(slave_addr),
        .data_in(data_in),
        .data_out(data_out),
        .busy(busy),
        .done(done),
        .scl(scl),
        .sda(sda)
    );

    // Clock generator (100 MHz)
    always #5 clk = ~clk;

    initial begin
        // Initialize signals
        sda_slave = 0; 
        clk = 0;
        rst_n = 0;
        start = 0;
        read_write = 0;
        slave_addr = 7'b1010101; // Example address
        data_in = 8'h3C;
        sda_slave = 0;
        

        #20 rst_n = 1;  // Release reset

        // Read operation
        #50 read_write = 1;
        #10 start = 1;
        #10 start = 0;

        // Simulate data from slave
        #100
        sda_slave = 1; 
        sda_from_slave = 0; // ACK
        #10 sda_from_slave = 1; // Data bit 1
        #10 sda_from_slave = 0; // Data bit 0
        #10 sda_from_slave = 1; // Data bit 0
        #10 sda_from_slave = 1; // Data bit 0
        #10 sda_from_slave = 1; // Data bit 0
        #10 sda_from_slave = 1; // Data bit 0
        #10 sda_from_slave = 0; // Data bit 0
        #10 sda_from_slave = 1; // Stop

        #100
        // sda_slave = 0; 
        // sda_from_slave = 0; 
        #50
        sda_slave = 0; 

        $finish;
    end

    assign sda = (sda_slave) ? sda_from_slave :  1'bz ; // Open-drain emulation

    initial begin:TEST_BENCH
        $dumpfile("i2c_sim.vcd"); 
        $dumpvars(0, uut); 
    end 

endmodule
