
`include "../defines.v"
module if_id (
        input  wire             clk     ,
        input  wire             rstn    ,
        input  wire             nop     ,
        input  wire             jump    ,
        input  wire [`RegBus]   inst_i  ,
        input  wire [`RegBus]   addr_i  ,
        output wire [`RegBus]   inst_o  ,
        output wire [`RegBus]   addr_o
    );

    wire hold = nop | jump;
    reg rom_flag;

    // jump或nop都会hold
    always @(posedge clk)
    begin
        if(!rstn | jump)
            rom_flag <= `Disable;
        else
            rom_flag <= `Enable;
    end

    assign inst_o = rom_flag ? inst_i : `INST_NOP;

    DFF #(32) addr_dff(clk,rstn,jump,`ZeroWord,nop ? addr_o : addr_i,addr_o);

endmodule
