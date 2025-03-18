
`include "./defines.v"
module pc (
        input  wire             clk         ,
        input  wire             rstn        ,
        input  wire             jump_en     ,
        input  wire [`RegBus]   jump_addr   ,

        output reg  [`RegBus]           pc
    );

    reg [`RegBus] npc;

    always @(*) 
    begin
        case ({rstn, jump_en})
            // 2'b00: npc = `ZeroWord; 
            // 2'b01: npc = `ZeroWord; 
            2'b11: npc = jump_addr; 
            2'b10: npc = pc + 3'd4; 
            default: npc = `ZeroWord; 
        endcase
    end

    always @(posedge clk) 
        pc <= npc;


endmodule

