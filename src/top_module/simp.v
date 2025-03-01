`include "../src/interfaces/i2c/i2c_master.v"

module simp (
    input clk, // FPGA buil-in clock 
    output scl, // Single master I2C arch 
    inout sda, // Bidirectional natura 
    input start,
	 input rst_n,
	 output wire [3:0] state_ind
);

parameter [6:0] IMU_ADDR =7'h68; // Direccion de dispositivo

// Direcciones de las aceleraciones 
parameter [6:0] ACCX_LSB_ADDR = 7'h12;    
parameter [6:0] ACCX_MSB_ADDR = 7'h13;    

parameter [6:0] ACCY_LSB_ADDR = 7'h14;    
parameter [6:0] ACCY_MSB_ADDR = 7'h15;    

parameter [6:0] ACCZ_LSB_ADDR = 7'h16;    
parameter [6:0] ACCZ_MSB_ADDR = 7'h17;  

// La frecuencia de reloj es 100kHz 

wire done; 
wire busy; 


reg read_write; 

reg [6:0] slave_addr; 
reg [7:0] data_in; 
wire [7:0] data_out; 

reg [6:0] reg_addr; 





initial begin
    read_write = 1; 
    // Definicion de registros importantes 
    slave_addr = IMU_ADDR; 
    reg_addr = 7'h12; // registro de Accx 
	
    data_in = 0; 
end 

i2c_master i2c_master_uut(
        // input  
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .read_write(read_write),
        .slave_addr(slave_addr),
        .reg_addr(reg_addr),
        .data_in(data_in),
        // output 
        .data_out(data_out),
        .busy(busy),
        .done(done),
        .scl(scl),
        .sda(sda),
		  .state_ind(state_ind)
); 









endmodule