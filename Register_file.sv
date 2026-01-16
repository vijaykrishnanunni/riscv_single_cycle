module register_file (
    input  logic        clk,
    input  logic        RegWrite,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [31:0]; // 32 registers

    // Initializing all registers to 0 at simulation start
    initial begin
        for (int i = 0; i < 32; i++) begin
            registers[i] = 32'd0;
        end
    end

    // Simulation-only preload task (optional)
    task automatic set_reg(input int idx, input logic [31:0] value);
        if (idx != 0 && idx < 32)
            registers[idx] = value;
    endtask

    // Read ports (combinational)
    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    // Write port (synchronous)
    always_ff @(posedge clk) begin
        if (RegWrite && rd != 5'd0)
            registers[rd] <= write_data;
    end

endmodule
