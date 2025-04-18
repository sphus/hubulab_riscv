
`define NEW


`include "../defines.v"
module control (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        input  wire                 hold        ,
        input  wire [`RegBus]       inst        ,
        input  wire                 JC          ,
        // to imm_gen
        output wire [`sw_imm_bus]   imm_ctrl    ,   // IMM Control
        output wire [`ALU_sel_bus]  alu_sel     ,   // ALU Select
        output wire [`RegAddrBus]   rs1_addr    ,   // Register 1 Address
        output wire [`RegAddrBus]   rs2_addr    ,   // Register 2 Address
        output wire [`RegAddrBus]   rd_addr     ,   // Register Destination Address
        output wire                 rmem        ,   // Memory   Read  Enable
        output wire                 wmem        ,   // Memory   Write Enable
        output wire                 wen         ,   // Register Write Enable
        output wire                 jmp         ,   // Jump
        output wire                 jcc         ,   // Jump on Condition
        output wire [`ALU_ctrl_bus] alu_ctrl    ,   // ALU Control
        output wire                 jal         ,   // JAL  Instruction
        output wire                 jalr        ,   // JALR Instruction
        output wire                 lui         ,   // LUI Instruction
        output wire                 auipc       ,   // AUIPC Instruction
        output wire                 inst_R      ,   // INST TYPE R
        output wire [`mem_type_bus] mem_type    ,   // Load/Store Data Type
        output wire                 mem_sign    ,   // Load/Store Data Sign
        output wire                 sign        ,   // ALU SIGN
        output wire                 sub         ,   // ALU SUB
        output reg  [`StateBus]     state       ,
        output wire                 jump

    );

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            state <= `IF_STATE;
        else if(hold)
            state <= `IF_STATE;
        else
            state <= {state[`Statenum-2:0],state[`Statenum-1]};
    end

    // 分线
    assign  rs1_addr  = inst[19:15];
    assign  rs2_addr  = inst[24:20];
    assign  rd_addr   = inst[11: 7];

    wire [6:0] func7   = inst[31:25];
    wire [2:0] func3   = inst[14:12];
    wire [6:0] opcode  = inst[ 6: 0];

    // INST signal
    assign jalr     = (opcode == `INST_JALR     );
    assign jal      = (opcode == `INST_JAL      );
    assign lui      = (opcode == `INST_LUI      );
    assign auipc    = (opcode == `INST_AUIPC    );
    assign inst_R   = (opcode == `INST_TYPE_R_M );
    assign inst_I   = (opcode == `INST_TYPE_I   );
    assign rmem     = (opcode == `INST_TYPE_L   );
    assign wmem     = (opcode == `INST_TYPE_S   );
    assign jcc      = (opcode == `INST_TYPE_B   );

    // Jump signal
    assign jmp  = (jal|jalr);

    assign imm_ctrl =
           ({`sw_imm_num{inst_I |rmem|jalr  }}) & `sw_immI |
           ({`sw_imm_num{wmem               }}) & `sw_immS |
           ({`sw_imm_num{lui    |auipc      }}) & `sw_immU |
           ({`sw_imm_num{jcc                }}) & `sw_immB |
           ({`sw_imm_num{jal                }}) & `sw_immJ ;

    wire    cjump   = jcc & JC;
    assign  jump    = jmp | cjump;

    // ALU signal
    assign alu_ctrl = func3 & {`ALU_ctrl_num{inst_I & inst_R & jcc}};
    assign sub      = inst_R& func7[5];

    // Shift Left Sign/Zero Extension
    assign sign = func7[5];

    // memory Sign/Zero Extension
    // memory Byte/Half/Word type
    assign {mem_sign,mem_type} = func3;

    // register write enable
    assign wen  = (inst_I|
                   inst_R|
                   rmem |
                   jal  |
                   jalr |
                   lui  |
                   auipc);

    // 在IF阶段只执行加法
    assign alu_sel_MEM_WB =
           {jal     |jalr   ,
            auipc           ,
            lui             ,
            rmem    |wmem   ,
            inst_R  |jcc    }
           & {`ALU_sel_num{state[`EX]|state[`WB]}};

    // 在IF阶段只执行加法
    assign alu_sel_IF =
           {~jump       ,
            cjump|jal   ,
            `Disable    ,
            jalr        ,
            `Disable}
           & {`ALU_sel_num{state[`IF]}};

endmodule //control
