`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2026 12:57:24 AM
// Design Name: 
// Module Name: uart_result_tx
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


module uart_result_tx(
    input wire clk,
    input wire reset,
    
    input wire start,
    
    input wire [3:0] minus,
    input wire [3:0] hundreds,
    input wire [3:0] tens,
    input wire [3:0] ones,
    
    input wire tx_busy,
    input wire tx_done,
    output reg [7:0] tx_data,
    output reg tx_send,
    output reg busy
);

    localparam IDLE = 3'b000;
    localparam CR = 3'b001;
    localparam LF = 3'b010;
    localparam MINUS = 3'b011;
    localparam HUNDREDS = 3'b100;
    localparam TENS = 3'b101;
    localparam ONES = 3'b110;
    
    reg [2:0] state, next_state;
    reg flag;
    
    // decide next state
    always @(posedge clk) begin
        if(reset)
            next_state <= IDLE;
            
        else begin
            case(state)
                IDLE: begin
                    if(start)
                        next_state <= CR;
                end
                
                CR: begin
                    if(tx_done)
                        next_state <= LF;
                end
                
                LF: begin
                    if(tx_done) begin
                        if (flag) next_state <= IDLE;
                        else if (minus == 4'hF) next_state <= MINUS;
                        else if (hundreds != 0) next_state <= HUNDREDS;
                        else if (~(tens == 0 && hundreds == 0)) next_state <= TENS;
                        else next_state <= ONES;
                    end
                end
                
                MINUS: begin
                    if(tx_done) begin
                        if (hundreds != 0) next_state <= HUNDREDS;
                        else if (~(tens == 0 && hundreds == 0)) next_state <= TENS;
                        else next_state <= ONES;
                    end
                end
                
                HUNDREDS: begin
                    if(tx_done)
                        next_state <= TENS;
                end
                
                TENS: begin
                    if(tx_done)
                        next_state <= ONES;
                end
                
                ONES: begin
                    if(tx_done)
                        next_state <= CR;
                end
                
                default: next_state <= IDLE;
            endcase
        end
    end
    
    // update variables
    always @(posedge clk) begin
        if(reset) begin
            tx_data <= 0;
            tx_send <= 0;
            busy <= 0;
            flag <= 0;
        end
            
        else begin
            tx_send <= 0;
            
            case(state)
                IDLE: begin
                    busy <= 0;
                    flag <= 0;
                    
                    if(start)
                        busy <= 1;
                end
                
                CR: begin
                    busy <= 1;
                     
                    if(!tx_busy) begin
                        tx_data <= 8'h0D;
                        tx_send <= 1;
                    end
                end
                
                LF: begin
                    busy <= 1;
                     
                    if(!tx_busy) begin
                        tx_data <= 8'h0A;
                        tx_send <= 1;
                    end
                end
                
                MINUS: begin
                    busy <= 1;
                     
                    if(!tx_busy) begin
                        tx_data <= "-";
                        tx_send <= 1;
                    end
                end
                
                HUNDREDS: begin
                    busy <= 1;
                    
                    if(!tx_busy) begin
                        tx_data <= "0" + hundreds;
                        tx_send <= 1;
                    end
                end
                
                TENS: begin
                    busy <= 1;
                     
                    if(!tx_busy) begin
                        tx_data <= "0" + tens;
                        tx_send <= 1;
                    end
                end
                
                ONES: begin
                    busy <= 1;
                     
                    if(!tx_busy) begin
                        tx_data <= "0" + ones;
                        tx_send <= 1;
                        flag <= 1;
                    end
                end
                
                default: busy <= 0;
            endcase
        end
    end
    
    // change state
    always @(posedge clk) begin
        if (reset) state <= IDLE;
        else state <= next_state;
    end
endmodule
