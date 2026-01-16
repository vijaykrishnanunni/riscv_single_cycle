module control_unit(
    input logic [6:0] opcode,
    output logic RegWrite,
    output logic MemWrite,
    output logic MemRead,
    output logic MemToReg,
    output logic ALUSrc,
    output logic Branch,
    output logic Jump,
    output logic AUIPC,             // Add Upper Immediate to PC
    output logic [1:0] alu_op       // ALU operation selector
);

always_comb begin
    // Default values
    RegWrite = 0;
    MemRead  = 0;
    MemWrite = 0;
    MemToReg = 0;
    ALUSrc   = 0;
    Branch   = 0;
    Jump     = 0;
    AUIPC    = 0;
    alu_op   = 2'b00;

    case (opcode)
        7'b0110011: begin // R-type
            ALUSrc   = 0;
            RegWrite = 1;
            alu_op   = 2'b10;
        end

        7'b0010011: begin // I-type
            ALUSrc   = 1;
            RegWrite = 1;
            alu_op   = 2'b11;
        end

        7'b0000011: begin // Load - I-type
            ALUSrc    = 1;
            RegWrite  = 1;
            MemRead   = 1;
            MemToReg  = 1;
            alu_op    = 2'b11;
        end

        7'b1100111: begin // JALR - I-type
            ALUSrc   = 1;
            RegWrite = 1;
            Jump     = 1;
            alu_op   = 2'b11;
        end

        7'b1101111: begin // JAL - J-type
            ALUSrc   = 1;
            RegWrite = 1;
            Jump     = 1;
            alu_op   = 2'b00; // not ALU-based
        end

        7'b0100011: begin // Store - S-type
            ALUSrc   = 1;
            MemWrite = 1;
            alu_op   = 2'b00; // ALU add for address
        end

        7'b1100011: begin // Branch - B-type
            ALUSrc  = 0;
            Branch  = 1;
            alu_op  = 2'b01;
        end

        7'b0010111: begin // AUIPC - U-type
            ALUSrc   = 1;
            RegWrite = 1;
            AUIPC    = 1;
            alu_op   = 2'b00; // address calculation
        end

        7'b0110111: begin // LUI - U-type
            ALUSrc   = 1;
            RegWrite = 1;
            alu_op   = 2'b00; // Not ALU-related
        end

        default: begin
            alu_op = 2'b00;
        end
    endcase 
end

endmodule
