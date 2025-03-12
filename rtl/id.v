
`include "defines.v"

module id (
        // from if_id
        input  wire [`RegBus]       inst_i      ,
        input  wire [`RegBus]       inst_addr_i ,

        // from reg
        input  wire [`RegBus]       rs1_data_i  ,
        input  wire [`RegBus]       rs2_data_i  ,

        // to reg
        output reg  [`RegAddrBus]   rs1_addr_o  ,
        output reg  [`RegAddrBus]   rs2_addr_o  ,

        // to id_ex
        output wire [`RegBus]       inst_o      ,
        output wire [`RegBus]       inst_addr_o ,
        output reg  [`RegBus]       base_addr   ,
        output reg  [`RegBus]       offset_addr ,
        output reg  [`RegBus]       op1_o       ,   // operands 1
        output reg  [`RegBus]       op2_o       ,   // operands 2
        output reg  [`RegAddrBus]   rd_addr_o   ,   // rd address
        output reg                  reg_wen     ,   // reg write enable

        // to mem read
        output reg                  mem_ren     ,   // memory read enable
        output reg  [`RegBus]       mem_raddr       // memory address

    );

    // 分线
    wire [6 :0]     func7   = inst_i[31:25];
    wire [4 :0]     rs2     = inst_i[24:20];
    wire [4 :0]     rs1     = inst_i[19:15];
    wire [4 :0]     func3   = inst_i[14:12];
    wire [4 :0]     rd      = inst_i[11: 7];
    wire [6 :0]     opcode  = inst_i[ 6: 0];
    wire [4 :0]     shamt   = inst_i[24:20];
    wire [`RegBus]  immI    = {{20{inst_i[31]}}, inst_i[31:20]};
    wire [`RegBus]  immU    = {inst_i[31:12], 12'b0};
    wire [`RegBus]  immS    = {{20{inst_i[31]}}, inst_i[31:25], inst_i[11:7]};
    wire [`RegBus]  immB    = {{20{inst_i[31]}}, inst_i[7], inst_i[30:25], inst_i[11:8], 1'b0};
    wire [`RegBus]  immJ    = {{12{inst_i[31]}}, inst_i[19:12], inst_i[20], inst_i[30:21], 1'b0};

    assign inst_o       = inst_i;
    assign inst_addr_o  = inst_addr_i;

    always @(*) begin
        base_addr   = `ZeroWord;
        offset_addr = `ZeroWord;
        rs1_addr_o  = `ZeroReg;
        rs2_addr_o  = `ZeroReg;
        rd_addr_o   = `ZeroReg;
        op1_o       = `ZeroWord;
        op2_o       = `ZeroWord;
        reg_wen     = `Disable;
        mem_ren     = `Disable;
        mem_raddr   = `ZeroWord;
        case (opcode)
            `INST_TYPE_I: begin
                rs1_addr_o  = rs1;
                rd_addr_o   = rd;
                op1_o       = rs1_data_i;
                reg_wen     = `Enable;
                case (func3)
                    `INST_ADDI ,
                    `INST_SLTI ,
                    `INST_SLTIU,
                    `INST_XORI ,
                    `INST_ORI  ,
                    `INST_ANDI : begin
                        op2_o       = immI;
                    end
                    `INST_SLLI ,
                    `INST_SRI: begin
                        op2_o       = {{27'd0},shamt};
                    end
                endcase
            end

            `INST_TYPE_R_M: begin
                case (func3)
                    `INST_ADD_SUB,
                    `INST_SLL   ,
                    `INST_SLT   ,
                    `INST_SLTU  ,
                    `INST_XOR   ,
                    `INST_SR    ,
                    `INST_OR    ,
                    `INST_AND: begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = rs2;
                        rd_addr_o   = rd;
                        op1_o       = rs1_data_i;
                        op2_o       = rs2_data_i;
                        reg_wen     = `Enable;
                    end
                endcase
            end
            `INST_TYPE_B: begin
                case (func3)
                    `INST_BNE    ,
                    `INST_BEQ    ,
                    `INST_BLT    ,
                    `INST_BGE    ,
                    `INST_BLTU   ,
                    `INST_BGEU: begin
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = rs2;
                        op1_o       = rs1_data_i;
                        op2_o       = rs2_data_i;
                        base_addr   = inst_addr_i;
                        offset_addr = immB;
                    end
                endcase
            end
            `INST_TYPE_L: begin
                case (func3)
                    `INST_LB ,
                    `INST_LH ,
                    `INST_LW ,
                    `INST_LBU,
                    `INST_LHU: begin
                        offset_addr = immI;
                        base_addr   = rs1_data_i;
                        mem_ren     = `Enable;
                        mem_raddr   = rs1_data_i + immI;
                        rs1_addr_o  = rs1;
                        rd_addr_o   = rd;
                        reg_wen     = `Enable;
                    end
                endcase
            end
            `INST_TYPE_S: begin
                case (func3)
                    `INST_SB,
                    `INST_SH,
                    `INST_SW: begin
                        offset_addr = immS;
                        base_addr   = rs1_data_i;
                        rs1_addr_o  = rs1;
                        rs2_addr_o  = rs2;
                        op2_o       = rs2_data_i;
                    end
                endcase
            end
            `INST_JAL: begin
                base_addr   = inst_addr_i;
                offset_addr = immJ;
                rd_addr_o   = rd;
                op1_o 	    = inst_addr_i;
                op2_o       = 32'd4;
                reg_wen     = `Enable;
            end
            `INST_JALR: begin
                base_addr   = rs1_data_i;
                offset_addr = immI;
                rs1_addr_o  = rs1;
                rd_addr_o   = rd;
                op1_o       = inst_addr_i;
                op2_o 	    = 32'd4;
                reg_wen     = `Enable;
            end
            `INST_LUI: begin
                rd_addr_o   = rd    ;
                op1_o       = immU  ;
                reg_wen     = `Enable;
            end
            `INST_AUIPC: begin
                rd_addr_o   = rd    ;
                op1_o       = inst_addr_i;
                op2_o       = immU  ;
                reg_wen     = `Enable;
            end
        endcase
    end

endmodule
