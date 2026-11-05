`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2026 09:12:28 PM
// Design Name: 
// Module Name: top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module top(
    input wire clk,
    input wire reset,
    input wire [15:0] sw,
    output wire [15:0] led,
    
    input wire uart_rx,
    
    output wire halted
);

// VARIABLE DECLARATIONS
    // rx
    wire [7:0] rx_data;
    wire rx_valid;
    
    // Program loader
    wire loader_write_enable;
    wire [7:0] loader_write_address;
    wire [15:0] loader_write_data;
    
    // CPU
    wire cpu_reset;
    assign cpu_reset = reset | ~sw[0];
    wire [15:0] mem_content;
    wire [7:0] reg_content;
    
// FUNCTIONS
    uart_rx rx0(
        .clk(clk),
        .reset(reset),

        .rx(uart_rx),

        .data(rx_data),
        .valid(rx_valid)
    );
    
    program_loader load0(
        .clk(clk),
        .reset(reset),

        .rx_data(rx_data),
        .rx_valid(rx_valid),

        .write_enable(loader_write_enable),
        .write_address(loader_write_address),
        .write_data(loader_write_data)
    );
    
    cpu cpu0(
        .clk(clk),
        .reset(cpu_reset),

        .imem_write_en(loader_write_enable),
        .imem_write_address(loader_write_address),
        .imem_write_data(loader_write_data),
        
        .debug_address(sw[8:1]),
        .debug_data(mem_content),
        
        .debug_reg_address(sw[3:1]),
        .debug_reg_data(reg_content),

        .halted(halted)
    );
    
    assign led = sw[15] ? {8'b0, reg_content} : mem_content;
endmodule
