`timescale 1ns / 1ps

module clkdiv(
    input wire clk,
    input wire reset,
    output wire clk_out
);
    reg [15:0] COUNT;
    
    assign clk_out = COUNT[15];
    
    always @(posedge clk) begin
        if (reset) COUNT <= 0;
        else COUNT <= COUNT + 1;
    end
endmodule