`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.11.2026 01:02:18
// Design Name: 
// Module Name: writeback
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


module writeback(

    // Inputs from Memory Stage
    input [31:0] ReadDataW,
    input [31:0] ALUResultW,
    input [31:0] PCPlus4W,

    // Control Signal
    input [1:0] ResultSrcW,
    input RegWriteW,

    // Output to Register File
    output reg [31:0] ResultW,
    output wire RegWriteOutW

);

    // --------------------------------
    // 1. 3:1 MULTIPLEXER
    // --------------------------------

    always @(*) begin

        case (ResultSrcW)

            2'b00:
                ResultW = ALUResultW;

            2'b01:
                ResultW = ReadDataW;

            2'b10:
                ResultW = PCPlus4W;

            default:
                ResultW = 32'd0;

        endcase

    end

    // --------------------------------
    // 2. REGISTER WRITE ENABLE
    // --------------------------------

    assign RegWriteOutW = RegWriteW;

endmodule