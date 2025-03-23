`include "../defines.v"

module id_unit (
        // from if_id
        input  wire [`RegBus]       inst        ,

        // from reg

        // to reg/id_ex
        output wire [`RegAddrBus]   rs1_addr_o  ,
        output wire [`RegAddrBus]   rs2_addr_o  ,

        // to id_ex
        output wire                 rmem        ,   // memory   read  enable
        output wire                 wmem        ,   // memory   write enable
        output wire                 wen         ,   // register write enable
        output wire                 jmp         ,   // Jump
        output wire                 jcc         ,   // Jump on Condition
        output wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        output wire                 lui         ,   // LUI Instruction
        output wire                 jal         ,   // JAL  Instruction
        output wire                 jalr        ,   // JALR Instruction
        output wire                 inst_R      ,   // INST TYPE R
        output wire [`mem_type_bus] mem_type    ,   // load/store data type
        output wire                 mem_sign    ,   // load/store data sign
        output wire                 sign        ,   // ALU SIGN
        output wire                 sub         ,   // ALU SUB

        output wire [`RegBus]       imm         ,   // immediate
        output wire [`RegAddrBus]   rd_addr_o       // rd address

        // output reg  [`RegBus]       csr_waddr_o ,   // csr address
        // output reg                  csr_wen     ,   // csr write enable

        // to csr_reg
        // output reg  [`RegBus]       csr_raddr_o     // csr address
    );

    // 分线
    assign  rs1_addr_o  = inst[19:15];
    assign  rs2_addr_o  = inst[24:20];
    assign  rd_addr_o   = inst[11: 7];

    wire  [`sw_imm_bus]   imm_ctrl    ;   // Immediate Control

    control control_inst(
                .inst       (inst       ),
                .imm_ctrl   (imm_ctrl   ),
                .rmem       (rmem       ),
                .wmem       (wmem       ),
                .wen        (wen        ),
                .jmp        (jmp        ),
                .jcc        (jcc        ),
                .alu_ctrl   (alu_ctrl   ),
                .lui        (lui        ),
                .jal        (jal        ),
                .jalr       (jalr       ),
                .inst_R     (inst_R     ),
                .mem_type   (mem_type   ),
                .mem_sign   (mem_sign   ),
                .sign       (sign       ),
                .sub        (sub        )
            );

    imm_gen imm_gen_inst(
                .inst     (inst     ),
                .imm_ctrl (imm_ctrl ),
                .imm      (imm      )
            );

endmodule
