`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 12:12:29 AM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input wire clk,
    input wire reset,
    input wire [7:0] data,
    input wire send,
    output reg tx,
    output reg tx_busy,
    output reg done
);

    // 100,000,000 / 115200* ≈ 868 clock cycles per UART bit
    localparam integer TICKS_PER_BIT = 868;
    
    // state bits
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    // storage
    reg [1:0] state, next_state;
    reg [9:0] baud_count;
    reg [2:0] bit_count;
    reg [7:0] tx_data;
    
    // decide next state
    always @(posedge clk) begin
        if (reset) next_state <= IDLE;
        
        else begin
            case (state)
                IDLE: begin
                    if (send)
                        next_state <= START;
                end
                
                START: begin
                    if (baud_count == TICKS_PER_BIT - 1)
                        next_state <= DATA;
                end
                
                DATA: begin
                    if (baud_count == TICKS_PER_BIT - 1) begin
                        if (bit_count == 3'd7)
                            next_state <= STOP;
                    end
                end
                
                STOP: begin
                    if (baud_count == TICKS_PER_BIT - 1)
                        next_state <= IDLE;
                end
                
                default: next_state <= IDLE;
            endcase
        end
    end

    // update variables
    always @(posedge clk) begin
        if (reset) begin
            tx_busy    <= 1'b0;
            tx_data <= 0;
            tx <= 1'b1;
            done <= 1'b0;
        end
        
        else begin
            done <= 0;
            case (state)
                IDLE: begin
                    bit_count <= 0;
                    baud_count <= 0;
                    tx_data <= 0;
                    tx <= 1'b1;
                    tx_busy <= 1'b0;
                    
                    if (send) begin
                        tx_data <= data;
                        tx_busy <= 1'b1;
                    end
                end
                START: begin
                    tx <= 1'b0;
                    tx_busy <= 1'b1;
                    
                    if (baud_count == TICKS_PER_BIT - 1)
                        baud_count <= 0;
                    else
                        baud_count <= baud_count + 1;
                end
                DATA: begin
                    tx <= tx_data[bit_count];
                    tx_busy <= 1'b1;
                    
                    if (baud_count == TICKS_PER_BIT - 1) begin
                        baud_count <= 0;                                                                                                                                                                                
                        if (bit_count != 3'd7)
                            bit_count <= bit_count + 1;
                    end
                    else
                        baud_count <= baud_count + 1;
                end
                STOP: begin
                    tx <= 1'b1;
                    tx_busy <= 1'b1;
                    
                    if (baud_count == TICKS_PER_BIT - 1) begin
                        baud_count <= 0;
                        done <= 1;
                    end
                    else begin
                        baud_count <= baud_count + 1;
                        done <= 0;
                    end
                end
            endcase
        end
    end
    
    // change state
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end
endmodule
