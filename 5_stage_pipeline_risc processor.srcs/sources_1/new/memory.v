`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 00:50:06
// Design Name: 
// Module Name: memory
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


module memory(


    input clk,
    input reset,

    // Inputs from Execute Stage
    input RegWriteM,
    input [1:0] ResultSrcM,
    input MemWriteM,

    input [31:0] ALUResultM,
    input [31:0] WriteDataM,
    input [31:0] PCPlus4M,

    // Outputs to Writeback Stage
    output reg RegWriteW,
    output reg [1:0] ResultSrcW,

    output reg [31:0] ReadDataW,
    output reg [31:0] ALUResultW,
    output reg [31:0] PCPlus4W

);

    // --------------------------------
    // 1. DATA MEMORY
    // --------------------------------

    reg [31:0] DataMem [0:255];

    wire [7:0] Address;

    assign Address = ALUResultM[9:2];

    // Synchronous Memory Write

    always @(posedge clk) begin

        if (MemWriteM)
            DataMem[Address] <= WriteDataM;

    end

    // Asynchronous Memory Read

    wire [31:0] ReadDataM;

    assign ReadDataM = DataMem[Address];

    // --------------------------------
    // 2. MEMORY / WRITEBACK REGISTERS
    // --------------------------------

    always @(posedge clk or posedge reset) begin

        if (reset) begin

            RegWriteW  <= 1'b0;
            ResultSrcW <= 2'b00;

            ReadDataW  <= 32'd0;
            ALUResultW <= 32'd0;
            PCPlus4W   <= 32'd0;

        end

        else begin

            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;

            ReadDataW  <= ReadDataM;
            ALUResultW <= ALUResultM;
            PCPlus4W   <= PCPlus4M;

        end

    end

endmodule
