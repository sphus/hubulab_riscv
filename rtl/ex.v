
`include "defines.v"

module ex (
        // from id_ex
        input  wire [31:0]  inst_i      ,
        input  wire [31:0]  inst_addr_i ,
        input  wire [31:0]  op1         ,   // operands 1
        input  wire [31:0]  op2         ,   // operands 2
        input  wire [31:0]  base_addr   ,
        input  wire [31:0]  offset_addr ,
        input  wire [4 :0]  rd_addr_i   ,
        input  wire         reg_wen_i   ,   // reg write enable

        // to reg
        output wire [4 :0]  rd_addr_o   ,
        output reg  [31:0]  rd_data_o   ,
        output wire         reg_wen_o   ,   // reg write enable

        // to ctrl
        output wire [31:0]  jump_addr_o ,
        output reg          jump_en_o   ,
        output reg          hold_flag_o
    );

    // 分线
    wire [6 :0] func7   = inst_i[31:25];
    wire [4 :0] rs2     = inst_i[24:20];
    wire [4 :0] rs1     = inst_i[19:15];
    wire [2 :0] func3   = inst_i[14:12];
    wire [4 :0] rd      = inst_i[11: 7];
    wire [6 :0] opcode  = inst_i[ 6: 0];

    // 信号输出
    assign rd_addr_o = rd_addr_i;
    assign reg_wen_o = reg_wen_i;
    
    // 判断信号 
    wire eq = (op1 == op2) ? 1'b1 : 1'b0;
    wire less_signed    = (op1_s < op2_s) ? 1'b1 : 1'b0;
    wire less_unsigned  = (op1 < op2) ? 1'b1 : 1'b0;
    
    // 辅助运算信号
    wire        [4 :0] shamt    = op2[4:0];
    wire        sub             = (opcode == `INST_TYPE_R_M) ? func7[5] : 1'b0;
    wire        sign            = func7[5];
    wire signed [31:0] op1_s    = op1;
    wire signed [31:0] op2_s    = op2;

    // ALU
    assign jump_addr_o = base_addr + offset_addr;
    wire [31:0] add_sub_val = op1 + (sub ? ~op2 + sub : op2);
    wire [31:0] xor_val     = op1 ^ op2;
    wire [31:0] or_val      = op1 | op2;
    wire [31:0] and_val     = op1 & op2;
    wire [31:0] sll_val     = op1 << shamt;
    wire [31:0] sr_val      = sign ?
                            (op1_s >>> shamt):
                            (op1_s >> shamt);

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_ADDI :rd_data_o = add_sub_val;
                    `INST_SLTI :rd_data_o = {31'd0,less_signed};
                    `INST_SLTIU:rd_data_o = {31'd0,less_unsigned};
                    `INST_XORI :rd_data_o = xor_val;
                    `INST_ORI  :rd_data_o = or_val ;
                    `INST_ANDI :rd_data_o = and_val;
                    `INST_SLLI :rd_data_o = sll_val;
                    `INST_SRI  :rd_data_o = sr_val;
                    default:rd_data_o = 32'd0;
                endcase
            end
            `INST_TYPE_R_M: begin
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_ADD_SUB:rd_data_o = add_sub_val;
                    `INST_SLL    :rd_data_o = sll_val;
                    `INST_SLT    :rd_data_o = {31'd0,less_signed};
                    `INST_SLTU   :rd_data_o = {31'd0,less_unsigned};
                    `INST_XOR    :rd_data_o = xor_val;
                    `INST_SR     :rd_data_o = sr_val;
                    `INST_OR     :rd_data_o = or_val ;
                    `INST_AND    :rd_data_o = and_val;
                    default:rd_data_o = 32'd0;      
                endcase
            end
            `INST_TYPE_B: begin
                rd_data_o   = 32'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_BNE   : jump_en_o = ~eq;
                    `INST_BEQ   : jump_en_o = eq;
                    `INST_BLT   : jump_en_o = less_signed;
                    `INST_BGE   : jump_en_o = ~less_signed;
                    `INST_BLTU  : jump_en_o = less_unsigned;
                    `INST_BGEU  : jump_en_o = ~less_unsigned;
                    default     : jump_en_o = 1'd0;
                endcase
            end
            `INST_TYPE_L: begin
                rd_data_o   = 32'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_LB    : jump_en_o = ~eq;
                    `INST_LH    : jump_en_o = eq;
                    `INST_LW    : jump_en_o = less_signed;
                    `INST_LBU   : jump_en_o = ~less_signed;
                    `INST_LHU   : jump_en_o = less_unsigned;
                    `INST_BGEU  : jump_en_o = ~less_unsigned;
                    default     : jump_en_o = 1'd0;
                endcase
            end
            `INST_JAL,`INST_JALR: begin
                rd_data_o   = add_sub_val;
                jump_en_o   = 1'd1;
                hold_flag_o = 1'd0;
            end
            `INST_LUI,`INST_AUIPC: begin
                rd_data_o   = add_sub_val;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
            end
            default: begin
                rd_data_o   = 32'd0;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
            end
        endcase
    end

endmodule
