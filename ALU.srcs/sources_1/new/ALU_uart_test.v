`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 12:40:15 PM
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


module ALU_uart_test(
    input wire clk,
    input wire reset,
    input wire RsRx,
    output wire RsTx,
    output wire [3:0] an,
    output wire [6:0] sseg
);

    wire [7:0] rx_data;
    wire rx_valid;
//    reg  [7:0] rx_latched;

    wire [7:0] enter_tx_data;
    wire enter_tx_send;
    
    wire [7:0] tx_data;
    wire tx_send;
    wire tx_busy;
    wire tx_done;
  
    wire [7:0] num1;
    wire [7:0] num2;
    wire [2:0] oper;
    wire nums_ready, entry_in_progress;
    
    wire [9:0] result, magnitude;
 
    wire [3:0] minus, hundreds, tens, ones;
    
    wire [7:0] result_tx_data;
    wire result_tx_send;
    wire result_tx_busy;

    wire [6:0] in0, in1, in2, in3;
    
    wire slow_clk;

    // recieve characters from console on PC
    uart_rx urx0(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),
        .data(rx_data),
        .valid(rx_valid)
    );
 
    uart_enter_tx uetx0(
        .clk(clk),
        .reset(reset),
        .rx_data(rx_data),
        .rx_valid(rx_valid),
        .tx_busy(tx_busy),
        .tx_data(enter_tx_data),
        .tx_send(enter_tx_send)
    );

    uart_tx utx0(
        .clk(clk),
        .reset(reset),
        .data(tx_data),
        .send(tx_send),
        .tx(RsTx),
        .tx_busy(tx_busy),
        .done(tx_done)
    );
    
    // parse the expression typed by user on console on PC
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
    
    // perform arithmetic operation specified by user
    ALU_func alu0(
        .A(num1),
        .B(num2),
        .opcode(oper),
        .result(result)
    );
    
    assign magnitude = result[9] ? ~result + 1 : result;
    assign minus = result[9] ? 4'hF : 4'hE;
    
    // convert from binary result to decimal
    bcd_decoder bcd0(
        .value(magnitude),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );
    
    uart_result_tx urtx0(
        .clk(clk),
        .reset(reset),
        .start(nums_ready),
        .minus(minus),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        .tx_data(result_tx_data),
        .tx_send(result_tx_send),
        .busy(result_tx_busy)
    );
  
    assign tx_data = result_tx_busy ? result_tx_data : enter_tx_data;
    assign tx_send = result_tx_busy ? result_tx_send : enter_tx_send;
    
    wire [3:0] display_sign = entry_in_progress ? 4'hE : minus;
    wire [3:0] display_hundreds = entry_in_progress ? 4'hE : hundreds;
    wire [3:0] display_tens = entry_in_progress ? 4'hE : tens;
    wire [3:0] display_ones = entry_in_progress ? 4'hE : ones;
 
    
    
    // display decimal result on seven segments using time multiplexing
    digit_to_7seg dig0(.digit(display_sign), .seg(in0));
    digit_to_7seg dig1(.digit(display_hundreds), .seg(in1));
    digit_to_7seg dig2(.digit(display_tens), .seg(in2));
    digit_to_7seg dig3(.digit(display_ones), .seg(in3));
 
    clkdiv c0(.clk(clk), .reset(reset), .clk_out(slow_clk));
 
    time_multiplexer fsm0(
        .clk(slow_clk), .reset(reset),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .an(an), .sseg(sseg)
    );    
endmodule