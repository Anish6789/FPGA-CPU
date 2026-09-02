`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 12:37:34 AM
// Design Name: 
// Module Name: reg_files_tb
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


`timescale 1ns / 1ps

module reg_files_tb;

    reg clk;
    reg reset;

    reg [2:0] read_select1;
    reg [2:0] read_select2;
    wire [7:0] read_data1;
    wire [7:0] read_data2;

    reg [7:0] write_data;
    reg write_enable;
    reg [2:0] write_select;


    // Instantiate register file
    reg_files uut (
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


    // 100 MHz clock
    always #5 clk = ~clk;


    initial begin

        // Initial values
        clk = 0;
        reset = 1;

        read_select1 = 0;
        read_select2 = 0;

        write_data = 0;
        write_enable = 0;
        write_select = 0;


        // -------------------------
        // RESET
        // -------------------------

        #10;
        reset = 0;


        // -------------------------
        // WRITE 10 TO R0
        // -------------------------

        write_data = 8'd10;
        write_select = 3'd0;
        write_enable = 1;

        #10;

        write_enable = 0;


        // -------------------------
        // WRITE 3 TO R1
        // -------------------------

        write_data = 8'd3;
        write_select = 3'd1;
        write_enable = 1;

        #10;

        write_enable = 0;


        // -------------------------
        // READ R0 AND R1
        // -------------------------

        read_select1 = 3'd0;
        read_select2 = 3'd1;

        #10;

        $display("R0 = %d", read_data1);
        $display("R1 = %d", read_data2);


        // -------------------------
        // WRITE 13 TO R2
        // -------------------------

        write_data = 8'd13;
        write_select = 3'd2;
        write_enable = 1;

        #10;

        write_enable = 0;


        // -------------------------
        // READ R2
        // -------------------------

        read_select1 = 3'd2;

        #10;

        $display("R2 = %d", read_data1);


        // -------------------------
        // READ R0 AND R1 AGAIN
        // -------------------------

        read_select1 = 3'd0;
        read_select2 = 3'd1;

        #10;

        $display("R0 = %d", read_data1);
        $display("R1 = %d", read_data2);


        // -------------------------
        // FINISH
        // -------------------------

        #10;
        $finish;

    end

endmodule
