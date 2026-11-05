`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/22/2026 07:33:30 PM
// Design Name: 
// Module Name: cpu
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


module cpu(
    input wire clk,
    input wire reset,
    
    input wire imem_write_en,
    input wire [7:0] imem_write_address,
    input wire [15:0] imem_write_data,
    
    input wire [7:0] debug_address,
    output wire [15:0] debug_data,
    
    input wire [2:0] debug_reg_address,
    output wire [7:0] debug_reg_data,
    
    output wire halted
);

// VARIABLE DECLARATIONS
    // pc
    wire [7:0] pc;
    wire pc_enable;
    
    // inst memory
    wire [15:0] instruction_mem;
    
    // IR
    wire ir_load;
    wire [15:0] instruction;
    
    // control unit
    wire [3:0] ir_opcode;
    wire [2:0] ir_dr;
    wire [2:0] ir_sr1;
    wire [2:0] ir_sr2;
    wire [2:0] ir_alu_op;
    wire [7:0] ir_imm;
    
    wire write_en;
    wire [2:0] write_select;
    
    wire [2:0] alu_select;
    wire [2:0] alu_sr1;
    wire [2:0] alu_sr2;
    
    wire dmem_write_en;
    wire dmem_read_en;
    
    // datapath
    wire [9:0] alu_result;
    
    // data memory
    wire [7:0] dmem_write_data;
    wire [7:0] dmem_read_data;
    
// FUNCTIONS
    pc pc0(
        .clk(clk),
        .reset(reset),
        .enable(pc_enable),
        .address(pc)
    );
    
    instruction_memory imem0(
        .clk(clk),
        .address(pc),
        .instruction(instruction_mem),
    
        .write_enable(imem_write_en),
        .write_address(imem_write_address),
        .write_data(imem_write_data),
        
        .debug_address(debug_address),
        .debug_data(debug_data)
    );
     
    instruction_reg ir0(
        .clk(clk),
        .reset(reset),
        .load(ir_load),
        
        .instruction_in(instruction_mem),
        .instruction(instruction)
    );
    
    assign ir_opcode = instruction[15:12];
    assign ir_dr = instruction[11:9];
    assign ir_sr1 = instruction[8:6];
    assign ir_sr2 = instruction[2:0];
    assign ir_alu_op = instruction[5:3];
    assign ir_imm = instruction[7:0];
    
    control_unit control0(
        .clk(clk),
        .reset(reset),
        
        .ir_opcode(ir_opcode),
        .ir_dr(ir_dr),
        .ir_sr1(ir_sr1),
        .ir_sr2(ir_sr2),
        .ir_alu_op(ir_alu_op),
        .ir_imm(ir_imm),
        
        .pc_enable(pc_enable),
        .ir_load(ir_load),
        
        .write_en(write_en),
        .write_select(write_select),
        
        .alu_select(alu_select),
        .alu_sr1(alu_sr1),
        .alu_sr2(alu_sr2),
        
        .mem_write(dmem_write_en),
        .mem_read(dmem_read_en),
        
        .halted(halted)
    );
    
    cpu_datapath data0(
        .clk(clk),
        .reset(reset),
        
        .instruction(instruction),
        
        .read_select1(alu_sr1),
        .read_select2(alu_sr2),
        
        .write_enable(write_en),
        .write_select(write_select),
        
        .debug_address(debug_reg_address),
        .debug_data(debug_reg_data),
        
        .alu_select(alu_select),
        .alu_result(alu_result),
        
        .mem_read_data(dmem_read_data),
        .mem_write_data(dmem_write_data)
    );
    
    data_memory dmem0(
        .clk(clk),
        .reset(reset),
        
        .address(ir_imm),
        
        .write_enable(dmem_write_en),
        .write_data(dmem_write_data),
        
        .read_data(dmem_read_data)
    );
endmodule
