`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 20.11.2026 23:33:17
// Design Name: 
// Module Name: decode
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


module decode(

    input clk,
    input reset,

    // Fetch stage inputs
    input [31:0] InstrD,
    input [31:0] PCD,
    input [31:0] PCPlus4D,

    // Writeback inputs
    input RegWriteW,
    input [31:0] ResultW,
    input [4:0] RdW,

    // Execute stage outputs
    output [31:0] RD1E,
    output [31:0] RD2E,
    output [31:0] ImmExtE,
    output [31:0] PCE,
    output [31:0] PCPlus4E,

    output [4:0] Rs1E,
    output [4:0] Rs2E,

    output RegWriteE,
    output [1:0] ResultSrcE,
    output MemWriteE,
    output JumpE,
    output BranchE,
    output [2:0] ALUControlE,
    output ALUSrcE
);

    // Instruction fields
    wire [6:0] opcode;
    wire [2:0] funct3;
    wire funct7;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign opcode = InstrD[6:0];
    assign rd     = InstrD[11:7];
    assign funct3 = InstrD[14:12];
    assign rs1    = InstrD[19:15];
    assign rs2    = InstrD[24:20];
    assign funct7 = InstrD[30];

    // Control signals
    wire RegWriteD;
    wire [1:0] ResultSrcD;
    wire MemWriteD;
    wire JumpD;
    wire BranchD;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire [1:0] ImmSrcD;

    // 1. CONTROL UNIT
    control_unit CU (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),

        .RegWrite(RegWriteD),
        .ResultSrc(ResultSrcD),
        .MemWrite(MemWriteD),
        .Jump(JumpD),
        .Branch(BranchD),
        .ALUControl(ALUControlD),
        .ALUSrc(ALUSrcD),
        .ImmSrc(ImmSrcD)
    );

    // 2. REGISTER FILE
    wire [31:0] RD1D;
    wire [31:0] RD2D;

    register_file RF (
        .clk(clk),
        .reset(reset),
        .WE3(RegWriteW),
        .A1(rs1),
        .A2(rs2),
        .A3(RdW),
        .WD3(ResultW),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    // 3. IMMEDIATE EXTENDER
    wire [31:0] ImmExtD;

    immediate_extender EXT (
        .Instr(InstrD),
        .ImmSrc(ImmSrcD),
        .ImmExt(ImmExtD)
    );

    // 4. DECODE STAGE REGISTERS (ID/EX)
    reg [31:0] RD1Reg;
    reg [31:0] RD2Reg;
    reg [31:0] ImmExtReg;
    reg [31:0] PCReg;
    reg [31:0] PCPlus4Reg;

    reg [4:0] Rs1Reg;
    reg [4:0] Rs2Reg;

    reg RegWriteReg;
    reg [1:0] ResultSrcReg;
    reg MemWriteReg;
    reg JumpReg;
    reg BranchReg;
    reg [2:0] ALUControlReg;
    reg ALUSrcReg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin

            RD1Reg <= 0;
            RD2Reg <= 0;
            ImmExtReg <= 0;
            PCReg <= 0;
            PCPlus4Reg <= 0;

            Rs1Reg <= 0;
            Rs2Reg <= 0;

            RegWriteReg <= 0;
            ResultSrcReg <= 0;
            MemWriteReg <= 0;
            JumpReg <= 0;
            BranchReg <= 0;
            ALUControlReg <= 0;
            ALUSrcReg <= 0;

        end
        else begin

            RD1Reg <= RD1D;
            RD2Reg <= RD2D;
            ImmExtReg <= ImmExtD;

            PCReg <= PCD;
            PCPlus4Reg <= PCPlus4D;

            Rs1Reg <= rs1;
            Rs2Reg <= rs2;

            RegWriteReg <= RegWriteD;
            ResultSrcReg <= ResultSrcD;
            MemWriteReg <= MemWriteD;
            JumpReg <= JumpD;
            BranchReg <= BranchD;
            ALUControlReg <= ALUControlD;
            ALUSrcReg <= ALUSrcD;

        end
    end

    // Execute stage outputs
    assign RD1E = RD1Reg;
    assign RD2E = RD2Reg;
    assign ImmExtE = ImmExtReg;

    assign PCE = PCReg;
    assign PCPlus4E = PCPlus4Reg;

    assign Rs1E = Rs1Reg;
    assign Rs2E = Rs2Reg;

    assign RegWriteE = RegWriteReg;
    assign ResultSrcE = ResultSrcReg;
    assign MemWriteE = MemWriteReg;
    assign JumpE = JumpReg;
    assign BranchE = BranchReg;
    assign ALUControlE = ALUControlReg;
    assign ALUSrcE = ALUSrcReg;

endmodule


// CONTROL UNIT
module control_unit (
    input [6:0] opcode,
    input [2:0] funct3,
    input funct7,

    output reg RegWrite,
    output reg [1:0] ResultSrc,
    output reg MemWrite,
    output reg Jump,
    output reg Branch,
    output reg [2:0] ALUControl,
    output reg ALUSrc,
    output reg [1:0] ImmSrc
);

    always @(*) begin

        RegWrite = 0;
        ResultSrc = 2'b00;
        MemWrite = 0;
        Jump = 0;
        Branch = 0;
        ALUControl = 3'b000;
        ALUSrc = 0;
        ImmSrc = 2'b00;

        case (opcode)

            // R-TYPE
            7'b0110011: begin
                RegWrite = 1;

                case (funct3)
                    3'b000:
                        ALUControl = funct7 ? 3'b001 : 3'b000;
                    3'b111: ALUControl = 3'b010;
                    3'b110: ALUControl = 3'b011;
                    3'b100: ALUControl = 3'b100;
                    3'b010: ALUControl = 3'b101;
                    3'b001: ALUControl = 3'b110;
                    3'b101: ALUControl = funct7 ? 3'b111 : 3'b111;
                    default: ALUControl = 3'b000;
                endcase
            end

            // I-TYPE ALU
            7'b0010011: begin
                RegWrite = 1;
                ALUSrc = 1;
                ImmSrc = 2'b00;

                case (funct3)
                    3'b000: ALUControl = 3'b000;
                    3'b111: ALUControl = 3'b010;
                    3'b110: ALUControl = 3'b011;
                    3'b100: ALUControl = 3'b100;
                    3'b010: ALUControl = 3'b101;
                    3'b001: ALUControl = 3'b110;
                    3'b101: ALUControl = 3'b111;
                    default: ALUControl = 3'b000;
                endcase
            end

            // LOAD
            7'b0000011: begin
                RegWrite = 1;
                ResultSrc = 2'b01;
                ALUSrc = 1;
                ImmSrc = 2'b00;
                ALUControl = 3'b000;
            end

            // STORE
            7'b0100011: begin
                MemWrite = 1;
                ALUSrc = 1;
                ImmSrc = 2'b01;
                ALUControl = 3'b000;
            end

            // BRANCH
            7'b1100011: begin
                Branch = 1;
                ImmSrc = 2'b10;
                ALUControl = 3'b001;
            end

            // JAL
            7'b1101111: begin
                RegWrite = 1;
                Jump = 1;
                ResultSrc = 2'b10;
                ImmSrc = 2'b11;
            end

            // JALR
            7'b1100111: begin
                RegWrite = 1;
                Jump = 1;
                ResultSrc = 2'b10;
                ALUSrc = 1;
                ImmSrc = 2'b00;
                ALUControl = 3'b000;
            end

            default: begin
                RegWrite = 0;
            end

        endcase
    end

endmodule


// REGISTER FILE
module register_file (
    input clk,
    input reset,
    input WE3,

    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,

    input [31:0] WD3,

    output [31:0] RD1,
    output [31:0] RD2
);

    reg [31:0] registers [0:31];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 0;
        end
        else if (WE3 && A3 != 0) begin
            registers[A3] <= WD3;
        end
    end

    assign RD1 = (A1 == 0) ? 32'b0 : registers[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : registers[A2];

endmodule


// IMMEDIATE EXTENDER
module immediate_extender (
    input [31:0] Instr,
    input [1:0] ImmSrc,
    output reg [31:0] ImmExt
);

    always @(*) begin

        case (ImmSrc)

            // I-TYPE
            2'b00:
                ImmExt = {{20{Instr[31]}}, Instr[31:20]};

            // S-TYPE
            2'b01:
                ImmExt = {{20{Instr[31]}},
                          Instr[31:25], Instr[11:7]};

            // B-TYPE
            2'b10:
                ImmExt = {{19{Instr[31]}},
                          Instr[31], Instr[7],
                          Instr[30:25], Instr[11:8], 1'b0};

            // J-TYPE
            2'b11:
                ImmExt = {{11{Instr[31]}},
                          Instr[31], Instr[19:12],
                          Instr[20], Instr[30:21], 1'b0};

            default:
                ImmExt = 32'b0;

        endcase
    end

endmodule

