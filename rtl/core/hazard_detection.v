
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

`ifdef COMBINATION_ROM

    DFF #(1) DFF_inst(clk,rstn,`Enable,`Disable,busy,hold);
`else
    assign hold  = busy;
`endif

    assign flush = jump;

endmodule //hazard_detection
