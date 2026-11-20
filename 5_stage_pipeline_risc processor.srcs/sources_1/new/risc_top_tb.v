`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2026 13:01:06
// Design Name: 
// Module Name: risc_top_tb
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


module risc_top_tb;

reg clk;
reg reset;

wire [31:0] debug_pc;
wire [31:0] debug_alu_result;
wire [31:0] debug_writeback;
wire debug_regwrite;

integer i;
integer errors;

// ==================================================
// DUT: DEVICE UNDER TEST
// ==================================================

riscv_top dut (

.clk(clk),
    .reset(reset),

.debug_pc(debug_pc),
    .debug_alu_result(debug_alu_result),
    .debug_writeback(debug_writeback),
    .debug_regwrite(debug_regwrite)

);

// ==================================================
// CLOCK GENERATION
// ==================================================

initial begin

    clk = 0;

    forever #5 clk = ~clk;

end

// ==================================================
// TEST PROGRAM
// ==================================================

initial begin

errors = 0;
    reset = 1;

    // INITIALIZE INSTRUCTION MEMORY

    for (i = 0; i <256; i = i + 1)
        dut.instr_mem[i] = 32'h00000013;

    // INITIALIZE DATA MEMORY

    for (i = 0; i <256; i = i + 1)
        dut.data_mem[i] = 0;

// ----------------------------------------------
    // INSTRUCTION PROGRAM
    // ----------------------------------------------

// ADDI x1, x0, 5
    dut.instr_mem[0] = 32'h00500093;

// ADDI x2, x0, 10
    dut.instr_mem[1] = 32'h00A00113;

// ADD x3, x1, x2
    dut.instr_mem[2] = 32'h002081B3;

// SUB x4, x2, x1
    dut.instr_mem[3] = 32'h40110233;

// SW x3, 0(x0)
    dut.instr_mem[4] = 32'h00302023;

// LW x5, 0(x0)
    dut.instr_mem[5] = 32'h00002283;

// ADD x6, x5, x1
    // Load-use hazard test
    dut.instr_mem[6] = 32'h00128333;

// ADDI x7, x0, 20
    dut.instr_mem[7] = 32'h01400393;

// BEQ x6, x7, +8
    // Branch taken test
    dut.instr_mem[8] = 32'h00730463;

// ADDI x8, x0, 99
    // This instruction should be skipped
    dut.instr_mem[9] = 32'h06300413;

// ADDI x8, x0, 7
    dut.instr_mem[10] = 32'h00700413;

// ----------------------------------------------
    // RESET
    // ----------------------------------------------

    repeat (2) @(posedge clk);

    #1 reset = 0;

    // WAIT FOR PIPELINE

    repeat (35) @(posedge clk);

    #1;

// ----------------------------------------------
    // DISPLAY RESULTS
    // ----------------------------------------------

$display("");
    $display("========================================");
    $display("  RISC-V PROCESSOR TEST RESULTS");
    $display("========================================");

$display("Register x1 = %0d", dut.regs[1]);
    $display("Register x2 = %0d", dut.regs[2]);
    $display("Register x3 = %0d", dut.regs[3]);
    $display("Register x4 = %0d", dut.regs[4]);
    $display("Register x5 = %0d", dut.regs[5]);
    $display("Register x6 = %0d", dut.regs[6]);
    $display("Register x7 = %0d", dut.regs[7]);
    $display("Register x8 = %0d", dut.regs[8]);

    $display("Data Memory[0] = %0d", dut.data_mem[0]);

    $display("----------------------------------------");

// ----------------------------------------------
    // CHECK EXPECTED OUTPUTS
    // ----------------------------------------------

if (dut.regs[1] !== 32'd5) begin
        $display("FAIL: x1 expected 5");
        errors = errors + 1;
    end

if (dut.regs[2] !== 32'd10) begin
        $display("FAIL: x2 expected 10");
        errors = errors + 1;
    end

if (dut.regs[3] !== 32'd15) begin
        $display("FAIL: x3 expected 15");
        errors = errors + 1;
    end

if (dut.regs[4] !== 32'd5) begin
        $display("FAIL: x4 expected 5");
        errors = errors + 1;
    end

if (dut.regs[5] !== 32'd15) begin
        $display("FAIL: x5 expected 15");
        errors = errors + 1;
    end

if (dut.regs[6] !== 32'd20) begin
        $display("FAIL: x6 expected 20");
        errors = errors + 1;
    end

if (dut.regs[7] !== 32'd20) begin
        $display("FAIL: x7 expected 20");
        errors = errors + 1;
    end

if (dut.regs[8] !== 32'd7) begin
        $display("FAIL: x8 expected 7");
        errors = errors + 1;
    end

if (dut.data_mem[0] !== 32'd15) begin
        $display("FAIL: Data Memory expected 15");
        errors = errors + 1;
    end

if (dut.regs[0] !== 32'd0) begin
        $display("FAIL: x0 must remain zero");
        errors = errors + 1;
    end

// ----------------------------------------------
    // FINAL RESULT
    // ----------------------------------------------

if (errors == 0)
        $display("PASS: ALL TESTS PASSED");

else
        $display("FAIL: %0d TESTS FAILED", errors);

    $display("========================================");

    $finish;

end

endmodule
