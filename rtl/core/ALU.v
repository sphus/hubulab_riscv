`include "../defines.v"
module ALU (
        input  wire [`RegBus]       op1         ,   // operands 1
        input  wire [`RegBus]       op2         ,   // operands 2
        input  wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU control
        input  wire                 sub         ,   // sub
        input  wire                 sign        ,   // sign
        output reg  [`RegBus]       result      ,   // result
        output reg                  JC              // Jump Condition
    );

    // signed operand
    wire signed [`RegBus]       op1_s = op1;
    wire signed [`RegBus]       op2_s = op2;

    // ALU result
    wire        [`RegBus]       add_sub_val = op1 + (sub ? ~op2 + sub : op2);
    wire        [`RegBus]       xor_val     = op1 ^ op2;
    wire        [`RegBus]       or_val      = op1 | op2;
    wire        [`RegBus]       and_val     = op1 & op2;
    wire        [`RegAddrBus]   shamt       = op2[4:0];
    wire        [`RegBus]       sll_val     = op1 << shamt;
    wire        [`RegBus]       sr_val      = sign ? (op1_s >>> shamt) : (op1_s >> shamt);

    // JC signal
    wire eq             = (op1 == op2)      ? `Enable : `Disable;
    wire less_signed    = (op1_s < op2_s)   ? `Enable : `Disable;
    wire less_unsigned  = (op1 < op2)       ? `Enable : `Disable;

    always @( *)
    begin
        case (alu_ctrl)
            `INST_ADD : result = add_sub_val;
            `INST_SLL : result = sll_val;
            `INST_SLT : result = less_signed;
            `INST_SLTU: result = less_unsigned;
            `INST_XOR : result = xor_val;
            `INST_SR  : result = sr_val;
            `INST_OR  : result = or_val;
            `INST_AND : result = and_val;
            default:    result = `ZeroWord;
        endcase
    end


    always @( *)
    begin
        case (alu_ctrl)
            `INST_BEQ : JC = eq;
            `INST_BNE : JC = ~eq;
            `INST_BLT : JC = less_signed;
            `INST_BGE : JC = ~less_signed;
            `INST_BLTU: JC = less_unsigned;
            `INST_BGEU: JC = ~less_unsigned;
            default:    JC = `Disable;
        endcase
    end

endmodule //ALU
