`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 12:46:28 AM
// Design Name: 
// Module Name: cpu_datapath
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


module cpu_datapath(
    input wire clk,
    input wire reset,
    
    input wire [15:0] instruction,
    
    input wire [2:0] read_select1,
    input wire [2:0] read_select2,
    
    input wire write_enable,
    input wire [2:0] write_select,
    
    input wire [2:0] alu_select,
    output wire [9:0] alu_result,
    
    input wire [7:0] mem_read_data,
    output wire [7:0] mem_write_data 
);
    reg [7:0] write_data;
    wire [7:0] read_data1, read_data2;
    
    assign mem_write_data = read_data1;
    
    reg_files reg0(
        .clk(clk),
        .reset(reset),
        
        .read_select1(read_select1),
        .read_select2(read_select2),
        .read_data1(read_data1),
        .read_data2(read_data2),
        
        .write_data(write_data),
        .write_enable(write_enable),
        .write_select(write_select)
    );
    
    ALU_func alu0(
        .A(read_data1),
        .B(read_data2),
        .opcode(alu_select),
        .result(alu_result)
    );
    
    always @(*) begin
        case(instruction[15:12])
            4'b0000: write_data = alu_result;
            
            4'b0001: write_data = instruction[7:0];
            
            4'b0010: write_data = mem_read_data;
            
            default: write_data = 8'd0;
        endcase
    end
endmodule
