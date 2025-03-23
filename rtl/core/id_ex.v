
`include "../defines.v"

module id_ex (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        // from ctrl
        input  wire                 nop         ,
        input  wire                 jump        ,

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
        input  wire                  ID_lui      ,    // LUI Instruction
        input  wire                  ID_jal      ,    // JAL  Instruction
        input  wire                  ID_jalr     ,    // JALR Instruction
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
        output wire                  EX_lui      ,    // LUI Instruction
        output wire                  EX_jal      ,    // JAL  Instruction
        output wire                  EX_jalr     ,    // JALR Instruction
        output wire                  EX_inst_R   ,    // INST TYPE R
        output wire [`mem_type_bus]  EX_mem_type ,    // load/store data type
        output wire                  EX_mem_sign ,    // load/store data sign
        output wire                  EX_sign     ,    // ALU SIGN
        output wire                  EX_sub      ,    // ALU SUB
        output wire [`RegBus]        EX_imm           // immediate

        // output wire [`RegBus]       csr_waddr_o ,   // csr address
        // output wire                 csr_wen_o        // csr write enable
    );

    wire hold = nop | jump;
    // jump或nop都会hold

    DFF #(`Regnum       ) inst_addr_dff (clk,rstn,hold,`ZeroWord,ID_inst_addr   ,EX_inst_addr   );
    DFF #(`RegAddrnum   ) rs1_addr_dff  (clk,rstn,hold,`ZeroReg ,ID_rs1_addr    ,EX_rs1_addr    );
    DFF #(`RegAddrnum   ) rs2_addr_dff  (clk,rstn,hold,`ZeroReg ,ID_rs2_addr    ,EX_rs2_addr    );
    DFF #(`RegAddrnum   ) rd_addr_dff   (clk,rstn,hold,`ZeroReg ,ID_rd_addr     ,EX_rd_addr     );
    DFF #(`Regnum       ) rs1_data_dff  (clk,rstn,hold,`ZeroWord,ID_rs1_data    ,EX_rs1_data    );
    DFF #(`Regnum       ) rs2_data_dff  (clk,rstn,hold,`ZeroWord,ID_rs2_data    ,EX_rs2_data    );
    DFF #(1             ) rmem_dff      (clk,rstn,hold,`Disable ,ID_rmem        ,EX_rmem        );
    DFF #(1             ) wmem_dff      (clk,rstn,hold,`Disable ,ID_wmem        ,EX_wmem        );
    DFF #(1             ) wen_dff       (clk,rstn,hold,`Disable ,ID_wen         ,EX_wen         );
    DFF #(1             ) jmp_dff       (clk,rstn,hold,`Disable ,ID_jmp         ,EX_jmp         );
    DFF #(1             ) jcc_dff       (clk,rstn,hold,`Disable ,ID_jcc         ,EX_jcc         );
    DFF #(`ALU_ctrl_num ) alu_ctrl_dff  (clk,rstn,hold,{`ALU_ctrl_num{`Disable}},ID_alu_ctrl,EX_alu_ctrl);
    DFF #(1             ) lui_dff       (clk,rstn,hold,`Disable ,ID_lui         ,EX_lui         );
    DFF #(1             ) jal_dff       (clk,rstn,hold,`Disable ,ID_jal         ,EX_jal         );
    DFF #(1             ) jalr_dff      (clk,rstn,hold,`Disable ,ID_jalr        ,EX_jalr        );
    DFF #(1             ) inst_R_dff    (clk,rstn,hold,`Disable ,ID_inst_R      ,EX_inst_R      );
    DFF #(`mem_type_num ) mem_type_dff  (clk,rstn,hold,{`mem_type_num{`Disable}},ID_mem_type,EX_mem_type);
    DFF #(1             ) mem_sign_dff  (clk,rstn,hold,`Disable ,ID_mem_sign    ,EX_mem_sign    );
    DFF #(1             ) sign_dff      (clk,rstn,hold,`Disable ,ID_sign        ,EX_sign        );
    DFF #(1             ) sub_dff       (clk,rstn,hold,`Disable ,ID_sub         ,EX_sub         );
    DFF #(`Regnum       ) imm_dff       (clk,rstn,hold,`ZeroWord,ID_imm         ,EX_imm         );

    // DFF #(32) csr_waddr_dff     (clk,rstn,hold,`ZeroWord ,csr_waddr_i    ,csr_waddr_o    );
    // DFF #( 1) csr_wen_dff       (clk,rstn,hold,`Disable  ,csr_wen_i      ,csr_wen_o      );

endmodule
