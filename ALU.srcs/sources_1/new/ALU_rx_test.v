`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 12:27:49 PM
// Design Name: 
// Module Name: uart_test
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


module ALU_rx_test(
    input wire clk,
    input wire reset,
    input wire RsRx,
    output wire RsTx,
    output wire [3:0] an,
    output wire [6:0] sseg
);

    // Not transmitting anything yet -- idle-high keeps the line quiet.
    assign RsTx = 1'b1;
 
    wire [7:0] rx_data;
    wire rx_valid;
//    reg  [7:0] rx_latched;
    
    wire [7:0] num1;
    wire [7:0] num2;
    wire [2:0] oper;
    wire nums_ready, entry_in_progress;
    
    wire [9:0] result, magnitude;
 
    wire [3:0] minus, hundreds, tens, ones;
    wire [6:0] in0, in1, in2, in3;
    wire slow_clk;
 
    uart_rx urx(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),
        .data(rx_data),
        .valid(rx_valid)
    );
 
    // data/valid only hold the received byte for ~1 baud tick before
    // uart_rx's IDLE state clears them back to 0, so latch it here and
    // hold until the next byte arrives -- otherwise the display would
    // flicker back to "000" almost immediately after each character.
//    always @(posedge clk) begin
//        if (reset)
//            rx_latched <= 8'h00;
//        else if (rx_valid)
//            rx_latched <= rx_data;
//    end
    
    command_parser cmd0(
        .clk(clk),
        .reset(reset),
        .data(rx_data),
        .valid(rx_valid),
        .num1(num1),
        .num2(num2),
        .oper(oper),
        .nums_ready(nums_ready),
        .entry_in_progress(entry_in_progress)
    );
    
    ALU_func alu0(
        .A(num1),
        .B(num2),
        .opcode(oper),
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
    
    wire [3:0] display_sign     = entry_in_progress ? 4'hE : minus;
    wire [3:0] display_hundreds = entry_in_progress ? 4'hE : hundreds;
    wire [3:0] display_tens     = entry_in_progress ? 4'hE : tens;
    wire [3:0] display_ones     = entry_in_progress ? 4'hE : ones;
 
    // AN0 = rightmost physical digit -> ones. AN3 = leftmost -> blank.
    digit_to_7seg dig0(.digit(display_sign), .seg(in0));
    digit_to_7seg dig1(.digit(display_hundreds), .seg(in1));
    digit_to_7seg dig2(.digit(display_tens), .seg(in2));
    digit_to_7seg dig3(.digit(display_ones), .seg(in3));
 
    clkdiv c0(.clk(clk), .reset(reset), .clk_out(slow_clk));
 
    time_multiplexer fsm(
        .clk(slow_clk), .reset(reset),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .an(an), .sseg(sseg)
    );
    
endmodule