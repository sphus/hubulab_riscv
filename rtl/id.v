
`include "defines.v"

module id (
        // from if_id
        input  wire [31:0]  inst_i      ,
        input  wire [31:0]  inst_addr_i ,

        // from reg
        input  wire [31:0]  rs1_data_i  ,
        input  wire [31:0]  rs2_data_i  ,

        // to reg
        output reg  [4:0]   rs1_addr_o  ,
        output reg  [4:0]   rs2_addr_o  ,

        // to id_ex
        output wire [31:0]  inst_o      ,
        output wire [31:0]  inst_addr_o ,
        output reg  [31:0]  op1_o       ,   // operands 1
        output reg  [31:0]  op2_o       ,   // operands 2
        output reg  [ 4:0]  rd_addr_o   ,   // rd address
        output reg          reg_wen         // reg write enable
    );

    // 分线
    wire [6 :0] func7   = inst_i[31:25];
    wire [4 :0] rs2     = inst_i[24:20];
    wire [4 :0] rs1     = inst_i[19:15];
    wire [4 :0] func3   = inst_i[14:12];
    wire [4 :0] rd      = inst_i[11: 7];
    wire [6 :0] opcode  = inst_i[ 6: 0];
    wire [4 :0] shamt   = inst_i[24:20];
    wire [31:0] immI    = {{20{inst_i[31]}}, inst_i[31:20]};
    wire [31:0] immU    = {inst_i[31:12], 12'b0};
    wire [31:0] immS    = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire [31:0] immB    = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire [31:0] immJ    = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};
    // wire [11:0] imm_s   = inst_i[31:20];
    // wire [11:0] imm_b   = inst_i[31:20];
    // wire [11:0] imm_u   = inst_i[31:20];
    // wire [11:0] imm_j   = inst_i[31:20];

    assign inst_o       = inst_i;
    assign inst_addr_o  = inst_addr_i;

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                case (func3)
                    `INST_ADDI ,
                    `INST_SLTI ,
                    `INST_SLTIU,
                    `INST_XORI ,
                    `INST_ORI  ,
                    `INST_ANDI :
                    begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = 5'd0;
                        rd_addr_o   = rd;
                        op1_o       = rs1_data_i;
                        op2_o       = immI;
                        reg_wen     = 1'b1;
                    end
                    `INST_SLLI ,
                    `INST_SRI:
                    begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = 32'd0;
                        rd_addr_o   = rd;
                        op1_o       = rs1_data_i;
                        op2_o       = {{27'd0},shamt};
                        reg_wen     = 1'b1;
                    end
                    default: begin
                        rs1_addr_o  = 5'd0;
                        rs2_addr_o  = 5'd0;
                        rd_addr_o   = 5'd0;
                        op1_o       = 32'd0;
                        op2_o       = 32'd0;
                        reg_wen     = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_R_M: begin
                case (func3)
                    `INST_ADD_SUB: begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = rs2;
                        rd_addr_o   = rd;
                        op1_o       = rs1_data_i;
                        op2_o       = rs2_data_i;
                        reg_wen     = 1'b1;
                    end
                    default: begin
                        rs1_addr_o  = 5'd0;
                        rs2_addr_o  = 5'd0;
                        rd_addr_o   = 5'd0;
                        op1_o       = 32'd0;
                        op2_o       = 32'd0;
                        reg_wen     = 1'b0;
                    end
                endcase
            end
            `INST_TYPE_B: begin
                case (func3)
                    `INST_BNE,`INST_BEQ: begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = rs2;
                        rd_addr_o   = 5'd0;
                        op1_o       = rs1_data_i;
                        op2_o       = rs2_data_i;
                        reg_wen     = 1'b0;
                    end
                    default: begin
                        rs1_addr_o  = 5'd0;
                        rs2_addr_o  = 5'd0;
                        rd_addr_o   = 5'd0;
                        op1_o       = 32'd0;
                        op2_o       = 32'd0;
                        reg_wen     = 1'b0;
                    end
                endcase
            end
            `INST_JAL: begin
                rs1_addr_o = 5'b0;
                rs2_addr_o = 5'b0;
                rd_addr_o  = rd;
                op1_o 	   = immJ;
                op2_o      = 32'b0;
                reg_wen    = 1'b1;
            end
            `INST_LUI: begin
                rs1_addr_o  = 5'd0  ;
                rs2_addr_o  = 5'd0  ;
                rd_addr_o   = rd    ;
                op1_o       = immU  ;
                op2_o       = 32'd0 ;
                reg_wen     = 1'b1  ;
            end
            default: begin
                rs1_addr_o  = 5'd0;
                rs2_addr_o  = 5'd0;
                rd_addr_o   = 5'd0;
                op1_o       = 32'd0;
                op2_o       = 32'd0;
                reg_wen     = 1'b0;
            end
        endcase
    end





endmodule
