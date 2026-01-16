module pc_unit(     //Along with Instruction Fetch
    input logic clk,
    input logic rst,
    input logic Branch,          //from CU
    input logic Jump,           //from CU
    input logic jal_r,         // High for JALR, low for JAL
    input logic branch_taken, // From ALU: 1 if branch condition true
    input logic [31:0] imm,
    input logic [31:0] rs1,
     output logic [31:0] pc_out
);

logic [31:0]pc_next;
logic [31:0]pc_reg;

assign pc_out = pc_reg ;

always_comb begin
    if (Jump)
        begin 
            if(jal_r)
            pc_next = rs1 + imm ;
            else 
            pc_next = pc_reg + imm ;
        end
    else if(Branch && branch_taken) 
         pc_next = pc_reg + imm ;
    else pc_next = pc_reg + 32'd4 ;
        
end

always_ff @(posedge clk) begin
    if (rst)
    pc_reg <= 32'd0 ;
    else
    pc_reg <= pc_next ;
    
end

endmodule