`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/16/2026 02:06:21 PM
// Design Name: 
// Module Name: ALU_main
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


module ALU_func(
    input wire [7:0] A,
    input wire [7:0] B,
    input wire [2:0] opcode,
    output reg [9:0] result
);

    always @(*) begin
        case (opcode)
            3'b000: result = A + B;
            3'b001: result = A - B;
            3'b010: result = A * B;
            3'b011 : result = A / B;
            3'b100: result = A % B;
            default: result = 8'd0;
        endcase
    end
endmodule
