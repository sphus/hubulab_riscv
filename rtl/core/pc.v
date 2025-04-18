
`include "../defines.v"
module pc (
        input  wire             clk         ,
        input  wire             rstn        ,
        input  wire [`Hold_Bus] hold        ,
        input  wire             jump        ,
        input  wire [`RegBus]   jump_addr   ,

        output wire [`RegBus]   pc
    );

    reg [`RegBus] pc_reg;
    reg [`RegBus] pc_buff;

    wire hold_flag = |hold;

    always @(posedge clk or negedge rstn)
    begin
        if (rstn == `RstnEnable )
            pc_reg <= `pc_rstn;
        case ({jump,hold_flag})
            3'b01 :pc_reg <= pc_reg;          // hold
            3'b10 :pc_reg <= jump_addr;       // 跳转
            3'b00 :pc_reg <= pc_reg + 32'd4;  // 自增
            default:pc_reg <= `pc_rstn;
        endcase
    end

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            pc_buff <= `pc_rstn;
        else if(!hold_flag)
            pc_buff <= pc_reg;
        else
            pc_buff <= pc_buff;
    end

    assign pc = hold_flag ? pc_buff : pc_reg;


endmodule

