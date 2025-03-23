
`include "../defines.v"
module ex (
        // input  wire [`RegBus]       csr_addr_i  ,   // csr address
        // input  wire                 csr_wen_i   ,   // csr write enable


        // // to csr
        // output wire [`RegBus]       csr_addr_o  ,
        // output reg  [`RegBus]       csr_wr_data ,
        // output wire                 csr_wen_o   ,

        // data
        input  wire [`RegBus]       EX_inst_addr    ,
        input  wire [`RegBus]       EX_rs1_data     ,
        input  wire [`RegBus]       EX_rs2_data     ,
        input  wire [`RegBus]       MEM_rd_data     ,
        input  wire [`RegBus]       WB_rd_data      ,
        input  wire [`FwdBus]       fwd_rs1         ,
        input  wire [`FwdBus]       fwd_rs2         ,
        // control
        input  wire                 EX_rmem         ,    // memory   read  enable
        input  wire                 EX_wmem         ,    // memory   write enable
        // input  wire                 EX_wen       ,    // register write enable
        input  wire                 EX_jmp          ,    // Jump
        input  wire                 EX_jcc          ,    // Jump on Condition
        input  wire [`ALU_ctrl_bus] EX_alu_ctrl     ,    // ALU Control
        input  wire                 EX_jal          ,    // JAL  Instruction
        input  wire                 EX_jalr         ,    // JALR Instruction
        input  wire                 EX_lui          ,    // LUI Instruction
        input  wire                 EX_auipc        ,    // AUIPC Instruction
        input  wire                 EX_inst_R       ,    // INST TYPE R

        // input  wire [`mem_type_bus] EX_mem_type  ,    // load/store data type
        // input  wire                 EX_mem_sign  ,    // load/store data sign
        input  wire                 EX_sign         ,    // ALU SIGN
        input  wire                 EX_sub          ,    // ALU SUB
        input  wire [`RegBus]       EX_imm          ,    // immediate

        output wire [`RegBus]       EX_jump_addr    ,
        output wire [`RegBus]       EX_result       ,
        output reg  [`RegBus]       EX_FD_rs2_data  ,
        output wire                 EX_jump
    );

    // Forward data mux
    reg  [`RegBus] EX_FD_rs1_data;

    always @( *)
    begin
        case (fwd_rs1)
            `Fwd_WB  :
                EX_FD_rs1_data = WB_rd_data;
            `Fwd_MEM :
                EX_FD_rs1_data = MEM_rd_data;
            `Fwd_NONE:
                EX_FD_rs1_data = EX_rs1_data;
            default:
                EX_FD_rs1_data = `ZeroWord;
        endcase
    end

    always @( *)
    begin
        case (fwd_rs2)
            `Fwd_WB  :
                EX_FD_rs2_data = WB_rd_data;
            `Fwd_MEM :
                EX_FD_rs2_data = MEM_rd_data;
            `Fwd_NONE:
                EX_FD_rs2_data = EX_rs2_data;
            default:
                EX_FD_rs2_data = `ZeroWord;
        endcase
    end

    // jump_addr
    wire [`RegBus]  basic_addr   = (EX_jal | EX_jcc) ? EX_inst_addr : EX_FD_rs1_data;
    wire [`RegBus]  offset_addr  = EX_imm;
    assign EX_jump_addr = basic_addr + offset_addr;

    // ALU
    wire mem    = EX_rmem | EX_wmem;

    wire [`RegBus] op1 = EX_lui ?`ZeroWord :
         (EX_jmp|EX_auipc) ? EX_inst_addr : EX_FD_rs1_data;

    wire [`RegBus] op2 = EX_jmp ? 32'd4 :
         (EX_inst_R|EX_jcc) ? EX_FD_rs2_data : EX_imm;

    wire EX_JC;

    ALU ALU_inst(
            .op1      (op1          ),
            .op2      (op2          ),
            .alu_ctrl (EX_alu_ctrl  ),
            .sub      (EX_sub       ),
            .sign     (EX_sign      ),
            .result   (EX_result    ),
            .JC       (EX_JC        )
        );

    assign EX_jump = EX_jmp | (EX_jcc & EX_JC);

endmodule
