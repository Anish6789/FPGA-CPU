`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 05:55:37 PM
// Design Name: 
// Module Name: pc
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


module pc(
    input wire clk,
    input wire reset,
    input wire enable,
    output reg [7:0] address
);
 
    always @(posedge clk) begin
        if (reset)
            address <= 8'd0;
        else if (enable)
            address <= address + 8'd1;
    end
endmodule
