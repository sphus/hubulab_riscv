
`define pc_rstn     32'h0
`define ZeroReg     5'h0

`define RstnEnable  1'b0
`define RstnDisable 1'b1
`define Enable      1'b1
`define Disable     1'b0
`define ZeroWord    32'h0

// Bus
`define RegAddrnum  5
`define RegAddrBus  (`RegAddrnum-1):0
`define Regnum      32
`define RegBus      (`Regnum - 1):0
`define DoubleRegBus 63:0

// forward
`define Fwdnum      2
`define FwdBus      (`Fwdnum-1):0
`define Fwd_WB      2'b01
`define Fwd_MEM     2'b10
`define Fwd_NONE    2'b00

// hold
`define Hold_num    2
`define Hold_Bus    (`Hold_num-1):0
// `define Hold_pc     2'b01
// `define Hold_ls     2'b10



// flush
`define Flush_num   2
`define Flush_Bus   (`Flush_num-1):0
`define Flush_id    2'b01
`define Flush_jump  2'b10

// ALU Switch
`define ALU_ctrl_num  3
`define ALU_ctrl_bus  (`ALU_ctrl_num - 1):0
`define INST_ADD    3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111

// Immdiate Switch
`define sw_imm_num  3
`define sw_imm_bus  (`sw_imm_num-1):0
`define sw_immI     3'b000
`define sw_immIu    3'b001
`define sw_immU     3'b010
`define sw_immS     3'b011
`define sw_immB     3'b100
`define sw_immBu    3'b101
`define sw_immJ     3'b110


`define mem_type_num 2
`define mem_type_bus (`mem_type_num-1):0
`define LS_B        2'b00
`define LS_H        2'b01
`define LS_W        2'b10
`define LS_signed   1'b0
`define LS_unsigned 1'b1

// I type inst
`define INST_TYPE_I 7'b0010011
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// L type inst
`define INST_TYPE_L 7'b0000011
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// S type inst
`define INST_TYPE_S 7'b0100011
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// R and M type inst
`define INST_TYPE_R_M 7'b0110011
// R type inst
`define INST_ADD_SUB 3'b000
`define INST_SLL    3'b001
`define INST_SLT    3'b010
`define INST_SLTU   3'b011
`define INST_XOR    3'b100
`define INST_SR     3'b101
`define INST_OR     3'b110
`define INST_AND    3'b111
// M type inst
`define INST_MUL    3'b000
`define INST_MULH   3'b001
`define INST_MULHSU 3'b010
`define INST_MULHU  3'b011
`define INST_DIV    3'b100
`define INST_DIVU   3'b101
`define INST_REM    3'b110
`define INST_REMU   3'b111

// J type inst
`define INST_JAL    7'b1101111
`define INST_JALR   7'b1100111

`define INST_LUI    7'b0110111
`define INST_AUIPC  7'b0010111
`define INST_NOP    32'h00000013
`define INST_NOP_OP 7'b0000001
`define INST_MRET   32'h30200073
`define INST_RET    32'h00008067

`define INST_FENCE  7'b0001111
`define INST_ECALL  32'h73
`define INST_EBREAK 32'h00100073

// J type inst
`define INST_TYPE_B 7'b1100011
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111

// J type inst

// CSR inst
`define INST_CSR    7'b1110011
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111

// CSR reg addr
`define CSR_CYCLE   12'hc00
`define CSR_CYCLEH  12'hc80
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MIE     12'h304
`define CSR_MSTATUS 12'h300
`define CSR_MSCRATCH 12'h340
