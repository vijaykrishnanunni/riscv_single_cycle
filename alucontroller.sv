module alucontroller (
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    input  logic [1:0] alu_op,
    output logic [3:0] alu_control
);

always_comb begin
    case (alu_op)

        2'b00: alu_control = 4'b0010;  // Default: add (used for lw/sw/jal/jalr/auipc)

        2'b10: begin                   // R-type
            case (funct3)
                3'b000: alu_control = (funct7 == 7'b0000000) ? 4'b0010 : 4'b0110; // add or sub
                3'b100: alu_control = 4'b1000;  // xor
                3'b110: alu_control = 4'b0001;  // or
                3'b111: alu_control = 4'b0000;  // and
                3'b001: alu_control = 4'b1001;  // sll
                3'b101: alu_control = (funct7 == 7'b0000000) ? 4'b1010 : 4'b1011; // srl or sra
                3'b010: alu_control = 4'b1100;  // slt
                3'b011: alu_control = 4'b0111;  // sltu
                default: alu_control = 4'b0010;
            endcase
        end

        2'b01: begin                   // B-type
            case (funct3)
                3'b000: alu_control = 4'b0110;  // beq
                3'b100: alu_control = 4'b0110;  // bne
                3'b110: alu_control = 4'b0111;  // blt
                3'b111: alu_control = 4'b1101;  // bge
                3'b001: alu_control = 4'b1100;  // bltu
                3'b101: alu_control = 4'b1110;  // bgeu
                3'b010: alu_control = 4'b1100;  // slt (alias)
                3'b011: alu_control = 4'b1011;  // sltu (alias)
                default: alu_control = 4'b0010;
            endcase
        end

        2'b11: begin                   // I-type
            case (funct3)
                3'b000: alu_control = 4'b0010;  // addi
                3'b100: alu_control = 4'b1000;  // xori
                3'b110: alu_control = 4'b0001;  // ori
                3'b111: alu_control = 4'b0000;  // andi
                3'b001: alu_control = 4'b1001;  // slli
                3'b101: alu_control = (funct7 == 7'b0000000) ? 4'b1010 : 4'b1011; // srli or srai
                3'b010: alu_control = 4'b1100;  // slti
                3'b011: alu_control = 4'b1011;  // sltiu
                default: alu_control = 4'b0010;
            endcase
        end

        default: alu_control = 4'b0010;

    endcase
end

endmodule
