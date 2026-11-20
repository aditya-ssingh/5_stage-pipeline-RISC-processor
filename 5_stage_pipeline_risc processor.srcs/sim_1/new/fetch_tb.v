`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2026 23:21:30
// Design Name: 
// Module Name: fetch_tb
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


module fetch_tb;

    reg clk;
    reg reset;
    reg PCSrcE;
    reg [31:0] PCTargetE;

    wire [31:0] InstrD;
    wire [31:0] PCD;
    wire [31:0] PCPlus4D;
    wire [31:0] PCF;

    // DUT: Design Under Test
    fetch uut (
        .clk(clk),
        .reset(reset),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .InstrD(InstrD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .PCF(PCF)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        PCSrcE = 0;
        PCTargetE = 32'd16;

        $monitor(
            "Time=%0t | PCF=%h | InstrD=%h | PCD=%h | PCPlus4D=%h | PCSrcE=%b",
            $time, PCF, InstrD, PCD, PCPlus4D, PCSrcE
        );

        // Reset
        #10;
        reset = 0;

        // Sequential instruction fetching
        #30;

        // Branch operation
        PCSrcE = 1;

        #10;

        // Return to sequential fetching
        PCSrcE = 0;

        #30;

        $display("Fetch Cycle Simulation Completed");

        $finish;

    end

endmodule

