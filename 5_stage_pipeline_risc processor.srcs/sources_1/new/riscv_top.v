`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: .11.2026 12:37:00
// Design Name: 
// Module Name: riscv_top
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


// 32-bit, 5-stage pipelined RISC-V processor
// Supported: ADD, SUB, AND, OR, XOR,
// ADDI, ANDI, ORI, XORI, LW, SW, BEQ, BNE

module riscv_top(
    input wire clk,
    input wire reset,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_alu_result,
    output wire [31:0] debug_writeback,
    output wire debug_regwrite
);

// ==================================================
// INSTRUCTION MEMORY, DATA MEMORY AND REGISTER FILE
// ==================================================

reg [31:0] instr_mem [0:255];
reg [31:0] data_mem  [0:255];
reg [31:0] regs      [0:31];

// ==================================================
// FETCH STAGE
// ==================================================

reg [31:0] pc;

wire [31:0] instr_f;
wire [31:0] pc_plus4_f;

assign instr_f = instr_mem[pc[9:2]];
assign pc_plus4_f = pc + 32'd4;

assign debug_pc = pc;

// ==================================================
// IF / ID PIPELINE REGISTER
// ==================================================

reg [31:0] instr_d;
reg [31:0] pc_d;

// ==================================================
// DECODE STAGE
// ==================================================

wire [6:0] opcode_d = instr_d[6:0];
wire [4:0] rd_d = instr_d[11:7];
wire [2:0] funct3_d = instr_d[14:12];
wire [4:0] rs1_d = instr_d[19:15];
wire [4:0] rs2_d = instr_d[24:20];
wire [6:0] funct7_d = instr_d[31:25];

//wire [31:0] rd1_d =
    //(rs1_d == 0) ? 32'd0 : regs[rs1_d];

//wire [31:0] rd2_d =
    //(rs2_d == 0) ? 32'd0 : regs[rs2_d];
    wire [31:0] rd1_d;
    wire [31:0] rd2_d;

// ==================================================
// CONTROL UNIT AND IMMEDIATE GENERATOR
// ==================================================

reg regwrite_d;
reg memread_d;
reg memwrite_d;
reg memtoreg_d;
reg alusrc_d;
reg branch_d;
reg branch_ne_d;

reg [3:0] alu_control_d;
reg [31:0] imm_d;

reg uses_rs1_d;
reg uses_rs2_d;

always @(*) begin

    regwrite_d = 0;
    memread_d = 0;
    memwrite_d = 0;
    memtoreg_d = 0;
    alusrc_d = 0;
    branch_d = 0;
    branch_ne_d = 0;

    alu_control_d = 0;
    imm_d = 0;

    uses_rs1_d = 0;
    uses_rs2_d = 0;

    case (opcode_d)

        // R TYPE: ADD, SUB, AND, OR, XOR
        7'b0110011: begin

            regwrite_d = 1;
            uses_rs1_d = 1;
            uses_rs2_d = 1;

            case (funct3_d)

                3'b000:
                    alu_control_d =
                    (funct7_d == 7'b0100000) ?
                    4'd1 : 4'd0;

                3'b111: alu_control_d = 4'd2;
                3'b110: alu_control_d = 4'd3;
                3'b100: alu_control_d = 4'd4;

                default: begin
                    regwrite_d = 0;
                end

            endcase
        end

        // I TYPE: ADDI, ANDI, ORI, XORI
        7'b0010011: begin

            regwrite_d = 1;
            alusrc_d = 1;
            uses_rs1_d = 1;

            imm_d = {{20{instr_d[31]}},
                     instr_d[31:20]};

            case (funct3_d)

                3'b000: alu_control_d = 4'd0;
                3'b111: alu_control_d = 4'd2;
                3'b110: alu_control_d = 4'd3;
                3'b100: alu_control_d = 4'd4;

                default: regwrite_d = 0;

            endcase
        end

        // LOAD WORD
        7'b0000011: begin

            regwrite_d = 1;
            memread_d = 1;
            memtoreg_d = 1;
            alusrc_d = 1;
            uses_rs1_d = 1;

            imm_d = {{20{instr_d[31]}},
                     instr_d[31:20]};

            alu_control_d = 4'd0;
        end

        // STORE WORD
        7'b0100011: begin

            memwrite_d = 1;
            alusrc_d = 1;

            uses_rs1_d = 1;
            uses_rs2_d = 1;

            imm_d = {{20{instr_d[31]}},
                     instr_d[31:25],
                     instr_d[11:7]};

            alu_control_d = 4'd0;
        end

        // BEQ / BNE
        7'b1100011: begin

            branch_d = 1;
            branch_ne_d = (funct3_d == 3'b001);

            uses_rs1_d = 1;
            uses_rs2_d = 1;

            imm_d = {{19{instr_d[31]}},
                     instr_d[31],
                     instr_d[7],
                     instr_d[30:25],
                     instr_d[11:8],
                     1'b0};

            alu_control_d = 4'd1;
        end

        default: begin
            // NOP
        end

    endcase
end

// ==================================================
// ID / EX PIPELINE REGISTER
// ==================================================

reg [31:0] pc_e;
reg [31:0] rd1_e;
reg [31:0] rd2_e;
reg [31:0] imm_e;

reg [4:0] rs1_e;
reg [4:0] rs2_e;
reg [4:0] rd_e;

reg regwrite_e;
reg memread_e;
reg memwrite_e;
reg memtoreg_e;
reg alusrc_e;
reg branch_e;
reg branch_ne_e;

reg [3:0] alu_control_e;

// ==================================================
// HAZARD DETECTION UNIT
// LOAD-USE HAZARD
// ==================================================

wire load_use_stall;

assign load_use_stall =
    memread_e &&
    (rd_e != 5'd0) &&
    ((uses_rs1_d && (rd_e == rs1_d)) ||
     (uses_rs2_d && (rd_e == rs2_d)));

// ==================================================
// EX / MEM PIPELINE REGISTER
// ==================================================

reg [31:0] alu_result_m;
reg [31:0] write_data_m;

reg [4:0] rd_m;

reg regwrite_m;
reg memread_m;
reg memwrite_m;
reg memtoreg_m;

// ==================================================
// MEM / WB PIPELINE REGISTER
// ==================================================

reg [31:0] read_data_w;
reg [31:0] alu_result_w;

reg [4:0] rd_w;

reg regwrite_w;
reg memtoreg_w;

// ==================================================
// WRITEBACK STAGE
// ==================================================

wire [31:0] result_w;

assign result_w = memtoreg_w ? read_data_w : alu_result_w;

//assign result_w =
    //memtoreg_w ? read_data_w : alu_result_w;
    // REGISTER FILE READ BYPASS
    
    assign rd1_d =
        (rs1_d == 0) ? 32'd0 :
        (regwrite_w && (rd_w != 0) && (rd_w == rs1_d))
        ? result_w : regs[rs1_d];
    
    assign rd2_d =
        (rs2_d == 0) ? 32'd0 :
        (regwrite_w && (rd_w != 0) && (rd_w == rs2_d))
        ? result_w : regs[rs2_d];

assign debug_writeback = result_w;
assign debug_regwrite = regwrite_w;

// ==================================================
// FORWARDING UNIT
// ==================================================

reg [1:0] forward_a;
reg [1:0] forward_b;

always @(*) begin

    forward_a = 2'b00;
    forward_b = 2'b00;

    if (regwrite_m && (rd_m != 0) &&
        (rd_m == rs1_e) && !memtoreg_m)

        forward_a = 2'b10;

    else if (regwrite_w && (rd_w != 0) &&
             (rd_w == rs1_e))

        forward_a = 2'b01;


    if (regwrite_m && (rd_m != 0) &&
        (rd_m == rs2_e) && !memtoreg_m)

        forward_b = 2'b10;

    else if (regwrite_w && (rd_w != 0) &&
             (rd_w == rs2_e))

        forward_b = 2'b01;

end

// ==================================================
// EXECUTE STAGE
// ==================================================

reg [31:0] src_a_e;
reg [31:0] forwarded_b_e;

wire [31:0] alu_src_b_e;

reg [31:0] alu_result_e;

wire branch_taken_e;
wire [31:0] branch_target_e;

wire [31:0] result_w_internal = result_w;

always @(*) begin

    case (forward_a)

        2'b10: src_a_e = alu_result_m;
        2'b01: src_a_e = result_w_internal;

        default: src_a_e = rd1_e;

    endcase


    case (forward_b)

        2'b10: forwarded_b_e = alu_result_m;
        2'b01: forwarded_b_e = result_w_internal;

        default: forwarded_b_e = rd2_e;

    endcase

end

assign alu_src_b_e =
    alusrc_e ? imm_e : forwarded_b_e;

// ALU

always @(*) begin

    case (alu_control_e)

        4'd0: alu_result_e = src_a_e + alu_src_b_e;
        4'd1: alu_result_e = src_a_e - alu_src_b_e;
        4'd2: alu_result_e = src_a_e & alu_src_b_e;
        4'd3: alu_result_e = src_a_e | alu_src_b_e;
        4'd4: alu_result_e = src_a_e ^ alu_src_b_e;

        default: alu_result_e = 32'd0;

    endcase

end

// BRANCH CONTROL

assign branch_taken_e =
    branch_e &&
    (branch_ne_e ?
     (src_a_e != forwarded_b_e) :
     (src_a_e == forwarded_b_e));

assign branch_target_e = pc_e + imm_e;

// ==================================================
// MEMORY STAGE
// ==================================================

wire [31:0] read_data_m;

assign read_data_m =
    data_mem[alu_result_m[9:2]];

assign debug_alu_result = alu_result_m;

// ==================================================
// SEQUENTIAL LOGIC
// ==================================================

integer k;

always @(posedge clk or posedge reset) begin

    if (reset) begin

        pc <= 0;

        instr_d <= 32'h00000013;
        pc_d <= 0;

        pc_e <= 0;
        rd1_e <= 0;
        rd2_e <= 0;
        imm_e <= 0;

        rs1_e <= 0;
        rs2_e <= 0;
        rd_e <= 0;

        regwrite_e <= 0;
        memread_e <= 0;
        memwrite_e <= 0;
        memtoreg_e <= 0;
        alusrc_e <= 0;
        branch_e <= 0;
        branch_ne_e <= 0;

        alu_control_e <= 0;

        alu_result_m <= 0;
        write_data_m <= 0;
        rd_m <= 0;

        regwrite_m <= 0;
        memread_m <= 0;
        memwrite_m <= 0;
        memtoreg_m <= 0;

        read_data_w <= 0;
        alu_result_w <= 0;
        rd_w <= 0;

        regwrite_w <= 0;
        memtoreg_w <= 0;

        for (k = 0; k < 32; k = k + 1)
            regs[k] <= 0;

        for (k = 0; k < 256; k = k + 1)
            data_mem[k] <= 0;

    end

    else begin

        // WRITEBACK

        if (regwrite_w && (rd_w != 0))
            regs[rd_w] <= result_w;

        regs[0] <= 0;

        // MEMORY WRITE

        if (memwrite_m)
            data_mem[alu_result_m[9:2]]
                <= write_data_m;

        // MEM / WB REGISTER

        read_data_w <= read_data_m;
        alu_result_w <= alu_result_m;
        rd_w <= rd_m;

        regwrite_w <= regwrite_m;
        memtoreg_w <= memtoreg_m;

        // EX / MEM REGISTER

        alu_result_m <= alu_result_e;
        write_data_m <= forwarded_b_e;
        rd_m <= rd_e;

        regwrite_m <= regwrite_e;
        memread_m <= memread_e;
        memwrite_m <= memwrite_e;
        memtoreg_m <= memtoreg_e;

        // FETCH AND PC CONTROL

        if (branch_taken_e) begin

            pc <= branch_target_e;

            instr_d <= 32'h00000013;
            pc_d <= 0;

        end

        else if (!load_use_stall) begin

            pc <= pc_plus4_f;

            instr_d <= instr_f;
            pc_d <= pc;

        end

        // ID / EX REGISTER

        if (branch_taken_e || load_use_stall) begin

            pc_e <= 0;
            rd1_e <= 0;
            rd2_e <= 0;
            imm_e <= 0;

            rs1_e <= 0;
            rs2_e <= 0;
            rd_e <= 0;

            regwrite_e <= 0;
            memread_e <= 0;
            memwrite_e <= 0;
            memtoreg_e <= 0;
            alusrc_e <= 0;
            branch_e <= 0;
            branch_ne_e <= 0;

            alu_control_e <= 0;

        end

        else begin

            pc_e <= pc_d;

            rd1_e <= rd1_d;
            rd2_e <= rd2_d;
            imm_e <= imm_d;

            rs1_e <= rs1_d;
            rs2_e <= rs2_d;
            rd_e <= rd_d;

            regwrite_e <= regwrite_d;
            memread_e <= memread_d;
            memwrite_e <= memwrite_d;
            memtoreg_e <= memtoreg_d;
            alusrc_e <= alusrc_d;
            branch_e <= branch_d;
            branch_ne_e <= branch_ne_d;

            alu_control_e <= alu_control_d;

        end

    end

end

endmodule

