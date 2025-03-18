
`include "defines.v"

module ex (
        // from id_ex
        input  wire [`RegBus]       inst_i      ,
        input  wire [`RegBus]       inst_addr_i ,
        input  wire [`RegBus]       op1         ,   // operands 1
        input  wire [`RegBus]       op2         ,   // operands 2
        input  wire [`RegBus]       base_addr   ,
        input  wire [`RegBus]       offset_addr ,
        input  wire [`RegAddrBus]   rd_addr_i   ,
        input  wire                 reg_wen_i   ,   // reg write enable
        input  wire [`RegBus]       csr_addr_i  ,   // csr address
        input  wire                 csr_wen_i   ,   // csr write enable

        // to reg
        output wire [`RegAddrBus]   rd_addr_o   ,
        output reg  [`RegBus]       rd_data_o   ,
        output wire                 reg_wen_o   ,   // reg write enable

        // to csr                        
        output wire [`RegBus]       csr_addr_o  ,
        output reg  [`RegBus]       csr_wr_data ,
        output wire                 csr_wen_o   ,   

        // to ctrl
        output wire [`RegBus]       jump_addr_o ,
        output reg                  jump_en_o   ,
        output reg                  hold_flag_o ,

        // from mem
        input  wire [`RegBus]       mem_rd_data ,

        // to mem
        output reg  [`RegBus]       mem_wr_addr ,
        output reg  [`RegBus]       mem_wr_data ,
        output reg  [ 3:0]          mem_wen     
                        
    );

    // 分线
    wire [6:0] func7   = inst_i[31:25];
    wire [4:0] rs2     = inst_i[24:20];
    wire [4:0] rs1     = inst_i[19:15];
    wire [2:0] func3   = inst_i[14:12];
    wire [4:0] rd      = inst_i[11: 7];
    wire [6:0] opcode  = inst_i[ 6: 0];

    // 信号输出
    assign rd_addr_o  = rd_addr_i;
    assign reg_wen_o  = reg_wen_i;
    assign csr_addr_o = csr_addr_i;
    assign csr_wen_o  = csr_wen_i;

    // 辅助运算信号
    wire    [4:0]   shamt   = op2[4:0];
    // 减法标志
    wire            sub     = (opcode == `INST_TYPE_R_M) ? func7[5] : `Disable;
    // 算术右移标志
    wire            sign    = func7[5];
    wire signed [`RegBus]   op1_s   = op1;
    wire signed [`RegBus]   op2_s   = op2;

    // 判断信号
    wire eq             = (op1 == op2)      ? `Enable : `Disable;
    wire less_signed    = (op1_s < op2_s)   ? `Enable : `Disable;
    wire less_unsigned  = (op1 < op2)       ? `Enable : `Disable;

    // ALU
    assign jump_addr_o = base_addr + offset_addr;

    wire [`RegBus] add_sub_val = op1 + (sub ? ~op2 + sub : op2);
    wire [`RegBus] xor_val     = op1 ^ op2;
    wire [`RegBus] or_val      = op1 | op2;
    wire [`RegBus] and_val     = op1 & op2;
    wire [`RegBus] sll_val     = op1 << shamt;
    wire [`RegBus] sr_val      = sign ? (op1_s >>> shamt) : (op1_s >> shamt);

    wire [ 1:0] store_index =  jump_addr_o[1:0];
    wire [ 1:0] load_index  =  jump_addr_o[1:0];

    always @(*) begin
        mem_wr_addr = `ZeroWord;
        mem_wr_data = `ZeroWord;
        mem_wen     = 4'b0000;
        csr_wr_data = `ZeroWord;
        rd_data_o   = `ZeroWord;
        jump_en_o   = `Disable;
        hold_flag_o = `Disable;
        case (opcode)
            `INST_TYPE_I: begin     //
                case (func3)
                    `INST_ADDI  :rd_data_o = add_sub_val;
                    `INST_SLTI  :rd_data_o = {31'd0,less_signed};
                    `INST_SLTIU :rd_data_o = {31'd0,less_unsigned};
                    `INST_XORI  :rd_data_o = xor_val;
                    `INST_ORI   :rd_data_o = or_val ;
                    `INST_ANDI  :rd_data_o = and_val;
                    `INST_SLLI  :rd_data_o = sll_val;
                    `INST_SRI   :rd_data_o = sr_val;
                    default     :rd_data_o = `ZeroWord;
                endcase
            end
            `INST_TYPE_R_M: begin
                case (func3)
                    `INST_ADD_SUB   :rd_data_o = add_sub_val;
                    `INST_SLL       :rd_data_o = sll_val;
                    `INST_SLT       :rd_data_o = {31'd0,less_signed};
                    `INST_SLTU      :rd_data_o = {31'd0,less_unsigned};
                    `INST_XOR       :rd_data_o = xor_val;
                    `INST_SR        :rd_data_o = sr_val;
                    `INST_OR        :rd_data_o = or_val ;
                    `INST_AND       :rd_data_o = and_val;
                    default         :rd_data_o = `ZeroWord;
                endcase
            end
            `INST_TYPE_B: begin
                case (func3)
                    `INST_BNE   :jump_en_o = ~eq;
                    `INST_BEQ   :jump_en_o = eq;
                    `INST_BLT   :jump_en_o = less_signed;
                    `INST_BGE   :jump_en_o = ~less_signed;
                    `INST_BLTU  :jump_en_o = less_unsigned;
                    `INST_BGEU  :jump_en_o = ~less_unsigned;
                    default     :jump_en_o = `Disable;
                endcase
            end
            `INST_TYPE_L: begin
                case (func3)
                    `INST_LB    :begin                        
                        case (load_index)
                            2'd0:rd_data_o = {{24{mem_rd_data[ 7]}},mem_rd_data[ 7: 0]};
                            2'd1:rd_data_o = {{24{mem_rd_data[15]}},mem_rd_data[15: 8]};
                            2'd2:rd_data_o = {{24{mem_rd_data[23]}},mem_rd_data[23:16]};
                            2'd3:rd_data_o = {{24{mem_rd_data[31]}},mem_rd_data[31:24]};
                            default:rd_data_o = `ZeroWord;
                        endcase
                    end
                    `INST_LH    :begin                        
                        case (load_index[1])
                            1'b0:rd_data_o = {{16{mem_rd_data[15]}},mem_rd_data[15: 0]};
                            1'b1:rd_data_o = {{16{mem_rd_data[31]}},mem_rd_data[31:16]};
                            default:rd_data_o = `ZeroWord;
                        endcase
                    end
                    `INST_LW    :
                        rd_data_o = mem_rd_data;
                    `INST_LBU   :begin                        
                        case (load_index)
                            2'd0:rd_data_o = {{24'd0},mem_rd_data[ 7: 0]};
                            2'd1:rd_data_o = {{24'd0},mem_rd_data[15: 8]};
                            2'd2:rd_data_o = {{24'd0},mem_rd_data[23:16]};
                            2'd3:rd_data_o = {{24'd0},mem_rd_data[31:24]};
                            default:rd_data_o = `ZeroWord;
                        endcase
                    end
                    `INST_LHU   :begin                        
                        case (load_index[1])
                            1'b0:rd_data_o = {{16'd0},mem_rd_data[15: 0]};
                            1'b1:rd_data_o = {{16'd0},mem_rd_data[31:16]};
                            default:rd_data_o = `ZeroWord;
                        endcase
                    end
                    default     :
                        rd_data_o = `ZeroWord;
                endcase
            end
            `INST_TYPE_S :  begin
                mem_wr_addr = jump_addr_o;
                case (func3)
                    `INST_SB : begin
                        case (store_index)
                            2'd0: begin
                                mem_wr_data = {24'b0,op2[7:0]};
                                mem_wen = 4'b0001;
                            end
                            2'd1: begin
                                mem_wr_data = {16'b0,op2[7:0],8'b0};
                                mem_wen = 4'b0010;
                            end
                            2'd2: begin
                                mem_wr_data = {8'b0,op2[7:0],16'b0};
                                mem_wen = 4'b0100;
                            end
                            2'd3: begin
                                mem_wr_data = {op2[7:0],24'b0};
                                mem_wen = 4'b1000;
                            end
                            default: begin
                                mem_wr_data = `ZeroWord;
                                mem_wen = 4'b0000;
                            end
                        endcase
                    end
                    `INST_SH : begin
                        case (store_index[1])
                            1'b0: begin
                                mem_wr_data = {16'b0,op2[15: 0]};
                                mem_wen = 4'b0011;
                            end
                            1'b1: begin
                                mem_wr_data = {op2[15: 0],16'b0};
                                mem_wen = 4'b1100;
                            end
                            default: begin
                                mem_wr_data = `ZeroWord;
                                mem_wen = 4'b0000;
                            end
                        endcase
                    end
                    `INST_SW : begin
                        mem_wen = 4'b1111;
                        mem_wr_data = op2;
                    end
                    default: begin
                        mem_wen = 4'b0000;
                        mem_wr_data = `ZeroWord;
                    end
                endcase
            end
            `INST_CSR: begin
                case(func3)
                    `INST_CSRRW,
                    `INST_CSRRWI: begin
                        rd_data_o = op2;
                        csr_wr_data = op1;
                    end
                    `INST_CSRRS,
                    `INST_CSRRSI: begin
                        rd_data_o = op2;
                        csr_wr_data = or_val;
                    end
                    `INST_CSRRC,
                    `INST_CSRRCI: begin
                        rd_data_o = op2;
                        csr_wr_data = ~op1 & op2;
                    end
                    default: begin
                        rd_data_o = `ZeroWord;
                        csr_wr_data = `ZeroWord;
                    end                
                endcase
            end
            `INST_JAL,`INST_JALR: begin
                rd_data_o   = add_sub_val;
                jump_en_o   = `Enable;
            end
            `INST_LUI,`INST_AUIPC: begin
                rd_data_o   = add_sub_val;
            end
            default: begin
                mem_wr_addr = `ZeroWord;
                mem_wr_data = `ZeroWord;
                mem_wen     = `ZeroReg;
                rd_data_o   = `ZeroWord;
                jump_en_o   = `Disable;
                hold_flag_o = `Disable;
            end
        endcase
    end

endmodule
