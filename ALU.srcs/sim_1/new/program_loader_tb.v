`timescale 1ns / 1ps

module program_loader_tb;

    reg clk;
    reg reset;

    reg [7:0] rx_data;
    reg rx_valid;

    wire write_enable;
    wire [7:0] write_address;
    wire [15:0] write_data;


    program_loader uut (
        .clk(clk),
        .reset(reset),

        .rx_valid(rx_valid),
        .rx_data(rx_data),

        .write_enable(write_enable),
        .write_address(write_address),
        .write_data(write_data)
    );


    always #5 clk = ~clk;


    initial begin

        clk = 0;
        reset = 1;

        rx_data = 0;
        rx_valid = 0;

        #20;

        reset = 0;


        // Send 16'h1019

        #10;
        rx_data = 8'h10;
        rx_valid = 1;

        #10;
        rx_valid = 0;

        #10;
        rx_data = 8'h19;
        rx_valid = 1;

        #10;
        rx_valid = 0;


        // Send 16'h120A

        #10;
        rx_data = 8'h12;
        rx_valid = 1;

        #10;
        rx_valid = 0;

        #10;
        rx_data = 8'h0A;
        rx_valid = 1;

        #10;
        rx_valid = 0;


        // Send HALT = F000

        #10;
        rx_data = 8'hF0;
        rx_valid = 1;

        #10;
        rx_valid = 0;

        #10;
        rx_data = 8'h00;
        rx_valid = 1;

        #10;
        rx_valid = 0;


        #20;

        $finish;

    end


    always @(posedge clk) begin

        if (write_enable) begin

            $display(
                "WRITE: address=%d data=%h",
                write_address,
                write_data
            );

        end

    end

endmodule