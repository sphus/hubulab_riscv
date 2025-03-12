
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
        output reg  [31:0]  base_addr   ,
        output reg  [31:0]  offset_addr ,
        output reg  [31:0]  op1_o       ,   // operands 1
        output reg  [31:0]  op2_o       ,   // operands 2
        output reg  [ 4:0]  rd_addr_o   ,   // rd address
        output reg          reg_wen     ,   // reg write enable
        
        // to mem read
        output reg          mem_ren     ,   // memory read enable
        output reg  [31:0]  mem_raddr       // memory address

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

    assign inst_o       = inst_i;
    assign inst_addr_o  = inst_addr_i;

    always @(*) begin
        case (opcode)
            `INST_TYPE_I: begin
                mem_ren     =  1'd0;
                mem_raddr   = 32'd0;
                base_addr   = 32'd0;
                offset_addr = 32'd0;
                rs1_addr_o  = rs1;
                rs2_addr_o  =  5'd0;
                rd_addr_o   = rd;
                op1_o       = rs1_data_i;
                reg_wen     =  1'b1;
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
                    default: begin
                        op2_o       = 32'd0;
                    end
                endcase
            end

            `INST_TYPE_R_M: begin
                // `INST_ADD_SUB
                // `INST_SLL   
                // `INST_SLT   
                // `INST_SLTU  
                // `INST_XOR   
                // `INST_SR    
                // `INST_OR    
                // `INST_AND
                mem_ren     =  1'd0;    
                mem_raddr   = 32'd0;    
                base_addr   = 32'd0;
                offset_addr = 32'd0;
                rs1_addr_o  = rs1;
                rs2_addr_o  = rs2;
                rd_addr_o   = rd;
                op1_o       = rs1_data_i;
                op2_o       = rs2_data_i;
                reg_wen     = 1'b1;
            end
            `INST_TYPE_B: begin
                // `INST_BNE   
                // `INST_BEQ   
                // `INST_BLT   
                // `INST_BGE   
                // `INST_BLTU  
                // `INST_BGEU 
                mem_ren     =  1'd0;
                mem_raddr   = 32'd0;
                rs1_addr_o  = rs1;
                rs2_addr_o  = rs2;
                rd_addr_o   = 5'd0;
                op1_o       = rs1_data_i;
                op2_o       = rs2_data_i;
                reg_wen     = 1'b0;
                base_addr   = inst_addr_i;
                offset_addr = immB;
            end
            `INST_TYPE_L: begin
                //     `INST_LB 
                //     `INST_LH 
                //     `INST_LW 
                //     `INST_LBU
                //     `INST_LHU
                offset_addr = immI;
                base_addr   = rs1_data_i;
                mem_ren     = 1'd1;
                mem_raddr   = rs1_data_i + immI;
                rs1_addr_o  = rs1;
                rs2_addr_o  = 5'd0;
                rd_addr_o   = rd;
                op1_o       = 32'd0;
                op2_o       = 32'd0;
                reg_wen     = 1'b1;
            end
            `INST_TYPE_S:
            begin
                // `INST_SB
                // `INST_SH
                // `INST_SW
                offset_addr = immS;
                base_addr   = rs1_data_i;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
                rs1_addr_o  = rs1;
                rs2_addr_o  = rs2;
                rd_addr_o   = 5'd0;
                op1_o       = 32'd0;
                op2_o       = rs2_data_i;
                reg_wen     = 1'b0;
            end
            `INST_JAL: begin
                base_addr   = inst_addr_i;
                offset_addr = immJ;
                rs1_addr_o  = 5'b0;
                rs2_addr_o  = 5'b0;
                rd_addr_o   = rd;
                op1_o 	    = inst_addr_i;
                op2_o       = 32'd4;
                reg_wen     = 1'b1;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
            end
            `INST_JALR: begin
                base_addr   = rs1_data_i;
                offset_addr = immI;
                rs1_addr_o  = rs1;
                rs2_addr_o  = 5'b0;
                rd_addr_o   = rd;
                op1_o       = inst_addr_i;
                op2_o 	    = 32'd4;
                reg_wen     = 1'b1;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
            end
            `INST_LUI: begin
                base_addr   = 32'd0;
                offset_addr = 32'd0;
                rs1_addr_o  = 5'd0  ;
                rs2_addr_o  = 5'd0  ;
                rd_addr_o   = rd    ;
                op1_o       = immU  ;
                op2_o       = 32'd0 ;
                reg_wen     = 1'b1  ;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
            end
            `INST_AUIPC: begin
                base_addr   = 32'd0;
                offset_addr = 32'd0;
                rs1_addr_o  = 5'd0  ;
                rs2_addr_o  = 5'd0  ;
                rd_addr_o   = rd    ;
                op1_o       = inst_addr_i;
                op2_o       = immU  ;
                reg_wen     = 1'b1  ;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
            end
            default: begin
                base_addr   = 32'd0;
                offset_addr = 32'd0;
                rs1_addr_o  = 5'd0;
                rs2_addr_o  = 5'd0;
                rd_addr_o   = 5'd0;
                op1_o       = 32'd0;
                op2_o       = 32'd0;
                reg_wen     = 1'b0;
                mem_ren     = 1'd0;
                mem_raddr   = 32'd0;
            end
        endcase
    end

endmodule
