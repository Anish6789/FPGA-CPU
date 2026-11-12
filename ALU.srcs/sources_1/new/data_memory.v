`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2026 11:20:46 AM
// Design Name: 
// Module Name: data_memory
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


module data_memory(
    input wire clk,
    input wire reset,
    
    input wire [7:0] address,
    
    input wire write_enable,
    input wire [7:0] write_data,
    
    output wire [7:0] read_data,
    
    input wire [7:0] debug_address,
    output wire [15:0] debug_data
);

    reg [7:0] memory[0:255];
    integer i;
    
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;
    end
    
    assign read_data = memory[address];
    assign debug_data = memory[debug_address];
    
    always @(posedge clk) begin
        if (write_enable)
            memory[address] <= write_data;
    end
endmodule
