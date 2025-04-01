
`include "../defines.v"
module mem_wb (
    input  wire                 clk             ,
    input  wire                 rstn            ,
    // data
    input  wire [`RegBus]       MEM_result      ,
    input  wire [`RegAddrBus]   MEM_rd_addr     ,
    // control
    input  wire                 MEM_rmem        ,   // memory   read  enable
    input  wire                 MEM_wen         ,   // register write enable
    // data
    output wire [`RegBus]       WB_result       ,
    output wire [`RegAddrBus]   WB_rd_addr      ,
    // control
    output wire                 WB_rmem         ,   // memory   read  enable
    output wire                 WB_wen              // register write enable
);

DFF #(`Regnum       ) result_dff    (clk,rstn,`Disable,32'h100  ,MEM_result     ,WB_result   );
DFF #(`RegAddrnum   ) rd_addr_dff   (clk,rstn,`Disable,`ZeroReg ,MEM_rd_addr    ,WB_rd_addr  );
DFF #(1             ) rmem_dff      (clk,rstn,`Disable,`Disable ,MEM_rmem       ,WB_rmem     );
DFF #(1             ) wen_dff       (clk,rstn,`Disable,`Disable ,MEM_wen        ,WB_wen      );

endmodule //mem_wb