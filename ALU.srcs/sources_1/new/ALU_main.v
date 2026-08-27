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


module ALU_main(
    input wire clk,
    input wire reset,
    input wire [14:0] sw,
    output wire [3:0] an,
    output wire [6:0] sseg,
    output wire slow_clk
);
    wire [9:0] result, magnitude;
    
    wire [3:0] minus, hundreds, tens, ones;
    
    wire [6:0] in0, in1, in2, in3;
//    wire [6:0] in3 = 7'b1111111;
    
    ALU_func alu0(
        .A(sw[11:6]),
        .B(sw[5:0]),
        .opcode(sw[14:12]),
        .result(result)
    );
    
    assign magnitude = result[9] ? ~result + 1 : result;
    assign minus = result[9] ? 4'hF : 4'hE;
    
    bcd_decoder bcd0(
        .value(magnitude),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );
    
    digit_to_7seg dig0(.digit(minus), .seg(in0));
    digit_to_7seg dig1(.digit(hundreds), .seg(in1));
    digit_to_7seg dig2(.digit(tens), .seg(in2));
    digit_to_7seg dig3(.digit(ones), .seg(in3));
    
    clkdiv c0(.clk(clk), .reset(reset), .clk_out(slow_clk));
    
    time_multiplexer fsm(
        .clk(slow_clk), .reset(reset),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .an(an), .sseg(sseg)
    );
endmodule
