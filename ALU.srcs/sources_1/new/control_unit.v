`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 01:21:47 AM
// Design Name: 
// Module Name: control_unit
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


module control_unit(
    input wire clk,
    input wire reset,
    
    input wire [3:0] ir_opcode, // ir[15:12]
    input wire [2:0] ir_dr, // ir[11:9]
    input wire [2:0] ir_sr1, // ir[8:6]
    input wire [2:0] ir_sr2, // ir[2:0]
    input wire [2:0] ir_alu_op, // ir[5:3]
    input wire [7:0] ir_imm, // ir[7:0]
    
    output reg pc_enable,
    output reg ir_load,
    
    output reg write_en,
    output reg [2:0] write_select,
    
    output reg [2:0] alu_select,
    output reg [2:0] alu_sr1,
    output reg [2:0] alu_sr2,
    
    output reg mem_write,
    output reg mem_read,
    
    output reg halted
);
    
    localparam FETCH = 2'b00;
    localparam DECODE = 2'b01;
    localparam EXECUTE = 2'b10;
    localparam HALT = 2'b11;
    
    reg [1:0] state;
    
    // decide next state
    always @(posedge clk) begin
        if (reset) begin
            state <= FETCH;
            
            pc_enable <= 0;
            ir_load <= 0;
            
            write_en <= 0;
            write_select <= 0;
            
            alu_select <= 0;
            alu_sr1 <= 0;
            alu_sr2 <= 0;
            
            mem_write <= 0;
            mem_read <= 0;
            
            halted <= 0;
        end
        else begin
            pc_enable <= 0;
            ir_load <= 0;
            
            write_en <= 0;
            mem_write <= 0;
            mem_read <= 0;
            halted <= 0;
            
            case(state)
                FETCH: begin
                    state <= DECODE;
                    
                    pc_enable <= 1;
                    ir_load <= 1;
                end
                
                DECODE: begin
                    state <= EXECUTE;
                    
                    if (ir_opcode == 4'b0011)
                        alu_sr1 <= ir_dr;
                end
                
                EXECUTE: begin
                    if (ir_opcode == 4'b1111)
                        state <= HALT;
                    else
                        state <= FETCH;
                        
                    case (ir_opcode)
                        4'b0000: begin
                            alu_select <= ir_alu_op;
                            alu_sr1 <= ir_sr1;
                            alu_sr2 <= ir_sr2;
                            
                            write_en <= 1;
                            write_select <= ir_dr;
                        end
                        
                        4'b0001: begin
                            write_en <= 1;
                            write_select <= ir_dr;
                        end
                        
                        4'b0010: begin
                            mem_write <= 0;
                            mem_read <= 1;
                            write_select <= ir_dr;
                            write_en <= 1;
                        end
                        
                        4'b0011: begin
                            mem_write <= 1;
                            mem_read <= 0;
                        end
                        
                        default: begin
                            
                        end
                    endcase
                end
                
                HALT: begin
                    state <= HALT;
                    
                    halted <= 1;
                end
                
                default: begin
                    state <= FETCH;
                end
            endcase
        end
    end
    
    // update control signals
//    always @(*) begin
//        if (reset) begin
//            write_en = 0;
//            write_select = 0;
            
//            alu_select = 0;
//            alu_sr1 = 0;
//            alu_sr2 = 0;
            
//            halted = 0;
//        end
//        else begin
//            case(state)
//                FETCH: begin
//                    pc_enable = 1;
//                    ir_load = 1;
//                end
                
//                DECODE: begin
//                    // later
//                end
                
//                EXECUTE: begin
//                    case (ir_opcode)
//                        4'b0000: begin
//                            alu_select = ir_alu_op;
//                            alu_sr1 = ir_sr1;
//                            alu_sr2 = ir_sr2;
                            
//                            write_en = 1;
//                            write_select = ir_dr;
//                        end
                        
//                        4'b0001: begin
//                            write_en = 1;
//                            write_select = ir_dr;
//                        end
                        
//                        4'b0010: begin
//                            // later
//                        end
                        
//                        4'b0011: begin
//                            // later
//                        end
                        
//                        default: begin
                            
//                        end
//                    endcase
//                end
                
//                HALT: begin
//                    halted = 1;
//                end
                
//                default: begin
                
//                end
//            endcase
//        end
//    end
    
//    // change state
//    always @(posedge clk) begin
//        if (reset) state <= FETCH;
//        else state <= next_state;
//    end
endmodule
