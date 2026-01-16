module branch_unit (
    input  logic [2:0] funct3,
    input  logic Z,  // zero flag
    input  logic N,  // negative flag
    input  logic V,  // overflow
    input  logic Carry,
    output logic branch_taken
);

always_comb begin
    case (funct3)
        3'b000: branch_taken =  Z;           // BEQ
        3'b001: branch_taken = ~Z;           // BNE
        3'b100: branch_taken =  N ^ V;       // BLT (signed)
        3'b101: branch_taken = ~(N ^ V);     // BGE (signed)
        3'b110: branch_taken = ~Carry;       // BLTU (unsigned)
        3'b111: branch_taken =  Carry;       // BGEU (unsigned)
        default: branch_taken = 1'b0;
    endcase
end

endmodule
