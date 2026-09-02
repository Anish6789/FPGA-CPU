`timescale 1ns / 1ps

module cpu_tb;

    reg clk;
    reg reset;

    wire halted;

    // CPU
    cpu uut (
        .clk(clk),
        .reset(reset),
        .halted(halted)
    );

    // 100 MHz clock
    always #5 clk = ~clk;

    
//    always @(posedge clk) begin
//        $display(
//            "PC=%d  IR=%h  R0=%d  R1=%d",
//            uut.pc,
//            uut.instruction,
//            uut.data0.reg0.registers[0],
//            uut.data0.reg0.registers[1]
//        );
        
//        $display(
//            "state=%b opcode=%b write_en=%b write_select=%d write_data=%d",
//            uut.control0.state,
//            uut.ir_opcode,
//            uut.write_en,
//            uut.write_select,
//            uut.data0.write_data
//        );
//    end
        
    initial begin

        clk = 0;
        reset = 1;

        // Reset CPU
        #20;
        reset = 0;

        // Let the CPU execute
        #500;
        
//        $display("INSTR 0 = %h", uut.imem0.mem[0]);
//        $display(
//            "state=%b opcode=%b write_en=%b write_select=%d write_data=%d",
//            uut.control0.state,
//            uut.ir_opcode,
//            uut.write_en,
//            uut.write_select,
//            uut.data0.write_data
//        );
//        $display("INSTR 1 = %h", uut.imem0.mem[1]);
//        $display("INSTR 2 = %h", uut.imem0.mem[2]);
//        $display("INSTR 3 = %h", uut.imem0.mem[3]);
        
//        $display("PC = %d, IR = %h", uut.pc, uut.instruction);

        $display("--------------------------------");
        $display("LOAD / STORE TEST");
        $display("--------------------------------");

        $display("R0 = %d", uut.data0.reg0.registers[0]);
        $display("R1 = %d", uut.data0.reg0.registers[1]);
        $display("MEM[20] = %d", uut.dmem0.memory[20]);
        $display("HALTED = %b", halted);


        // Check R0
        if (uut.data0.reg0.registers[0] == 8'd25)
            $display("R0 PASS");
        else
            $display("R0 FAIL");


        // Check memory
        if (uut.dmem0.memory[20] == 8'd25)
            $display("MEMORY PASS");
        else
            $display("MEMORY FAIL");


        // Check R1
        if (uut.data0.reg0.registers[1] == 8'd25)
            $display("R1 PASS");
        else
            $display("R1 FAIL");


        // Check HALT
        if (halted == 1'b1)
            $display("HALT PASS");
        else
            $display("HALT FAIL");


        $display("--------------------------------");

        $finish;

    end

endmodule