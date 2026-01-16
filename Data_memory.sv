module data_memory(
    input logic clk,
    input logic MemRead,
    input logic MemWrite,
    input logic [31:0] addr,
    input logic [31:0] mem_write_word,
    output logic [31:0] mem_read_word
);

logic [31:0] mem [1023:0] ;/// 4KB = 1024 words  of 32 bit

always_comb begin
    if(MemRead)
    mem_read_word = mem[addr[11:2]] ;
    else
    mem_read_word =  32'd0 ;
end


always_ff @(posedge clk) begin
    if(MemWrite)
    mem[addr[11:2]] <= mem_write_word ;


end

endmodule
   