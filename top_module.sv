module top(

    // Clock and reset
    input  logic clk,
    input  logic rst,

    // 1. Declare PC & instruction
    output logic [31:0] pc,            // PC Unit → Instruction Memory, WB Mux(PC+imm)

    // 2. Decoder outputs
    output logic [31:0] imm,           // Decoder → ALU Mux, PC Unit, WB Mux(PC+imm)
    output logic [6:0]  opcode,        // Decoder → Control Unit
    output logic [4:0]  rd, rs1, rs2,  // Decoder → Register File
    output logic [2:0]  funct3,        // Decoder → ALU Controller, Branch Unit, LSU
    output logic [6:0]  funct7,        // Decoder → ALU Controller

    // 3. Control Unit signals
    output logic RegWrite,             // Control Unit→ Register File (rd)
    output logic MemWrite,             // Control Unit→ Load/Store Unit (store)
    output logic MemRead,              // Control Unit→ Load/Store Unit (load)
    output logic MemToReg,             // Control Unit→ WB mux sel (=1 → WB selects read_data(load) from memory)
    output logic ALUSrc,               // Control Unit→ ALU input mux sel
    output logic Branch,               // Control Unit→ Branch Unit
    output logic Jump,                 // Control Unit→ PC Unit, WB Mux(sel)
    output logic AUIPC,                // Control Unit→ PC Unit, WB Mux(sel)
    output logic [1:0] alu_op,         // Control Unit→ ALU Controller
    output logic [3:0] alu_control,    // ALU Controller → ALU
    output logic write_enable,         // LSU→ Data Memory

    // 4. Register file
    output logic [31:0] reg_data1,     // Register File → ALU(rs1), PC Unit (jalr PC←rs1+imm)
    output logic [31:0] reg_data2,     // Register File → ALU(rs2), LSU Unit (sw Mem[rs1 + imm]←rs2)

    // 5. ALU
    output logic [31:0] alu_result,    // ALU → LSU, Branch Unit, WB Mux
    output logic [31:0] alu_in2,       // From ALU Mux (reg_data2 or imm)
    output logic Z, N, V, Carry,       // ALU → Branch Unit

    // 6. Branch logic
    output logic branch_taken,         // Branch Unit → PC Unit

    // 7. Memory signals
    output logic [31:0] mem_read_word,   // Data Mem → LSU
    output logic [31:0] mem_write_word,  // LSU → Data Mem
    output logic [31:0] read_data,       // LSU → WB Mux

    // 8. Writeback mux
    output logic [31:0] write_back_data,

    // 9. JALR signal
    output logic jal_r

);

logic [31:0] instruction;  // Instruction Memory → Decoder

assign jal_r = (opcode == 7'b1100111);

///////

// IF

// Instruction Mem
instruction_memory imem (
    .addr(pc),
    .instr(instruction)
);

// PC Unit
pc_unit pc_u (
    .clk(clk), .rst(rst),
    .branch_taken(branch_taken), .Branch(Branch),
    .Jump(Jump), .jal_r(jal_r),
    .imm(imm), .rs1(reg_data1),
    .pc_out(pc)
);

// ID Stage

// Decoder
decoder dec (
    .instr(instruction),
    .imm(imm), .opcode(opcode),
    .rd(rd), .rs1(rs1), .rs2(rs2),
    .funct3(funct3), .funct7(funct7)
);

// Control Unit
control_unit cu (
    .opcode(opcode),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .MemRead(MemRead), .MemToReg(MemToReg),
    .ALUSrc(ALUSrc), .Branch(Branch), .Jump(Jump), .AUIPC(AUIPC),
    .alu_op(alu_op)
);

// Register File
register_file rf (
    .clk(clk), .RegWrite(RegWrite),
    .rs1(rs1), .rs2(rs2), .rd(rd),
    .write_data(write_back_data),
    .read_data1(reg_data1), .read_data2(reg_data2)
);

// EX stage

// ALU control
alucontroller aluctrl (
    .alu_op(alu_op), .funct3(funct3), .funct7(funct7),
    .alu_control(alu_control)
);

assign alu_in2 = ALUSrc ? imm : reg_data2;

// ALU
alu alu_u (
    .a(reg_data1), .b(alu_in2), .alu_control(alu_control),
    .result(alu_result), .Z(Z), .N(N), .V(V), .Carry(Carry)
);

// Branch Unit
branch_unit bu (
    .Branch(Branch), .funct3(funct3),
    .Z(Z), .N(N), .V(V), .Carry(Carry),
    .branch_taken(branch_taken)
);

// MEM

// LSU
load_store_unit lsu (
    .clk(clk), .MemRead(MemRead), .MemWrite(MemWrite),
    .funct3(funct3), .addr(alu_result),
    .write_data(reg_data2),
    .mem_read_word(mem_read_word),
    .mem_write_word(mem_write_word),
    .read_data(read_data),
    .write_enable(write_enable)
);

// Data Memory 
data_memory dmem (
    .clk(clk),
    .MemRead(MemRead),
    .MemWrite(write_enable),
    .addr(alu_result),
    .mem_write_word(mem_write_word),
    .mem_read_word(mem_read_word)
);

// WB Stage

// Writeback logic
always_comb begin
    case (1'b1)
        MemToReg: write_back_data = read_data;         // From LSU
        AUIPC:    write_back_data = pc + imm;          // From PC + imm
        Jump:     write_back_data = pc + 32'd4;        // From PC + 4
        default:  write_back_data = alu_result;        // From ALU
    endcase
end

endmodule
