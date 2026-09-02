`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for ALU_main (top level)
//
// Assumes clkdiv has been updated to:
//     reg [1:0] COUNT;
//     assign clk_out = COUNT[1];
// i.e. a divide-by-4 clock (clk_out rises every 4 input clk cycles). This is
// fast enough to simulate directly in real time, so unlike the old 2^27
// divider, no force/release fast-forwarding of COUNT is needed anymore.
//
// Part 1: drives every ALU opcode through `sw` and checks the full pipeline
//         (ALU_func -> bcd_decoder -> digit_to_7seg) via hierarchical
//         references into the DUT.
// Part 2: waits on real edges of dut.slow_clk and checks that the
//         time_multiplexer cycles an/sseg through all 4 digit slots in the
//         correct order.
//////////////////////////////////////////////////////////////////////////////////

module ALU_main_tb;

    reg         clk;
    reg         reset;
    reg  [14:0] sw;
    wire [3:0]  an;
    wire [6:0]  sseg;
    wire        slow_clk;

    integer errors = 0;
    integer checks = 0;
    integer i;

    reg [7:0] exp_result;
    reg [3:0] exp_hundreds, exp_tens, exp_ones;
    reg [6:0] exp_seg0, exp_seg1, exp_seg2;

    ALU_main dut (
        .clk(clk),
        .reset(reset),
        .sw(sw),
        .an(an),
        .sseg(sseg),
        .slow_clk(slow_clk)
    );

    // 100 MHz system clock
    initial clk = 0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------------
    // Reference models (independent of the DUT's internal implementation)
    // ---------------------------------------------------------------------
    function [7:0] alu_ref;
        input [5:0] a_in;
        input [5:0] b_in;
        input [2:0] op_in;
        begin
            case (op_in)
                3'b000: alu_ref = a_in + b_in;
                3'b001: alu_ref = a_in - b_in;
                3'b010: alu_ref = a_in & b_in;
                3'b011: alu_ref = a_in | b_in;
                3'b100: alu_ref = a_in ^ b_in;
                default: alu_ref = 8'd0;
            endcase
        end
    endfunction

    function [6:0] seg_ref;
        input [3:0] digit;
        begin
            case (digit)
                4'h0: seg_ref = 7'b0000001;
                4'h1: seg_ref = 7'b1001111;
                4'h2: seg_ref = 7'b0010010;
                4'h3: seg_ref = 7'b0000110;
                4'h4: seg_ref = 7'b1001100;
                4'h5: seg_ref = 7'b0100100;
                4'h6: seg_ref = 7'b0100000;
                4'h7: seg_ref = 7'b0001111;
                4'h8: seg_ref = 7'b0000000;
                4'h9: seg_ref = 7'b0000100;
                default: seg_ref = 7'b1111111;
            endcase
        end
    endfunction

    // ---------------------------------------------------------------------
    // Part 1: full-pipeline check (sw -> ALU -> BCD -> 7-seg patterns)
    // ---------------------------------------------------------------------
    task run_case;
        input [5:0] a_in;
        input [5:0] b_in;
        input [2:0] op_in;
        input [8*20:1] label;
        begin
            sw = {op_in, a_in, b_in};
            #10; // let the combinational pipeline settle

            exp_result   = alu_ref(a_in, b_in, op_in);
            exp_hundreds = exp_result / 100;
            exp_tens     = (exp_result % 100) / 10;
            exp_ones     = exp_result % 10;
            exp_seg0     = seg_ref(exp_hundreds);
            exp_seg1     = seg_ref(exp_tens);
            exp_seg2     = seg_ref(exp_ones);

            checks = checks + 1;

            if (dut.result   !== exp_result   ||
                dut.hundreds !== exp_hundreds ||
                dut.tens     !== exp_tens     ||
                dut.ones     !== exp_ones     ||
                dut.in0      !== exp_seg0     ||
                dut.in1      !== exp_seg1     ||
                dut.in2      !== exp_seg2) begin
                errors = errors + 1;
                $display("FAIL [%0s] opcode=%b A=%0d B=%0d", label, op_in, a_in, b_in);
                $display("      result: got=%0d expected=%0d", dut.result, exp_result);
                $display("      digits: got=%0d%0d%0d expected=%0d%0d%0d",
                          dut.hundreds, dut.tens, dut.ones, exp_hundreds, exp_tens, exp_ones);
                $display("      seg:    got=%b/%b/%b expected=%b/%b/%b",
                          dut.in0, dut.in1, dut.in2, exp_seg0, exp_seg1, exp_seg2);
            end else begin
                $display("PASS [%0s] opcode=%b A=%0d B=%0d -> result=%0d digits=%0d%0d%0d",
                          label, op_in, a_in, b_in, dut.result,
                          dut.hundreds, dut.tens, dut.ones);
            end
        end
    endtask

    // ---------------------------------------------------------------------
    // Part 2: display multiplexer cycling
    // ---------------------------------------------------------------------
    task check_mux_state;
        input [3:0] exp_an;
        input [6:0] exp_sseg;
        input [8*20:1] label;
        begin
            checks = checks + 1;
            if (an !== exp_an || sseg !== exp_sseg) begin
                errors = errors + 1;
                $display("FAIL [%0s] an=got %b expected %b | sseg=got %b expected %b",
                          label, an, exp_an, sseg, exp_sseg);
            end else begin
                $display("PASS [%0s] an=%b sseg=%b", label, an, sseg);
            end
        end
    endtask

    // ---------------------------------------------------------------------
    // Waveform dump -- includes dut.in0..in3 (the per-digit segment
    // patterns feeding the multiplexer) along with everything else in the
    // testbench/DUT hierarchy, so it's easy to see the result in a viewer
    // like GTKWave.
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("ALU_main_tb.vcd");
        $dumpvars(0, ALU_main_tb);
    end

    initial begin
        $display("=========================================================");
        $display(" ALU_main testbench starting");
        $display("=========================================================");

        reset = 1;
        sw    = 15'd0;
        repeat (3) @(posedge clk);
        reset = 0;
        @(posedge clk);

        $display("--- Part 1: ALU opcodes through the full display pipeline ---");

        // Directed: one case per defined opcode
        run_case(6'd10, 6'd5,  3'b000, "ADD basic");
        run_case(6'd10, 6'd5,  3'b001, "SUB basic");
        run_case(6'd42, 6'd53, 3'b010, "AND basic");
        run_case(6'd42, 6'd53, 3'b011, "OR basic");
        run_case(6'd42, 6'd53, 3'b100, "XOR basic");

        // Edge cases
        run_case(6'd0,  6'd0,  3'b000, "ADD zero");
        run_case(6'd63, 6'd63, 3'b000, "ADD max (overflow into hundreds digit)");
        run_case(6'd0,  6'd1,  3'b001, "SUB underflow");
        run_case(6'd63, 6'd63, 3'b100, "XOR identical (result 0)");

        // Undefined opcodes should show 000
        run_case(6'd25, 6'd7,  3'b101, "Undefined opcode 101");
        run_case(6'd25, 6'd7,  3'b110, "Undefined opcode 110");
        run_case(6'd25, 6'd7,  3'b111, "Undefined opcode 111");

        // Randomized sweep across valid opcodes
        for (i = 0; i < 50; i = i + 1) begin
            run_case($random & 6'h3F, $random & 6'h3F, $random % 5, "random");
        end

        $display("--- Part 2: display multiplexer cycling ---");

        // Set a known ALU result: A=12, B=34, ADD -> result=46 -> digits 0,4,6
        reset = 1;
        @(posedge clk);
        reset = 0;
        sw = {3'b000, 6'd12, 6'd34};
        #10;

        // After reset, state should be 00 -> digit0 (hundreds) selected
        check_mux_state(4'b1110, dut.in0, "state0: hundreds digit");

        @(posedge slow_clk); #1;
        check_mux_state(4'b1101, dut.in1, "state1: tens digit");

        @(posedge slow_clk); #1;
        check_mux_state(4'b1011, dut.in2, "state2: ones digit");

        @(posedge slow_clk); #1;
        check_mux_state(4'b0111, dut.in3, "state3: blank digit");

        @(posedge slow_clk); #1;
        check_mux_state(4'b1110, dut.in0, "state0 again: wraps back to hundreds digit");

        $display("=========================================================");
        if (errors == 0)
            $display(" ALL %0d CHECKS PASSED", checks);
        else
            $display(" %0d / %0d CHECKS FAILED", errors, checks);
        $display("=========================================================");

        $finish;
    end

endmodule
