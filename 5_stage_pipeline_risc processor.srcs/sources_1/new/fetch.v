`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2026 23:17:41
// Design Name: 
// Module Name: fetch
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


module fetch(

    input clk,
    input reset,
    input PCSrcE,
    input [31:0] PCTargetE,

    output [31:0] InstrD,
    output [31:0] PCD,
    output [31:0] PCPlus4D,
    output [31:0] PCF
);

    wire [31:0] PCNext;
    wire [31:0] PCPlus4F;
    wire [31:0] InstrF;

    // 1. PC MUX
    assign PCNext = PCSrcE ? PCTargetE : PCPlus4F;

    // 2. Program Counter
    reg [31:0] PC;

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'h00000000;
        else
            PC <= PCNext;
    end

    assign PCF = PC;

    // 3. Adder (PC + 4)
    assign PCPlus4F = PCF + 32'd4;

    // 4. Instruction Memory
    reg [31:0] instruction_memory [0:255];

    initial begin
        instruction_memory[0] = 32'h00500093;
        instruction_memory[1] = 32'h00A00113;
        instruction_memory[2] = 32'h002081B3;
        instruction_memory[3] = 32'h00302023;
        instruction_memory[4] = 32'h00000013;

        // Remaining memory initialized with NOP
        // (ADDI x0, x0, 0)
    end

    assign InstrF = instruction_memory[PCF[9:2]];

    // 5. IF/ID Pipeline Register
    reg [31:0] InstrReg;
    reg [31:0] PCReg;
    reg [31:0] PCPlus4Reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            InstrReg   <= 32'b0;
            PCReg      <= 32'b0;
            PCPlus4Reg <= 32'b0;
        end
        else begin
            InstrReg   <= InstrF;
            PCReg      <= PCF;
            PCPlus4Reg <= PCPlus4F;
        end
    end

    assign InstrD   = InstrReg;
    assign PCD      = PCReg;
    assign PCPlus4D = PCPlus4Reg;

endmodule

