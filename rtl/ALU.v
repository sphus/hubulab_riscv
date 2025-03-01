// ---------------------------------------------------------
// ALU
// analysis logic unit 算术逻辑单元
// 
// 输入:
//      opcode —— 操作码
//      op1     —— 操作数0
//      op2     —— 操作数1
// 输出:
//      o_low  —— 低16位结果
//      o_high —— 高16位结果
//      write_high —— 是否写入高16位
// ---------------------------------------------------------

// ---------------------------------------------------------
// 操作码定义
// ---------------------------------------------------------




`define INST_ADD_SUB 3'b000
`define INST_SLL     3'b001
`define INST_SLT     3'b010
`define INST_SLTU    3'b011
`define INST_XOR     3'b100
`define INST_SR      3'b101
`define INST_OR      3'b110
`define INST_AND     3'b111


module ALU (
    input  wire [31:0]  op1     ,
    input  wire [31:0]  op2     ,
    input  wire [2 :0]  fun3    ,
    input  wire         aux     ,

    output reg  [31:0]  result  
);
    wire sub    = aux;
    wire sign   = aux;
    wire [31:0] addsub_val = op2 + (sub ? ~op1 + sub : op1);

    // always @(*) 
    // begin
    //     case (opcode)
    //         `INST_ADD_SUB: result = addsub_val;
    //         `INST_SLL    : result = ;
    //         `INST_SLT    : result = ;
    //         `INST_SLTU   : result = ;
    //         `INST_XOR    : result = ;
    //         `INST_SR     : result = ;
    //         `INST_OR     : result = ;
    //         `INST_AND    : result = ;
    //     endcase
    // end

    // op2 + op1;
    // {31'd0,less_signed};
    // {31'd0,less_unsigned};
    // op1 ^ op2;
    // op1 | op2;
    // op1 & op2;
    // op1 << shamt;
    // sign ?
    // (op1 >>> shamt): 
    // (op1 >> shamt);

endmodule