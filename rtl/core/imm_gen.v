
`include "../defines.v"
module imm_gen (
        input  wire [`RegBus]       inst    ,
        input  wire [`sw_imm_bus]   imm_ctrl,
        output reg  [`RegBus]       imm
    );

    always @(*)
    begin
        case (imm_ctrl)
            `sw_immI : imm = {{20{inst[31]}}, inst[31:20]};
            `sw_immU : imm = {inst[31:12], 12'b0};
            `sw_immS : imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `sw_immB : imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            `sw_immJ : imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default  : imm = `ZeroWord;
        endcase
    end

endmodule //imm_gen
