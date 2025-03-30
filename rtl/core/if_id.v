`include "defines.v"

module if_id (
    input  wire             clk         ,
    input  wire             rstn        ,
    input  wire             hold_flag_i ,
    input  wire [`RegBus]   inst_i      ,
    input  wire [`RegBus]   addr_i      ,
    output wire [`RegBus]   inst_o      ,
    output wire [`RegBus]   addr_o
);
    reg rom_flag;

    always @(posedge clk) begin
        if(!rstn | hold_flag_i)
            rom_flag <= `Disable;
        else
            rom_flag <= `Enable;
    end

    assign inst_o = rom_flag ? inst_i : `INST_NOP;

    DFF #(32) addr_dff((clk),(rstn),(hold_flag_i),(`ZeroWord),(addr_i),(addr_o));
    
endmodule