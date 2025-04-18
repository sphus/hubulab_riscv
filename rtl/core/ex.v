
`include "../defines.v"
module ex (
        // data
        input  wire [`RegBus]       inst_addr   ,
        input  wire [`RegBus]       rs1_data    ,
        input  wire [`RegBus]       rs2_data    ,
        input  wire [`RegBus]       imm         ,   // immediate
        // control
        input  wire [`ALU_sel_bus]  alu_sel     ,   // ALU Select
        input  wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        input  wire                 sign        ,   // ALU SIGN
        input  wire                 sub         ,   // ALU SUB

        output wire [`RegBus]       result      ,
        output wire                 JC
    );

    // jump_addr
    // wire [`RegBus]  basic_addr   = (jal | jcc) ? inst_addr : rs1_data;
    // wire [`RegBus]  offset_addr  = imm ;
    // assign jump_addr = basic_addr + offset_addr;

    wire [`RegBus] op1 = {`Regnum{alu_sel[0]|alu_sel[1]}}           & rs1_data  |
                        {`Regnum{alu_sel}}                          & `ZeroWord |
                        {`Regnum{alu_sel[3]|alu_sel[4]}}            & inst_addr;

    wire [`RegBus] op2 = {`Regnum{alu_sel}}                         & rs2_data  |
                        {`Regnum{alu_sel[1]|alu_sel[2]|alu_sel[3]}} & imm       |
                        {`Regnum{alu_sel[4]}}                       & 32'd4;


    // wire [`RegBus] op1 = lui ?`ZeroWord :
    //      (jmp|auipc) ? inst_addr : rs1_data;

    // wire [`RegBus] op2 = jmp ? 32'd4 :
    //      (inst_R|jcc) ? rs2_data : imm;

    ALU ALU_inst(
            .op1      (op1      ),
            .op2      (op2      ),
            .alu_ctrl (alu_ctrl ),
            .sub      (sub      ),
            .sign     (sign     ),
            .result   (result   ),
            .JC       (JC       )
        );

endmodule
