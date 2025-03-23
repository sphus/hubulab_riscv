
`include "../defines.v"
module control (
        // from if_id
        input  wire [`RegBus]       inst        ,
        // to imm_gen
        output reg  [`sw_imm_bus]   imm_ctrl    ,   // Immediate Control
        // to id_ex
        output wire                 rmem        ,   // memory   read  enable
        output wire                 wmem        ,   // memory   write enable
        output wire                 wen         ,   // register write enable
        output wire                 jmp         ,   // Jump
        output wire                 jcc         ,   // Jump on Condition
        output wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        output wire                 jal         ,   // JAL  Instruction
        output wire                 jalr        ,   // JALR Instruction
        output wire                 lui         ,   // LUI Instruction
        output wire                 auipc       ,   // AUIPC Instruction
        output wire                 inst_R      ,   // INST TYPE R
        output wire [`mem_type_bus] mem_type    ,   // load/store data type
        output wire                 mem_sign    ,   // load/store data sign
        output wire                 sign        ,   // ALU SIGN
        output wire                 sub             // ALU SUB
    );

    // 分线
    wire [6:0] func7   = inst[31:25];
    wire [2:0] func3   = inst[14:12];
    wire [6:0] opcode  = inst[ 6: 0];

    always @( *)
    begin
        case (opcode)
            `INST_TYPE_I,
            `INST_TYPE_L,
            `INST_JALR      :imm_ctrl = `sw_immI ;
            `INST_TYPE_S    :imm_ctrl = `sw_immS ;
            `INST_LUI  ,
            `INST_AUIPC     :imm_ctrl = `sw_immU ;        
            `INST_TYPE_B    :imm_ctrl = `sw_immB ;
            `INST_JAL       :imm_ctrl = `sw_immJ ;
            default:imm_ctrl = `ZeroWord;
        endcase
    end

    // INST signal
    assign jalr = (opcode == `INST_JALR);
    assign jal  = (opcode == `INST_JAL);
    assign lui  = (opcode == `INST_LUI);
    assign inst_R  = (opcode == `INST_TYPE_R_M);
    assign auipc = (opcode == `INST_AUIPC);


    // Jump signal
    assign jcc  = (opcode == `INST_TYPE_B);

    assign jmp  = (opcode == `INST_JAL ||
                   opcode == `INST_JALR);

    // ALU signal
    assign alu_ctrl = func3 & {3{~auipc & ~lui & ~jmp & ~rmem & ~wmem}};
    // assign alu_ctrl = func3 & {3{opcode == `INST_TYPE_I || opcode == `INST_TYPE_R_M}};
    assign sub  = (opcode == `INST_TYPE_R_M) ? func7[5] : `Disable;

    // Shift Left Sign/Zero Extension
    assign sign = func7[5];

    // memory signal
    assign rmem = (opcode == `INST_TYPE_L);
    assign wmem = (opcode == `INST_TYPE_S);
    // memory Sign/Zero Extension
    // memory Byte/Half/Word type
    assign {mem_sign,mem_type} = func3;

    // register write enable
    assign wen  = (opcode == `INST_TYPE_I   ||
                   opcode == `INST_TYPE_R_M ||
                   opcode == `INST_TYPE_L   ||
                   opcode == `INST_JAL      ||
                   opcode == `INST_JALR     ||
                   opcode == `INST_LUI      ||
                   opcode == `INST_AUIPC);

endmodule //control
