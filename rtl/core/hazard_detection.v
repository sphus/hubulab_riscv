
`include "../defines.v"
module hazard_detection (
        input  wire                 clk     ,
        input  wire                 rstn    ,
        input  wire                 jump    ,
        input  wire [`RegAddrBus]   ID_rs1  ,
        input  wire [`RegAddrBus]   ID_rs2  ,
        input  wire [`RegAddrBus]   EX_rd   ,
        input  wire                 EX_rmem ,
        input  wire                 busy    ,
        output wire [`Hold_Bus]     hold    ,
        output wire [`Flush_Bus]    flush
    );

    // busy:访问外部总线等待数据->CPU停滞
    // jump:跳转->冲刷IF_ID,pc装入jump_addr
    // nop:有数据冲突,需要流水线插入nop指令->pc停滞,IF_ID冲刷



    // load读写冲突,IF_ID,ID_EX冲刷

    // load读写冲突,PC暂停一拍
    wire nop = EX_rmem & ((EX_rd == ID_rs1) | (EX_rd == ID_rs2));

    assign hold  = {busy,nop};
    assign flush = {jump,nop};
    

    // reg nop_reg;
    // // 如果busy,就停住流水线,再加上读写冲突多停一拍
    // always @(posedge clk)
    // begin
    //     if (!rstn)
    //         nop_reg <= `Disable;
    //     else if(busy & nop)
    //         nop_reg <= `Enable;
    //     else if(busy)
    //         nop_reg <= nop_reg;
    //     else if(!busy)
    //         nop_reg <= `Disable;
    //     else
    //         nop_reg <= nop_reg;
    // end

    // // 高位为全部hold,低位为pc IF_ID ID_EX hold
    // // 没有flush时,hold均无效
    // // assign hold = {busy, nop | nop_reg} & {2{~flush}};
    // assign hold = {busy, nop | nop_reg} & {2{~flush}};

endmodule //hazard_detection



