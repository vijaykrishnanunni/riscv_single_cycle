module alu (
    input  logic [3:0]  alu_control,
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] result,
    output logic        V,
    output logic        Z,
    output logic        N,
    output logic        Carry
);

    logic borrow;

    always_comb begin
        // Default assignments
        result = 32'b0;
        Carry = 1'b0;
        V = 1'b0;
        N = 1'b0;
        Z = 1'b0;

        case (alu_control) // Patterson & Hennessy scheme
            4'b0000: result = a & b;                     // AND
            4'b0001: result = a | b;                     // OR
            4'b0010: begin                               // ADD
                {Carry, result} = a + b;
                V = ((~a[31]) & (~b[31]) & result[31]) |
                    (a[31] & b[31] & ~result[31]);       // Signed overflow
            end
            4'b0110: begin                               // SUB
                {borrow, result} = a - b;
                Carry = ~borrow;                         // Borrow logic
                V = ((~a[31]) & b[31] & result[31]) |
                    (a[31] & ~b[31] & ~result[31]);      // Signed overflow
            end
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0; // SLT
            4'b1100: result = (a < b) ? 32'd1 : 32'd0;                   // SLTU
            4'b1000: result = a ^ b;                                      // XOR
            4'b1001: result = a << b[4:0];                                // SLL
            4'b1010: result = a >> b[4:0];                                // SRL
            4'b1011: result = $signed(a) >>> b[4:0];                     // SRA
            default: result = 32'b0;
        endcase

        N = result[31];              // Negative flag
        Z = (result == 32'b0);       // Zero flag
    end

endmodule
