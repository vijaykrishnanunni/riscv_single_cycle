module decoder (
    input  logic [31:0] instr,
    output logic [31:0] imm,
    output logic [1:0]  alu_op,   // 00: default/load/store, 01: branch, 10: R-type, 11: I-type ALU
    output logic [6:0]  opcode,
    output logic [4:0]  rd,
    output logic [2:0]  funct3,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [6:0]  funct7
);

    assign opcode = instr[6:0];

    always_comb begin
        // Set defaults
        rd      = 5'd0;
        funct3  = 3'd0;
        funct7  = 7'd0;
        rs1     = 5'd0;
        rs2     = 5'd0;
        imm     = 32'd0;
        alu_op  = 2'b00;

        case (opcode)
            7'b0110011: begin  // R-type (add, sub, etc.)
                rd      = instr[11:7];
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                rs2     = instr[24:20];
                funct7  = instr[31:25];
                alu_op  = 2'b10;
            end

            7'b0010011: begin  // I-type ALU (addi, slti, etc.)
                rd      = instr[11:7];
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                imm     = $signed(instr[31:20]);
                alu_op  = 2'b11;
            end

            7'b0000011: begin  // Load
                rd      = instr[11:7];
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                imm     = $signed(instr[31:20]);
                alu_op  = 2'b00;
            end

            7'b1100111: begin  // JALR
                rd      = instr[11:7];
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                imm     = $signed(instr[31:20]);
                alu_op  = 2'b00;
            end

            7'b0100011: begin  // S-type (store)
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                rs2     = instr[24:20];
                imm     = $signed({instr[31:25], instr[11:7]});
                alu_op  = 2'b00;
            end

            7'b1100011: begin  // B-type (branch)
                funct3  = instr[14:12];
                rs1     = instr[19:15];
                rs2     = instr[24:20];
                imm     = $signed({{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0});
                alu_op  = 2'b01;
            end

            7'b0110111,        // LUI
            7'b0010111: begin  // AUIPC
                rd      = instr[11:7];
                imm     = {instr[31:12], 12'b0};
                alu_op  = 2'b00;
            end

            7'b1101111: begin  // J-type (JAL)
                rd      = instr[11:7];
                imm     = $signed({{11{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0});
                alu_op  = 2'b00;
            end

            default: begin
                // Unknown instruction, keep defaults
            end
        endcase
    end

endmodule
