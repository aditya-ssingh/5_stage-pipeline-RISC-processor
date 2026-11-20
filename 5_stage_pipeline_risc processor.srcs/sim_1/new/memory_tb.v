`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 00:56:29
// Design Name: 
// Module Name: memory_tb
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


module memory_tb;

    // Inputs
    reg clk;
    reg reset;

    reg RegWriteM;
    reg [1:0] ResultSrcM;
    reg MemWriteM;

    reg [31:0] ALUResultM;
    reg [31:0] WriteDataM;
    reg [31:0] PCPlus4M;

    // Outputs
    wire RegWriteW;
    wire [1:0] ResultSrcW;

    wire [31:0] ReadDataW;
    wire [31:0] ALUResultW;
    wire [31:0] PCPlus4W;

    // DUT: Design Under Test

    memory DUT (

        .clk(clk),
        .reset(reset),

        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),

        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),

        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),

        .ReadDataW(ReadDataW),
        .ALUResultW(ALUResultW),
        .PCPlus4W(PCPlus4W)

    );

    // Clock Generation

    always #5 clk = ~clk;

    // Test Sequence

    initial begin

        clk = 0;
        reset = 1;

        RegWriteM = 0;
        ResultSrcM = 0;
        MemWriteM = 0;

        ALUResultM = 0;
        WriteDataM = 0;
        PCPlus4M = 0;

        // TEST 1: RESET

        #12;
        reset = 0;

        @(negedge clk);

        if (RegWriteW == 0 && ReadDataW == 0)
            $display("TEST 1 PASSED: RESET");
        else
            $display("TEST 1 FAILED: RESET");

        // TEST 2: STORE DATA IN MEMORY

        MemWriteM = 1;
        ALUResultM = 32'd4;
        WriteDataM = 32'h12345678;

        RegWriteM = 0;
        ResultSrcM = 2'b00;
        PCPlus4M = 32'd104;

        @(posedge clk);
        #1;

        if (DUT.DataMem[1] == 32'h12345678)
            $display("TEST 2 PASSED: MEMORY WRITE");
        else
            $display("TEST 2 FAILED: MEMORY WRITE");

        // TEST 3: READ DATA FROM MEMORY

        @(negedge clk);

        MemWriteM = 0;
        ALUResultM = 32'd4;

        RegWriteM = 1;
        ResultSrcM = 2'b01;
        PCPlus4M = 32'd108;

        @(posedge clk);
        #1;

        if (ReadDataW == 32'h12345678)
            $display("TEST 3 PASSED: MEMORY READ");
        else
            $display("TEST 3 FAILED: MEMORY READ");

        // TEST 4: ALU RESULT PASSING

        @(negedge clk);

        ALUResultM = 32'd100;
        RegWriteM = 1;
        ResultSrcM = 2'b00;
        PCPlus4M = 32'd112;

        @(posedge clk);
        #1;

        if (ALUResultW == 32'd100)
            $display("TEST 4 PASSED: ALU RESULT");
        else
            $display("TEST 4 FAILED: ALU RESULT");

        // TEST 5: CONTROL SIGNALS

        @(negedge clk);

        RegWriteM = 1;
        ResultSrcM = 2'b10;

        @(posedge clk);
        #1;

        if (RegWriteW == 1 && ResultSrcW == 2'b10)
            $display("TEST 5 PASSED: CONTROL SIGNALS");
        else
            $display("TEST 5 FAILED: CONTROL SIGNALS");

        // TEST 6: PC PLUS 4

        @(negedge clk);

        PCPlus4M = 32'd120;

        @(posedge clk);
        #1;

        if (PCPlus4W == 32'd120)
            $display("TEST 6 PASSED: PC PLUS 4");
        else
            $display("TEST 6 FAILED: PC PLUS 4");

        // TEST COMPLETED

        #10;

        $display("--------------------------------");
        $display("MEMORY CYCLE TESTING COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule
