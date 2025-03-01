
module pc (
        input  wire         clk         ,
        input  wire         rstn        ,
        input  wire         jump_en     ,
        input  wire [31:0]  jump_addr   ,

        output reg  [31:0]  pc
    );

    reg [31:0] npc;

    always @(*) 
    begin
        case ({rstn, jump_en})
            // 2'b00: npc = 32'b0; 
            // 2'b01: npc = 32'b0; 
            2'b11: npc = jump_addr; 
            2'b10: npc = pc + 3'd4; 
            default: npc = 32'd0; 
        endcase
    end

    always @(posedge clk) 
        pc <= npc;


endmodule

