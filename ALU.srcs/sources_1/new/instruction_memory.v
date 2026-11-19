`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// instruction_memory
//
// A small ROM holding the program, one 8-bit instruction per address. Reads
// are combinational (no clock needed) -- give it an address, it hands back
// the instruction stored there right away, since it's read-only.
//
// Instruction encoding (matches reg_files/ALU_func):
// ALU:  [0000][DR][SR1][ALU opcode (3 bits)][SR2]
// LOAD(imm): [0001][DR] 0 [8-bit immediate]
// LOAD(mem\): [0010][DR] 0 [8-bit address]
// STORE: [0011][SR] 0 [8-bit address]
// BRANCH: [0100] [nzp] 0 [8-bit address]
// HALT: [1111] 0000 0000 0000
//     all register addresses are 3 bits
//     ALU opcodes: 000=ADD 001=SUB 010=MUL 011=DIV 100=MOD
//////////////////////////////////////////////////////////////////////////////////
 
module instruction_memory(
    input wire clk,
    
    input  wire [7:0] address,
    output wire [15:0] instruction,
    
    input wire write_enable,
    input wire [15:0] write_data,
    input wire [7:0] write_address,
    
    input wire [7:0] debug_address,
    output wire [15:0] debug_data
);
 
    reg [15:0] mem[0:255];
 
    assign instruction = mem[address];
    assign debug_data = mem[debug_address];
    
    always @(posedge clk) begin
        if (write_enable) begin
            mem[write_address] <= write_data;
        end
    end
endmodule