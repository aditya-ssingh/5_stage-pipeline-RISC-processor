`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 00:35:19
// Design Name: 
// Module Name: execute
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


module execute(

    input clk,
    input reset,

    // Data inputs from Decode Stage
    input [31:0] RD1E,
    input [31:0] RD2E,
    input [31:0] PCE,
    input [31:0] ImmExtE,
    input [31:0] PCPlus4E,

    // Control inputs
    input RegWriteE,
    input [1:0] ResultSrcE,
    input MemWriteE,
    input JumpE,
    input BranchE,
    input [3:0] ALUControlE,
    input ALUSrcE,

    // Execute Stage outputs
    output PCSrcE,
    output [31:0] PCTargetE,

    // Outputs to Memory Stage
    output reg RegWriteM,
    output reg [1:0] ResultSrcM,
    output reg MemWriteM,
    output reg [31:0] ALUResultM,
    output reg [31:0] WriteDataM,
    output reg [31:0] PCPlus4M
);

    // Internal signals
    reg [31:0] SrcBE;
    reg [31:0] ALUResultE;
    wire ZeroE;

    // --------------------------------
    // 1. MUX
    // --------------------------------

    always @(*) begin
        if (ALUSrcE == 1'b1)
            SrcBE = ImmExtE;
        else
            SrcBE = RD2E;
    end

    // --------------------------------
    // 2. ALU
    // --------------------------------

    always @(*) begin

        case (ALUControlE)

            4'b0000: ALUResultE = RD1E & SrcBE;
            4'b0001: ALUResultE = RD1E | SrcBE;
            4'b0010: ALUResultE = RD1E + SrcBE;
            4'b0110: ALUResultE = RD1E - SrcBE;
            4'b0111: ALUResultE = ($signed(RD1E) < $signed(SrcBE)) ? 32'd1 : 32'd0;
            4'b1100: ALUResultE = ~(RD1E | SrcBE);

            default: ALUResultE = 32'd0;

        endcase

    end

    // --------------------------------
    // 3. Zero Detection
    // --------------------------------

    assign ZeroE = (ALUResultE == 32'd0);

    // --------------------------------
    // 4. AND Gate + Branch Logic
    // --------------------------------

    assign PCSrcE = JumpE | (BranchE & ZeroE);

    // --------------------------------
    // 5. Branch Target Adder
    // --------------------------------

    assign PCTargetE = PCE + ImmExtE;

    // --------------------------------
    // 6. Execute / Memory Pipeline Registers
    // --------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            RegWriteM  <= 1'b0;
            ResultSrcM <= 2'b00;
            MemWriteM  <= 1'b0;

            ALUResultM <= 32'd0;
            WriteDataM <= 32'd0;
            PCPlus4M   <= 32'd0;

        end

        else begin

            RegWriteM  <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM  <= MemWriteE;

            ALUResultM <= ALUResultE;
            WriteDataM <= RD2E;
            PCPlus4M   <= PCPlus4E;

        end

    end

endmodule