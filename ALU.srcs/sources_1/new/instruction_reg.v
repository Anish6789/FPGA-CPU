`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 01:15:40 AM
// Design Name: 
// Module Name: instruction_reg
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


module instruction_reg(
    input wire clk,
    input wire reset,
    input wire load,

    input wire [15:0] instruction_in,
    output reg [15:0] instruction
);

    always @(posedge clk) begin
        if (reset)
            instruction <= 16'd0;

        else if (load)
            instruction <= instruction_in;
    end
endmodule
