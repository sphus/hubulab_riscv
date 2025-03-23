
`include "../defines.v"
module forward (
        input  wire                 EX_MEM_wen  ,
        input  wire [`RegAddrBus]   EX_MEM_rd   ,
        input  wire                 MEM_WB_wen  ,
        input  wire [`RegAddrBus]   MEM_WB_rd   ,
        input  wire [`RegAddrBus]   ID_EX_rs1   ,
        input  wire [`RegAddrBus]   ID_EX_rs2   ,

        output wire [`FwdBus    ]   fwd_rs1 ,
        output wire [`FwdBus    ]   fwd_rs2
    );

    // 从EX前递至ID,前递两拍
    // 条件:写使能,rs == rd, rd != 0
    assign fwd_rs1[1] = (EX_MEM_rd != `ZeroReg) & (EX_MEM_wen && (ID_EX_rs1 == EX_MEM_rd));
    assign fwd_rs2[1] = (EX_MEM_rd != `ZeroReg) & (EX_MEM_wen && (ID_EX_rs2 == EX_MEM_rd));

    // 从WB前递至ID,前递一拍
    // 条件:写使能,rs == rd, rd != 0,且EX未前递至ID
    assign fwd_rs1[0] = (MEM_WB_rd != `ZeroReg) & (MEM_WB_wen && (ID_EX_rs1 == MEM_WB_rd)) & ~fwd_rs1[1];
    assign fwd_rs2[0] = (MEM_WB_rd != `ZeroReg) & (MEM_WB_wen && (ID_EX_rs2 == MEM_WB_rd)) & ~fwd_rs2[1];

endmodule //fwd
