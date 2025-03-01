
`include "defines.v"

module ex (
        // from id_ex
        input  wire [31:0]  inst_i      ,
        input  wire [31:0]  inst_addr_i ,
        input  wire [31:0]  op1       ,   // operands 1
        input  wire [31:0]  op2       ,   // operands 2
        input  wire [4 :0]  rd_addr_i   ,
        input  wire         reg_wen_i   ,   // reg write enable

        // to reg
        output wire [4 :0]  rd_addr_o   ,
        output reg  [31:0]  rd_data_o   ,
        output wire         reg_wen_o   ,   // reg write enable

        // to ctrl
        output reg  [31:0]  jump_addr_o ,
        output reg          jump_en_o   ,
        output reg          hold_flag_o
    );


    



    // 分线
    wire [6 :0] func7   = inst_i[31:25];
    wire [4 :0] rs2     = inst_i[24:20];
    wire [4 :0] rs1     = inst_i[19:15];
    wire [4 :0] func3   = inst_i[14:12];
    wire [4 :0] rd      = inst_i[11: 7];
    wire [6 :0] opcode  = inst_i[ 6: 0];
    // 立即数
    wire [31:0] immI = {{20{inst_i[31]}}, inst_i[31:20]};
    wire [31:0] immU = {inst_i[31:12], 12'b0};
    wire [31:0] immS = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire [31:0] immB = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire [31:0] immJ = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    // 辅助运算信号
    wire [4 :0] shamt   = op2[4:0];
    wire        sub     = func7[5];

    assign rd_addr_o = rd_addr_i;
    assign reg_wen_o = reg_wen_i;

    wire eq = (op1 == op2) ? 1'b1 : 1'b0;
    wire less_signed    = ($signed(op1) < $signed(op2)) ? 1'b1 : 1'b0;
    wire less_unsigned  = (op1 < op2) ? 1'b1 : 1'b0;
    wire great_signed   = ($signed(op1) > $signed(op2)) ? 1'b1 : 1'b0;
    wire great_unsigned = (op1 > op2) ? 1'b1 : 1'b0;




    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                jump_addr_o = 32'd0;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_ADDI : rd_data_o = op2 + op1;
                    `INST_SLTI : rd_data_o = {31'd0,less_signed};
                    `INST_SLTIU: rd_data_o = {31'd0,less_unsigned};
                    `INST_XORI : rd_data_o = op1 ^ op2;
                    `INST_ORI  : rd_data_o = op1 | op2;
                    `INST_ANDI : rd_data_o = op1 & op2;
                    `INST_SLLI : rd_data_o = op1 << shamt;
                    `INST_SRI  : rd_data_o = func7[5] ?
                                            (op1 >>> shamt): 
                                            (op1 >> shamt);
                    default: rd_data_o = 32'd0;                    
                endcase
            end
            `INST_TYPE_R_M: begin
                jump_addr_o = 32'd0;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
                case (func3)
                    `INST_ADD_SUB: begin
                        rd_data_o = op2 + (sub ? ~op1 + sub : op1);
                    end
                    default: begin
                        rd_data_o = 32'd0;
                    end
                endcase
            end
            `INST_TYPE_B: begin
                rd_data_o   = 32'd0;
                case (func3)
                    `INST_BNE: begin
                        jump_addr_o = (inst_addr_i + immB)&{32{~eq}};
                        jump_en_o   = ~eq;
                        hold_flag_o = 1'd0;
                    end
                    `INST_BEQ: begin
                        jump_addr_o = (inst_addr_i + immB)&{32{eq}};
                        jump_en_o   = eq;
                        hold_flag_o = 1'd0;
                    end
                    default: begin
                        jump_addr_o = 32'd0;
                        jump_en_o   = 1'd0;
                        hold_flag_o = 1'd0;
                    end
                endcase
            end
            `INST_JAL: begin
                rd_data_o   = inst_addr_i + 32'd4;
                jump_addr_o = inst_addr_i + op1;
                jump_en_o   = 1'd1;
                hold_flag_o = 1'd0;
            end
            `INST_LUI: begin
                rd_data_o   = op1;
                jump_addr_o = 32'd0;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
            end
            default: begin
                rd_data_o   = 32'd0;
                jump_addr_o = 32'd0;
                jump_en_o   = 1'd0;
                hold_flag_o = 1'd0;
            end
        endcase
    end

endmodule
