
`include "../defines.v"

module id_ex (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        // from ctrl
        input  wire [`Hold_Bus]     hold        ,
        input  wire [`Flush_Bus]    flush       ,

        // input  wire [`RegBus]       csr_waddr_i ,   // csr address
        // input  wire                 csr_wen_i   ,   // csr write enable

        // data
        input  wire [`RegBus]        ID_inst_addr,
        input  wire [`RegAddrBus]    ID_rs1_addr ,
        input  wire [`RegAddrBus]    ID_rs2_addr ,
        input  wire [`RegAddrBus]    ID_rd_addr  ,
        input  wire [`RegBus]        ID_rs1_data ,
        input  wire [`RegBus]        ID_rs2_data ,
        // control
        input  wire                  ID_rmem     ,    // memory   read  enable
        input  wire                  ID_wmem     ,    // memory   write enable
        input  wire                  ID_wen      ,    // register write enable
        input  wire                  ID_jmp      ,    // Jump
        input  wire                  ID_jcc      ,    // Jump on Condition
        input  wire [`ALU_ctrl_bus]  ID_alu_ctrl ,    // ALU Control
        input  wire                  ID_jal      ,    // JAL  Instruction
        input  wire                  ID_jalr     ,    // JALR Instruction
        input  wire                  ID_lui      ,    // LUI Instruction
        input  wire                  ID_auipc    ,    // AUIPC Instruction
        input  wire                  ID_inst_R   ,    // INST TYPE R
        input  wire [`mem_type_bus]  ID_mem_type ,    // load/store data type
        input  wire                  ID_mem_sign ,    // load/store data sign
        input  wire                  ID_sign     ,    // ALU SIGN
        input  wire                  ID_sub      ,    // ALU SUB
        input  wire [`RegBus]        ID_imm      ,    // immediate

        // data
        output wire [`RegBus]        EX_inst_addr,
        output wire [`RegAddrBus]    EX_rs1_addr ,
        output wire [`RegAddrBus]    EX_rs2_addr ,
        output wire [`RegAddrBus]    EX_rd_addr  ,
        output wire [`RegBus]        EX_rs1_data ,
        output wire [`RegBus]        EX_rs2_data ,
        // control
        output wire                  EX_rmem     ,    // memory   read  enable
        output wire                  EX_wmem     ,    // memory   write enable
        output wire                  EX_wen      ,    // register write enable
        output wire                  EX_jmp      ,    // Jump
        output wire                  EX_jcc      ,    // Jump on Condition
        output wire [`ALU_ctrl_bus]  EX_alu_ctrl ,    // ALU Control
        output wire                  EX_jal      ,    // JAL  Instruction
        output wire                  EX_jalr     ,    // JALR Instruction
        output wire                  EX_lui      ,    // LUI Instruction
        output wire                  EX_auipc    ,    // AUIPC Instruction
        output wire                  EX_inst_R   ,    // INST TYPE R
        output wire [`mem_type_bus]  EX_mem_type ,    // load/store data type
        output wire                  EX_mem_sign ,    // load/store data sign
        output wire                  EX_sign     ,    // ALU SIGN
        output wire                  EX_sub      ,    // ALU SUB
        output wire [`RegBus]        EX_imm           // immediate

        // output wire [`RegBus]       csr_waddr_o ,   // csr address
        // output wire                 csr_wen_o        // csr write enable
    );

    wire CE = ~hold[1];
    
    wire flush_dff =  |flush;

    // flush或hold都会flush

    // DFFC #(WIDTH      ) dff          (clk,rstn,flush     ,CE,set_data ,d             ,q              );
    DFFC #(1             ) rmem_dff     (clk,rstn,flush_dff ,CE,`Disable ,ID_rmem       ,EX_rmem        );
    DFFC #(1             ) wmem_dff     (clk,rstn,flush_dff ,CE,`Disable ,ID_wmem       ,EX_wmem        );
    DFFC #(1             ) wen_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_wen        ,EX_wen         );
    DFFC #(1             ) jmp_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_jmp        ,EX_jmp         );
    DFFC #(1             ) jcc_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_jcc        ,EX_jcc         );
    DFFC #(`ALU_ctrl_num ) alu_ctrl_dff (clk,rstn,flush_dff ,CE,`INST_ADD,ID_alu_ctrl   ,EX_alu_ctrl    );
    DFFC #(1             ) jal_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_jal        ,EX_jal         );
    DFFC #(1             ) jalr_dff     (clk,rstn,flush_dff ,CE,`Disable ,ID_jalr       ,EX_jalr        );
    DFFC #(1             ) lui_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_lui        ,EX_lui         );
    DFFC #(1             ) auipc_dff    (clk,rstn,flush_dff ,CE,`Disable ,ID_auipc      ,EX_auipc       );
    DFFC #(1             ) inst_R_dff   (clk,rstn,flush_dff ,CE,`Disable ,ID_inst_R     ,EX_inst_R      );
    DFFC #(`mem_type_num ) mem_type_dff (clk,rstn,flush_dff ,CE,`LS_B    ,ID_mem_type   ,EX_mem_type    );
    DFFC #(1             ) mem_sign_dff (clk,rstn,flush_dff ,CE,`Disable ,ID_mem_sign   ,EX_mem_sign    );
    DFFC #(1             ) sign_dff     (clk,rstn,flush_dff ,CE,`Disable ,ID_sign       ,EX_sign        );
    DFFC #(1             ) sub_dff      (clk,rstn,flush_dff ,CE,`Disable ,ID_sub        ,EX_sub         );

    
    // DFFD #(WIDTH      ) dff          (clk,rstn,CE,set_data   ,d              ,q              );
    DFFD #(`Regnum      ) inst_addr_dff (clk,rstn,CE,`ZeroWord  ,ID_inst_addr   ,EX_inst_addr   );
    DFFD #(`RegAddrnum  ) rs1_addr_dff  (clk,rstn,CE,`ZeroReg   ,ID_rs1_addr    ,EX_rs1_addr    );
    DFFD #(`RegAddrnum  ) rs2_addr_dff  (clk,rstn,CE,`ZeroReg   ,ID_rs2_addr    ,EX_rs2_addr    );
    DFFD #(`RegAddrnum  ) rd_addr_dff   (clk,rstn,CE,`ZeroReg   ,ID_rd_addr     ,EX_rd_addr     );
    DFFD #(`Regnum      ) rs1_data_dff  (clk,rstn,CE,`ZeroWord  ,ID_rs1_data    ,EX_rs1_data    );
    DFFD #(`Regnum      ) rs2_data_dff  (clk,rstn,CE,`ZeroWord  ,ID_rs2_data    ,EX_rs2_data    );
    DFFD #(`Regnum      ) imm_dff       (clk,rstn,CE,`ZeroWord  ,ID_imm         ,EX_imm         );
    // control 


    // DFF #(32) csr_waddr_dff     (clk,rstn,hold,`ZeroWord ,csr_waddr_i    ,csr_waddr_o    );
    // DFF #( 1) csr_wen_dff       (clk,rstn,hold,`Disable  ,csr_wen_i      ,csr_wen_o      );

endmodule
