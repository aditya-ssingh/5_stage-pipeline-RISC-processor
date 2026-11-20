`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 00:07:50
// Design Name: 
// Module Name: decode_tb
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


module decode_tb;




    reg clk;
    reg reset;

    reg [31:0] InstrD;
    reg [31:0] PCD;
    reg [31:0] PCPlus4D;

    reg RegWriteW;
    reg [31:0] ResultW;
    reg [4:0] RdW;

    wire [31:0] RD1E;
    wire [31:0] RD2E;
    wire [31:0] ImmExtE;
    wire [31:0] PCE;
    wire [31:0] PCPlus4E;

    wire [4:0] Rs1E;
    wire [4:0] Rs2E;

    wire RegWriteE;
    wire [1:0] ResultSrcE;
    wire MemWriteE;
    wire JumpE;
    wire BranchE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;

    // DUT
    decode uut (
        .clk(clk),
        .reset(reset),

        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),

        .RegWriteW(RegWriteW),
        .ResultW(ResultW),
        .RdW(RdW),

        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmExtE(ImmExtE),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),

        .Rs1E(Rs1E),
        .Rs2E(Rs2E),

        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Writeback task
    task write_register;
        input [4:0] address;
        input [31:0] data;
        begin
            @(negedge clk);
            RegWriteW = 1;
            RdW = address;
            ResultW = data;

            @(negedge clk);
            RegWriteW = 0;
        end
    endtask

    initial begin

        clk = 0;
        reset = 1;

        InstrD = 0;
        PCD = 0;
        PCPlus4D = 0;

        RegWriteW = 0;
        ResultW = 0;
        RdW = 0;

        $monitor(
            "Time=%0t | Instr=%h | RD1E=%d | RD2E=%d | ImmExtE=%d | PCE=%h | RegWriteE=%b | ALUSrcE=%b",
            $time, InstrD, RD1E, RD2E, ImmExtE,
            PCE, RegWriteE, ALUSrcE
        );

        // RESET
        #12;
        reset = 0;

        // Write x1 = 5
        write_register(5'd1, 32'd5);

        // Write x2 = 10
        write_register(5'd2, 32'd10);

        // ADD x3, x1, x2
        @(negedge clk);
        InstrD = 32'h002081B3;
        PCD = 32'h00000008;
        PCPlus4D = 32'h0000000C;

        @(posedge clk);
        #1;

        if (RD1E == 5 && RD2E == 10 &&
            Rs1E == 1 && Rs2E == 2 &&
            RegWriteE == 1 &&
            ALUControlE == 3'b000) begin

            $display("PASS: ADD instruction decoded correctly");

        end
        else begin
            $display("FAIL: ADD instruction");
        end

        // ADDI x4, x1, 5
        @(negedge clk);
        InstrD = 32'h00508213;
        PCD = 32'h0000000C;
        PCPlus4D = 32'h00000010;

        @(posedge clk);
        #1;

        if (RD1E == 5 &&
            ImmExtE == 5 &&
            ALUSrcE == 1 &&
            RegWriteE == 1) begin

            $display("PASS: ADDI instruction decoded correctly");

        end
        else begin
            $display("FAIL: ADDI instruction");
        end

        // STORE instruction
        @(negedge clk);
        InstrD = 32'h00302023;
        PCD = 32'h00000010;
        PCPlus4D = 32'h00000014;

        @(posedge clk);
        #1;

        if (MemWriteE == 1 &&
            ImmExtE == 0 &&
            ALUSrcE == 1) begin

            $display("PASS: STORE instruction decoded correctly");

        end
        else begin
            $display("FAIL: STORE instruction");
        end

        #10;

        $display("==============================");
        $display("DECODE CYCLE TEST COMPLETED");
        $display("==============================");

        $finish;

    end

endmodule

