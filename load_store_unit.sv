module load_store_unit(
    input  logic        clk,
    input  logic        MemRead,
    input  logic        MemWrite,
    input  logic [2:0]  funct3,        // To determine size/type
    input  logic [31:0] addr,          // Byte address
    input  logic [31:0] write_data,    // From register file
    input  logic [31:0] mem_read_word, // From data_memory (always returns a word)
    output logic [31:0] mem_write_word,// Word to write into memory
    output logic [31:0] read_data,     // Final value loaded into reg
    output logic        write_enable   // Asserted only for aligned SW
);

    logic [1:0] byte_offset;
    assign byte_offset = addr[1:0];

    always_comb begin
        read_data = 32'b0;
        mem_write_word = 32'b0;
        write_enable = 1'b0;

        // LOADS
        if (MemRead) begin
            case (funct3)
                3'b000: begin // LB
                    case (byte_offset)
                        2'b00: read_data = {{24{mem_read_word[7]}}, mem_read_word[7:0]};
                        2'b01: read_data = {{24{mem_read_word[15]}}, mem_read_word[15:8]};
                        2'b10: read_data = {{24{mem_read_word[23]}}, mem_read_word[23:16]};
                        2'b11: read_data = {{24{mem_read_word[31]}}, mem_read_word[31:24]};
                    endcase
                end
                3'b001: begin // LH
                    case (byte_offset[1]) // halfword aligned
                        1'b0: read_data = {{16{mem_read_word[15]}}, mem_read_word[15:0]};
                        1'b1: read_data = {{16{mem_read_word[31]}}, mem_read_word[31:16]};
                    endcase
                end
                3'b010: begin // LW
                    read_data = mem_read_word;
                end
                3'b100: begin // LBU
                    case (byte_offset)
                        2'b00: read_data = {24'b0, mem_read_word[7:0]};
                        2'b01: read_data = {24'b0, mem_read_word[15:8]};
                        2'b10: read_data = {24'b0, mem_read_word[23:16]};
                        2'b11: read_data = {24'b0, mem_read_word[31:24]};
                    endcase
                end
                3'b101: begin // LHU
                    case (byte_offset[1])
                        1'b0: read_data = {16'b0, mem_read_word[15:0]};
                        1'b1: read_data = {16'b0, mem_read_word[31:16]};
                    endcase
                end
                default: read_data = 32'b0;
            endcase
        end

        // STORES
        if (MemWrite) begin
            case (funct3)
                3'b000: begin // SB
                    case (byte_offset)
                        2'b00: mem_write_word = {mem_read_word[31:8], write_data[7:0]};
                        2'b01: mem_write_word = {mem_read_word[31:16], write_data[7:0], mem_read_word[7:0]};
                        2'b10: mem_write_word = {mem_read_word[31:24], write_data[7:0], mem_read_word[15:0]};
                        2'b11: mem_write_word = {write_data[7:0], mem_read_word[23:0]};
                    endcase
                    write_enable = 1'b1;
                end
                3'b001: begin // SH
                    case (byte_offset[1])
                        1'b0: mem_write_word = {mem_read_word[31:16], write_data[15:0]};
                        1'b1: mem_write_word = {write_data[15:0], mem_read_word[15:0]};
                    endcase
                    write_enable = 1'b1;
                end
                3'b010: begin // SW
                    mem_write_word = write_data;
                    write_enable = (byte_offset == 2'b00); // only aligned
                end
                default: begin
                    mem_write_word = 32'b0;
                    write_enable = 1'b0;
                end
            endcase
        end
    end
endmodule
