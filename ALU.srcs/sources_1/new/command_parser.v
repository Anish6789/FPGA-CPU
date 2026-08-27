`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 11:18:12 PM
// Design Name: 
// Module Name: command_parser
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


module command_parser(
    input wire clk,
    input wire reset,
    input wire [7:0] data,
    input wire valid,
    output reg [7:0] num1,
    output reg [7:0] num2,
    output reg [2:0] oper,
    output reg nums_ready,
    output reg entry_in_progress
);

    localparam FIRST_NUMBER = 1'b0;
    localparam SECOND_NUMBER = 1'b1;
    
    reg state, next_state;
    reg [7:0] curr_num;
    
    reg valid_prev;
    wire new_byte = valid && !valid_prev;
    
    always @(posedge clk) begin
        if (reset)
            valid_prev <= 1'b0;
        else
            valid_prev <= valid;
    end
    
    // determine next state
    always @(posedge clk) begin
        if (reset) next_state <= FIRST_NUMBER;
        
        else begin
            case(state)
                FIRST_NUMBER: begin
                    if (new_byte && (data == 8'h0D || data == "+" || data == "-" || data == "*" || data == "/" || data == "%"))
                        next_state <= SECOND_NUMBER;
                end
                
                SECOND_NUMBER: begin
                    if (new_byte && data == 8'h0D)
                        next_state <= FIRST_NUMBER;
                end
                
                default: next_state <= FIRST_NUMBER;
            endcase
        end
    end
    
    // update variables
    always @(posedge clk) begin
        if (reset) begin
            curr_num <= 0;
            num1 <= 0;
            num2 <= 0;
            nums_ready <= 0;
        end
        
        else begin
            nums_ready <= 1'b0;
            
            if (new_byte) begin
                case(state)
                    FIRST_NUMBER: begin
                        nums_ready <= 1'b0;
                        
                        if (data >= "0" && data <= "9")
                            curr_num <= (curr_num * 10) + (data - "0");
                            
                        else if (data == 8'h0D) begin
                            num1 <= curr_num;
                            curr_num <= 0;
                        end
                        
                        else if (data == "+" || data == "-" || data == "*" || data == "/" || data == "%") begin
                            num1 <= curr_num;
                            curr_num <= 0;
                            
                            case(data)
                                "+": oper <= 3'b000;
                                "-": oper <= 3'b001;
                                "*": oper <= 3'b010;
                                "/": oper <= 3'b011;
                                "%": oper <= 3'b100;
                                
                                default: oper <= 3'b000;
                            endcase
                        end
                    end
                    
                    SECOND_NUMBER: begin
                        if (data >= "0" && data <= "9")
                            curr_num <= (curr_num * 10) + (data - "0");
                        else if (new_byte && data == 8'h0D) begin
                            num2 <= curr_num;
                            curr_num <= 0;
                            nums_ready <= 1'b1;
                        end
                    end
                endcase
            end
        end
    end
    
    // change state
    always @(posedge clk) begin
        if (reset) state <= FIRST_NUMBER;
        else state <= next_state;
    end
    
    // set flags
    always @(posedge clk) begin
        if (reset)
            entry_in_progress <= 1'b0;
        else if (nums_ready)
            entry_in_progress <= 1'b0;
        else if (new_byte)
            entry_in_progress <= 1'b1;
    end
endmodule
