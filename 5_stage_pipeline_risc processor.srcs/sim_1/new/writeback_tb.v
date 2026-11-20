`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 01:04:05
// Design Name: 
// Module Name: writeback_tb
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


module writeback_tb;

    // Inputs
    reg [31:0] ReadDataW;
    reg [31:0] ALUResultW;
    reg [31:0] PCPlus4W;

    reg [1:0] ResultSrcW;
    reg RegWriteW;

    // Outputs
    wire [31:0] ResultW;
    wire RegWriteOutW;

    // DUT: Design Under Test

    writeback DUT (

        .ReadDataW(ReadDataW),
        .ALUResultW(ALUResultW),
        .PCPlus4W(PCPlus4W),

        .ResultSrcW(ResultSrcW),
        .RegWriteW(RegWriteW),

        .ResultW(ResultW),
        .RegWriteOutW(RegWriteOutW)

    );

    // Test Sequence

    initial begin

        // Initialize Inputs

        ReadDataW = 32'd0;
        ALUResultW = 32'd0;
        PCPlus4W = 32'd0;

        ResultSrcW = 2'b00;
        RegWriteW = 0;

        // TEST 1: ALU RESULT

        ALUResultW = 32'd100;
        ReadDataW = 32'd200;
        PCPlus4W = 32'd300;

        ResultSrcW = 2'b00;
        RegWriteW = 1;

        #10;

        if (ResultW == 32'd100 && RegWriteOutW == 1)
            $display("TEST 1 PASSED: ALU RESULT");
        else
            $display("TEST 1 FAILED: ALU RESULT");

        // TEST 2: MEMORY DATA

        ResultSrcW = 2'b01;
        RegWriteW = 1;

        #10;

        if (ResultW == 32'd200)
            $display("TEST 2 PASSED: MEMORY DATA");
        else
            $display("TEST 2 FAILED: MEMORY DATA");

        // TEST 3: PC PLUS 4

        ResultSrcW = 2'b10;
        PCPlus4W = 32'd104;

        #10;

        if (ResultW == 32'd104)
            $display("TEST 3 PASSED: PC PLUS 4");
        else
            $display("TEST 3 FAILED: PC PLUS 4");

        // TEST 4: INVALID SELECTION

        ResultSrcW = 2'b11;

        #10;

        if (ResultW == 32'd0)
            $display("TEST 4 PASSED: DEFAULT CASE");
        else
            $display("TEST 4 FAILED: DEFAULT CASE");

        // TEST 5: REGISTER WRITE DISABLED

        ResultSrcW = 2'b00;
        RegWriteW = 0;

        #10;

        if (RegWriteOutW == 0)
            $display("TEST 5 PASSED: WRITE DISABLED");
        else
            $display("TEST 5 FAILED: WRITE DISABLED");

        // COMPLETED

        $display("--------------------------------");
        $display("WRITEBACK CYCLE TESTING COMPLETED");
        $display("--------------------------------");

        $finish;

    end

endmodule