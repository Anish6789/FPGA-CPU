// Converts the ALU result into three decimal digits.

`timescale 1ns / 1ps
module bcd_decoder (
    input  wire [15:0] value,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
);
    always @(*) begin
        hundreds = value / 10'd100;
        tens = (value % 10'd100) / 10'd10;
        ones = value % 10'd10;
    end
endmodule
