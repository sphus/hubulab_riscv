
`include "../defines.v"
module pc (
        input  wire             clk         ,
        input  wire             rstn        ,
        input  wire             nop         ,
        input  wire             jump        ,
        input  wire [`RegBus]   jump_addr   ,

        output wire [`RegBus]   pc
    );

    reg [`RegBus] npc;
    reg [`RegBus] pc_reg;

    always @(*) 
    begin
        case ({rstn,jump,nop})
            3'b101 : npc = pc_reg;          // nop
            3'b110 : npc = jump_addr;       // 跳转
            3'b100 : npc = pc_reg + 32'd4;   // 自增
            default: npc = `pc_rstn; 
        endcase
    end


    


    assign pc = nop ? pc_reg - 32'd4 : pc_reg;

    always @(posedge clk) 
        pc_reg <= npc;


    

endmodule

