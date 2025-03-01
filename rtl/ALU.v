// ---------------------------------------------------------
// ALU
// analysis logic unit 算术逻辑单元
// 
// 输入:
//      opcode —— 操作码
//      s0     —— 操作数0
//      s1     —— 操作数1
// 输出:
//      o_low  —— 低16位结果
//      o_high —— 高16位结果
//      write_high —— 是否写入高16位
// ---------------------------------------------------------

// ---------------------------------------------------------
// 操作码定义
// ---------------------------------------------------------




`define OP_ADD 3'b000
`define OP_SUB 3'b001
`define OP_MUL 3'b010
`define OP_SH  3'b011
`define OP_XOR 3'b100
`define OP_AND 3'b101
`define OP_OR  3'b110
`define OP_NOT 3'b111


module ALU (
    input  wire         [2 :0]  opcode      ,
    input  wire signed  [15:0]  s0          ,
    input  wire signed  [15:0]  s1          ,
    output reg          [15:0]  o_low       ,
    output reg          [15:0]  o_high      ,
    output reg                  write_high  
);
    wire sub = (opcode == `OP_SUB);
    wire [15:0] addsub_val = s0 + (sub ? ~s1 : s1) + sub;

    wire [31:0] mul = s0 * s1;
    wire [31:0] shift = {16'h0000,s0} << s1;

    always @(*) 
    begin
        case (opcode)
            `OP_ADD: {o_high,o_low,write_high} = {16'd0,addsub_val ,1'b0};
            `OP_SUB: {o_high,o_low,write_high} = {16'd0,addsub_val ,1'b0};
            `OP_MUL: {o_high,o_low,write_high} = {     mul         ,1'b1};
            `OP_SH : {o_high,o_low,write_high} = {     shift       ,1'b1};
            `OP_XOR: {o_high,o_low,write_high} = {16'd0,s0^s1      ,1'b0};
            `OP_AND: {o_high,o_low,write_high} = {16'd0,s0&s1      ,1'b0};
            `OP_OR : {o_high,o_low,write_high} = {16'd0,s0|s1      ,1'b0};
            `OP_NOT: {o_high,o_low,write_high} = {16'd0,~s0        ,1'b0};
        endcase
    end


endmodule