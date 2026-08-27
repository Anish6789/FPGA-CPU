`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 12:19:36 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [7:0] data,
    output reg valid
);

    localparam integer BAUD_RATE = 115200;
    localparam integer OVERSAMPLE = 16;
    
    // 100,000,000 / (115200*16) ≈ 54 clock cycles per UART bit
    localparam integer TICKS_PER_BIT = 54;
    
    // state bits
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;
    
    // storage
    reg [1:0] state, next_state;
    reg [5:0] baud_count;
    reg [3:0] sample_count;
    reg [2:0] bit_count;
    reg [7:0] rx_temp;
    
    // Synchronize the RX signal to  FPGA clock
    reg rx1;
    reg rx2;
    
    always @(posedge clk) begin
        if (reset) begin
            rx1 <= 1'b1;
            rx2 <= 1'b1;
        end
        else begin
            rx1 <= rx;
            rx2 <= rx1;
        end
    end
    
    // decide next state
    always @(posedge clk) begin
        if (reset) next_state <= IDLE;
        
        else if (baud_count == TICKS_PER_BIT - 1) begin
            case (state)
                IDLE: begin
                    if (!rx2)
                        next_state <= START;
                end
                
                START: begin
                    if (sample_count == 4'd7) begin
                        if (!rx2)
                            next_state <= DATA;
                        else
                            next_state <= IDLE;
                    end
                end
                
                DATA: begin
                    if (sample_count == 4'd15) begin
                        if(bit_count == 3'd7)
                            next_state <= STOP;
                    end
                end
                
                STOP: begin
                    if (sample_count == 4'd15)
                        next_state <= IDLE;
                end
                default: next_state <= IDLE;
            endcase
        end
    end

    // update variables
    always @(posedge clk) begin
        if (baud_count == TICKS_PER_BIT - 1) begin
            baud_count <= 0;
            
            case (state)
                IDLE: begin
                    sample_count <= 0;
                    bit_count <= 0;
                    baud_count  <= 0;
                    rx_temp   <= 0;
                    data        <= 0;
                    valid       <= 0;
                end
                START: begin
                    if (sample_count == 4'd7)
                        sample_count <= 0;
                    else
                        sample_count <= sample_count + 1;
                end
                DATA: begin
                    if (sample_count == 4'd15) begin
                        sample_count <= 0;
                        rx_temp[bit_count] <= rx2;                                                                                                                                                                                 
                        if (bit_count != 3'd7)
                            bit_count <= bit_count + 1;
                    end
                    else
                        sample_count <= sample_count + 1;
                end
                STOP: begin
                    if (sample_count == 4'd15) begin
                        sample_count <= 0;
                        
                        data <= rx_temp;
                        valid <= 1'b1;
                    end
                    else
                        sample_count <= sample_count + 1;
                end
            endcase
        end
        else
            baud_count <= baud_count + 1;
    end
    
    // change state
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end 
endmodule
