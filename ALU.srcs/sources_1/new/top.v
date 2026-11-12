`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/26/2026 09:12:28 PM
// Design Name: 
// Module Name: top
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


module top(
    input wire clk,
    input wire reset,
    input wire [15:0] sw,
    output wire [15:0] led,
    output wire [3:0] an,
    output wire [6:0] sseg,
    
    input wire uart_rx
);

// VARIABLE DECLARATIONS
    // rx
    wire [7:0] rx_data;
    wire rx_valid;
    
    // Program loader
    wire loader_write_enable;
    wire [7:0] loader_write_address;
    wire [15:0] loader_write_data;
    
    // CPU
    wire cpu_reset;
    assign cpu_reset = reset | ~sw[0];
    wire [15:0] imem_content;
    wire [7:0] dmem_content;
    wire [7:0] reg_content;
    wire halted;
    
    // BCD
    wire [7:0] magnitude;
    wire [3:0] minus, hundreds, tens, ones;
    
    // Digit to 7seg
    wire [6:0] in0, in1, in2, in3;
    
    // Clkdiv
    wire slow_clk;
    
// FUNCTIONS
    uart_rx rx0(
        .clk(clk),
        .reset(reset),

        .rx(uart_rx),

        .data(rx_data),
        .valid(rx_valid)
    );
    
    program_loader load0(
        .clk(clk),
        .reset(reset),

        .rx_data(rx_data),
        .rx_valid(rx_valid),

        .write_enable(loader_write_enable),
        .write_address(loader_write_address),
        .write_data(loader_write_data)
    );
    
// sw[0]: cpu reset
// sw[3:1]: reg select
// sw[11:4]: mem select
// sw[14:12]: nothing
// sw[15]: mem choose
    cpu cpu0(
        .clk(clk),
        .reset(cpu_reset),

        .imem_write_en(loader_write_enable),
        .imem_write_address(loader_write_address),
        .imem_write_data(loader_write_data),
        
        .imem_debug_address(sw[11:4]),
        .imem_debug_data(imem_content),
        
        .dmem_debug_address(sw[11:4]),
        .dmem_debug_data(dmem_content),
        
        .debug_reg_address(sw[3:1]),
        .debug_reg_data(reg_content),

        .halted(halted)
    );
    
    assign magnitude = reg_content[7] ? ~reg_content + 1 : reg_content;
    assign minus = reg_content[7] ? 4'hF : 4'hE;
    
    bcd_decoder bcd0(
        .value({8'b0, magnitude}),
        .hundreds(hundreds),
        .tens(tens),
        .ones(ones)
    );
    
    digit_to_7seg dig0(.digit(minus), .seg(in3));
    digit_to_7seg dig1(.digit(hundreds), .seg(in2));
    digit_to_7seg dig2(.digit(tens), .seg(in1));
    digit_to_7seg dig3(.digit(ones), .seg(in0));
    
    clkdiv c0(.clk(clk), .reset(reset), .clk_out(slow_clk));
    
    time_multiplexer fsm(
        .clk(slow_clk), .reset(reset),
        .in0(in0), .in1(in1), .in2(in2), .in3(in3),
        .an(an), .sseg(sseg)
    );
    
    assign led = sw[15] ? imem_content : {8'b0, dmem_content};
endmodule
