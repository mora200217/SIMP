`include "src/interfaces/i2c/i2c_master.v"

module imu  #(
    parameter DEV_ADDR = 7'h68 // Default addr 
) (
    input [7:0] reg_addr, 
    input start, 
    input clk, 
    inout wire sda, 
    input rst_n, 
    output [7:0] data_buff, // data leída 
    output busy, 
    output done,
    output slc
);

reg read_write; 
reg [1:0] state; //  

i2c_master uut(
    .clk(clk), 
    .rst_n(rst_n),
    .start(start), 
    .read_write(read_write), 
    .slave_addr(DEV_ADDR), 
    .scl(scl),
    .data_in(reg_addr),
    .data_out(data_buff), 
    .busy(busy),
    .done(done),
    .sda(sda)
); 

initial begin
    read_write = 1; // 1 read - 0 write
    state = 2'b00; 
end 



endmodule