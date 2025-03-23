
`include "../defines.v"
module hazard_detection (
        input  wire [`RegAddrBus]   ID_rs1   ,
        input  wire [`RegAddrBus]   ID_rs2   ,
        input  wire [`RegAddrBus]   ID_rd    ,
        input  wire                 EX_rmem  ,

        output wire                 nop         
    );

    // load读写冲突,PC暂停一拍,IF_ID,ID_EX冲刷
    assign nop = EX_rmem & ((ID_rd == ID_rs1) | (ID_rd == ID_rs2));

endmodule //hazard_detection
