`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2026 02:29:39 PM
// Design Name: 
// Module Name: flags_reg
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


module flags_reg(
    input wire clk,
    input wire reset,
    input wire write_enable,
    input wire [7:0] result,
    
    output reg pos,
    output reg zero,
    output reg neg
);
    
    always @(posedge clk) begin
        if (reset) begin
            pos <= 0;
            zero <= 1;
            neg <= 0;
        end
        else if (write_enable) begin
            pos <= ~result[7] & (result != 8'd0);
            zero <= (result == 8'd0);
            neg <= result[7];
        end
    end
endmodule
