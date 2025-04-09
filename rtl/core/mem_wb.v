
`include "../defines.v"
module mem_wb (
        input  wire                 clk             ,
        input  wire                 rstn            ,
        input  wire [`Hold_Bus]     hold            ,

        // data
        input  wire [`RegBus]       MEM_result      ,
        input  wire [`RegBus]       MEM_mem_rdata   ,
        input  wire [`RegAddrBus]   MEM_rd_addr     ,
        // control
        input  wire                 MEM_rmem        ,   // memory   read  enable
        input  wire                 MEM_wen         ,   // register write enable
        // data
        output wire [`RegBus]       WB_result       ,
        output wire [`RegBus]       WB_mem_rdata    ,
        output wire [`RegAddrBus]   WB_rd_addr      ,
        // control
        output wire                 WB_rmem         ,   // memory   read  enable
        output wire                 WB_wen              // register write enable
    );

    // wire CE = ~{|hold};
    wire CE = ~hold[1];
    wire flush = `Disable;

    // DFFC #(WIDTH      ) dff          (clk,rstn,flush,CE,set_data ,d          ,q      );
    DFFC #(1             ) rmem_dff     (clk,rstn,flush,CE,`Disable ,MEM_rmem   ,WB_rmem);
    DFFC #(1             ) wen_dff      (clk,rstn,flush,CE,`Disable ,MEM_wen    ,WB_wen );
    
    // DFFD #(WIDTH      ) dff          (clk,rstn,CE,set_data   ,d              ,q              );
    DFFD #(`Regnum       ) result_dff   (clk,rstn,CE,`ZeroWord  ,MEM_result     ,WB_result      );
    DFFD #(`Regnum       ) mem_rdata_dff(clk,rstn,CE,`ZeroWord  ,MEM_mem_rdata  ,WB_mem_rdata   );
    DFFD #(`RegAddrnum   ) rd_addr_dff  (clk,rstn,CE,`ZeroReg   ,MEM_rd_addr    ,WB_rd_addr     );

endmodule //mem_wb
