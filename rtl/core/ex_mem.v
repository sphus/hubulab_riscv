
`include "../defines.v"

module ex_mem (
        input  wire                 clk          ,
        input  wire                 rstn         ,
        // from ctrl
        input  wire                 jump         ,

        // input  wire [`RegBus]       csr_waddr_i ,   // csr address
        // input  wire                 csr_wen_i   ,   // csr write enable

        // data
        input  wire [`RegBus]       EX_jump_addr    ,
        input  wire [`RegBus]       EX_result       ,
        input  wire [`RegBus]       EX_FD_rs2_data  ,
        input  wire [`RegAddrBus]   EX_rd_addr      ,
        // control
        input  wire                 EX_rmem         ,   // memory   read  enable
        input  wire                 EX_wmem         ,   // memory   write enable
        input  wire                 EX_wen          ,   // register write enable
        input  wire [`mem_type_bus] EX_mem_type     ,   // load/store data type
        input  wire                 EX_mem_sign     ,   // load/store data sign
        input  wire                 EX_jump         ,   // jump signal

        // data
        output wire [`RegBus]       MEM_jump_addr   ,
        output wire [`RegBus]       MEM_result      ,
        output wire [`RegBus]       MEM_FD_rs2_data ,
        output wire [`RegAddrBus]   MEM_rd_addr     ,
        // control
        output wire                 MEM_rmem        ,   // memory   read  enable
        output wire                 MEM_wmem        ,   // memory   write enable
        output wire                 MEM_wen         ,   // register write enable
        output wire [`mem_type_bus] MEM_mem_type    ,   // load/store data type
        output wire                 MEM_mem_sign    ,   // load/store data sign
        output wire                 MEM_jump            // jump signal

        // output wire [`RegBus]       csr_waddr_o ,   // csr address
        // output wire                 csr_wen_o        // csr write enable
    );

    wire hold = jump;
    // jump就hold

    DFF #(`Regnum       ) jump_addr_dff   (clk,rstn,hold,`ZeroWord  ,EX_jump_addr   ,MEM_jump_addr   );
    DFF #(`Regnum       ) result_dff      (clk,rstn,hold,`ZeroWord  ,EX_result      ,MEM_result      );
    DFF #(`Regnum       ) FD_rs2_data_dff (clk,rstn,hold,`ZeroWord  ,EX_FD_rs2_data ,MEM_FD_rs2_data );
    DFF #(`RegAddrnum   ) rd_addr_dff     (clk,rstn,hold,`ZeroReg   ,EX_rd_addr     ,MEM_rd_addr     );
    DFF #(1             ) rmem_dff        (clk,rstn,hold,`Disable   ,EX_rmem        ,MEM_rmem        );
    DFF #(1             ) wmem_dff        (clk,rstn,hold,`Disable   ,EX_wmem        ,MEM_wmem        );
    DFF #(1             ) wen_dff         (clk,rstn,hold,`Disable   ,EX_wen         ,MEM_wen         );
    DFF #(`mem_type_num ) mem_type_dff    (clk,rstn,hold,`LS_B      ,EX_mem_type    ,MEM_mem_type    );
    DFF #(1             ) mem_sign_dff    (clk,rstn,hold,`Disable   ,EX_mem_sign    ,MEM_mem_sign    );
    DFF #(1             ) jump_dff        (clk,rstn,hold,`Disable   ,EX_jump        ,MEM_jump        );

    // DFF #(32) csr_waddr_dff     (clk,rstn,hold,`ZeroWord ,csr_waddr_i    ,csr_waddr_o    );
    // DFF #( 1) csr_wen_dff       (clk,rstn,hold,`Disable  ,csr_wen_i      ,csr_wen_o      );

endmodule
