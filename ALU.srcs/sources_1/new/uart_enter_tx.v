`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 10:42:41 PM
// Design Name: 
// Module Name: uart_enter_tx
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


module uart_enter_tx(
    input wire clk,
    input wire reset,
    
    input wire [7:0] rx_data,
    input wire rx_valid,
    
    input wire tx_busy,
    output reg [7:0] tx_data,
    output reg tx_send
);
    
    // state bits
    localparam IDLE = 1'b0;
    localparam LF   = 1'b1;
    
    // storage
    reg state, next_state;
    
    // decide next state
//    always @(posedge clk) begin
//        if (reset)
//            next_state <= IDLE;
//        else begin
//            case(state)
//                IDLE: begin
//                    if (rx_valid && rx_data == 8'h0D)
//                        next_state <= LF;
//                end
                
//                LF: begin
//                    if (!tx_busy)
//                        next_state <= IDLE;
//                end
                
//                default: next_state <= IDLE;
//            endcase
//        end
//    end
    
//    // update variables
//    always @(posedge clk) begin
//        if (reset) begin
//            tx_data <= 0;
//            tx_send <= 0;
//        end
//        else begin
//            tx_send <= 0;
            
//            case(state)
//                IDLE: begin
//                    if (rx_valid && !tx_busy) begin
//                        if (rx_data == 8'h0D && !nums_ready) begin
//                            // send enter
//                            tx_data <= 8'h0D;
//                            tx_send <= 1;
//                        end
                        
//                        else begin
//                            // send normal character
//                            tx_data <= rx_data;
//                            tx_send <= 1'b1;
//                        end
//                    end
//                end
                
//                LF: begin
//                    if (!tx_busy) begin
//                        //send line feed
//                        tx_data <= 8'h0A;
//                        tx_send <= 1'b1;
//                    end
//                end
//            endcase
//        end
//    end
    
//    // change state
//    always @(posedge clk) begin
//        if (reset) state <= IDLE;
//        else state <= next_state;
//    end

    always @(posedge clk) begin
        if (reset) begin
            tx_data <= 0;
            tx_send <= 0;
        end
    
        else begin
            // tx_send should only be high for one clock
            tx_send <= 0;
    
            if (rx_valid && !tx_busy) begin
    
                // Don't echo Enter.
                // uart_result_tx will handle the newline.
                if (rx_data != 8'h0D) begin
                    tx_data <= rx_data;
                    tx_send <= 1'b1;
                end
    
            end
        end
    end

endmodule
