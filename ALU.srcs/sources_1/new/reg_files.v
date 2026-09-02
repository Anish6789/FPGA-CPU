`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 04:49:10 PM
// Design Name: 
// Module Name: reg_files
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


module reg_files(
    input wire clk,
    input wire reset,
    
    input wire [2:0] read_select1,
    input wire [2:0] read_select2,
    output wire [7:0] read_data1,
    output wire [7:0] read_data2,
    
    input wire [7:0] write_data,
    input wire write_enable,
    input wire [2:0] write_select
);

    reg [7:0] registers[0:7];

//    assign R0 = registers[0];
//    assign R1 = registers[1];
//    assign R2 = registers[2];
//    assign R3 = registers[3];
//    assign R4 = registers[4];
//    assign R5 = registers[5];
//    assign R6 = registers[6];
//    assign R7 = registers[7];

    integer i;
    
    assign read_data1 = registers[read_select1];
    assign read_data2 = registers[read_select2];
    
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                registers[i] <= 8'd0;
        end

        else if (write_enable) begin
            registers[write_select] <= write_data;
        end
    end 
endmodule
