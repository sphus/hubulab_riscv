
`include "../defines.v"
module pc (
        input  wire             clk         ,
        input  wire             rstn        ,
        input  wire             nop         ,
        input  wire             jump        ,
        input  wire [`RegBus]   jump_addr   ,

        output reg  [`RegBus]   pc
    );

    reg [`RegBus] npc;

    always @(*) 
    begin
        case ({rstn,jump,nop})
            3'b101 : npc = pc;          // nop
            3'b110 : npc = jump_addr;   // 跳转
            3'b100 : npc = pc + 3'd4;   // 自增
            default: npc = `pc_rstn; 
        endcase
    end

    always @(posedge clk) 
        pc <= npc;

endmodule

