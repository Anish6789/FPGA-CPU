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
// LOAD(mem): [0010][DR] 0 [8-bit address]
// STORE: [0011][SR] 0 [8-bit address]
//     all register addresses are 3 bits
//     ALU opcodes: 000=ADD 001=SUB 010=MUL 011=DIV 100=MOD
//
// The example program below is just a starting placeholder:
//   0: LOAD R0 = 10        -> 0001 000 0 0000 1010 = 16'h100A
//   1: LOAD R1 = 3         -> 0001 001 0 0000 0011 = 16'h1203
//   2: ADD, dest = R2      -> R2 <= R0 + R1 = 13     -> 0000 010 000 000 001 = 16'h0401
//   3: SUB, dest = R3      -> R3 <= R0 - R1 = 13 - 3 = 10 -> 0000 011 000 001 001 = 16'h0209
//   4: HALT                -> 1111 0000 0000 0000 = 16'hF000
//////////////////////////////////////////////////////////////////////////////////
 
module instruction_memory(
    input wire clk,
    
    input  wire [7:0] address,
    
    input wire write_enable,
    input wire [7:0] write_data,
    input wire [7:0] write_address,
    
    output wire [15:0] instruction
);
 
    reg [15:0] mem[0:255];
    integer i;
 
    initial begin
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 16'h0000;
            
//        mem[0] = 16'h1019; // LOAD R0 = 10
//        mem[1] = 16'h3014; // LOAD R1 = 3
//        mem[2] = 16'h2214; // R0 = R0 + R1
//        mem[3] = 16'h0609; // R1 = R0 - R1
//        mem[3] = 16'hF000; // HALT
    end
 
    assign instruction = mem[address];
    
    always @(posedge clk) begin
        if (write_enable) begin
            mem[write_address] <= write_data;
        end
    end
endmodule