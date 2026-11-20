`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 00:41:43
// Design Name: 
// Module Name: excute_tb
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


module excute_tb;

    // Inputs
    reg clk;
    reg reset;

    reg [31:0] RD1E;
    reg [31:0] RD2E;
    reg [31:0] PCE;
    reg [31:0] ImmExtE;
    reg [31:0] PCPlus4E;

    reg RegWriteE;
    reg [1:0] ResultSrcE;
    reg MemWriteE;
    reg JumpE;
    reg BranchE;
    reg [3:0] ALUControlE;
    reg ALUSrcE;

    // Outputs
    wire PCSrcE;
    wire [31:0] PCTargetE;

    wire RegWriteM;
    wire [1:0] ResultSrcM;
    wire MemWriteM;

    wire [31:0] ALUResultM;
    wire [31:0] WriteDataM;
    wire [31:0] PCPlus4M;

    // DUT: Design Under Test

    execute DUT (

        .clk(clk),
        .reset(reset),

        .RD1E(RD1E),
        .RD2E(RD2E),
        .PCE(PCE),
        .ImmExtE(ImmExtE),
        .PCPlus4E(PCPlus4E),

        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),

        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),

        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),

        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M)

    );

    // Clock Generation

    always #5 clk = ~clk;

    // Test Sequence

    initial begin

        clk = 0;
        reset = 1;

        RD1E = 0;
        RD2E = 0;
        PCE = 0;
        ImmExtE = 0;
        PCPlus4E = 0;

        RegWriteE = 0;
        ResultSrcE = 0;
        MemWriteE = 0;
        JumpE = 0;
        BranchE = 0;
        ALUControlE = 0;
        ALUSrcE = 0;

        // Reset

        #10;
        reset = 0;

        // TEST 1: ADD OPERATION

        RD1E = 32'd10;
        RD2E = 32'd20;
        ALUControlE = 4'b0010;
        ALUSrcE = 0;

        RegWriteE = 1;
        ResultSrcE = 2'b00;
        PCPlus4E = 32'd104;

        #10;

        if (ALUResultM == 32'd30)
            $display("TEST 1 PASSED: ADD");
        else
            $display("TEST 1 FAILED: ADD");

        // TEST 2: ADD IMMEDIATE

        RD1E = 32'd10;
        ImmExtE = 32'd5;
        ALUSrcE = 1;
        ALUControlE = 4'b0010;

        #10;

        if (ALUResultM == 32'd15)
            $display("TEST 2 PASSED: ADDI");
        else
            $display("TEST 2 FAILED: ADDI");

        // TEST 3: SUBTRACT

        RD1E = 32'd20;
        RD2E = 32'd10;
        ALUSrcE = 0;
        ALUControlE = 4'b0110;

        #10;

        if (ALUResultM == 32'd10)
            $display("TEST 3 PASSED: SUBTRACT");
        else
            $display("TEST 3 FAILED: SUBTRACT");

        // TEST 4: AND OPERATION

        RD1E = 32'h0000000F;
        RD2E = 32'h0000000A;
        ALUControlE = 4'b0000;

        #10;

        if (ALUResultM == 32'h0000000A)
            $display("TEST 4 PASSED: AND");
        else
            $display("TEST 4 FAILED: AND");

        // TEST 5: BRANCH EQUAL

        RD1E = 32'd25;
        RD2E = 32'd25;

        ALUControlE = 4'b0110;
        ALUSrcE = 0;

        BranchE = 1;
        JumpE = 0;

        PCE = 32'h00000100;
        ImmExtE = 32'd8;

        #1;

        if (PCSrcE == 1 && PCTargetE == 32'h00000108)
            $display("TEST 5 PASSED: BRANCH TAKEN");
        else
            $display("TEST 5 FAILED: BRANCH");

        // TEST 6: BRANCH NOT TAKEN

        RD1E = 32'd25;
        RD2E = 32'd20;

        #1;

        if (PCSrcE == 0)
            $display("TEST 6 PASSED: BRANCH NOT TAKEN");
        else
            $display("TEST 6 FAILED: BRANCH NOT TAKEN");

        // TEST 7: JUMP

        JumpE = 1;
        BranchE = 0;

        #1;

        if (PCSrcE == 1)
            $display("TEST 7 PASSED: JUMP");
        else
            $display("TEST 7 FAILED: JUMP");

        // TEST 8: MEMORY WRITE CONTROL

        JumpE = 0;
        MemWriteE = 1;
        RegWriteE = 1;

        RD2E = 32'd50;
        ALUControlE = 4'b0010;
        RD1E = 32'd100;

        #10;

        if (MemWriteM == 1 &&
            RegWriteM == 1 &&
            WriteDataM == 32'd50)
            $display("TEST 8 PASSED: PIPELINE REGISTERS");
        else
            $display("TEST 8 FAILED: PIPELINE REGISTERS");

        #10;

        $display("--------------------------------");
        $display("EXECUTE CYCLE TESTING COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
