module instruction_memory (
    input  logic [31:0] addr,      // PC input
    output logic [31:0] instr      // Instruction output
);

    // Word-addressable memory (256 words = 1 KB)
    logic [31:0] memory [0:255];

    // Word-aligned fetch (ignore bottom 2 bits of PC)
    assign instr = memory[addr[9:2]];

    // Simulation-only preload task
    task load_instr(input logic [31:0] address, input logic [31:0] value);
        memory[address[9:2]] = value;
    endtask

endmodule
