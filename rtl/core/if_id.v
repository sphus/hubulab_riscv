`include "defines.v"

module if_id (
    input  wire             clk         ,
    input  wire             rstn        ,
    input  wire             hold_flag_i ,
    input  wire [`RegBus]   inst_i      ,
    input  wire [`RegBus]   addr_i      ,
    output wire [`RegBus]   inst_o      ,
    output wire [`RegBus]   addr_o      ,
    // interupt
    input  wire             debug_irq   ,
    input  wire             timer_irq   ,
    input  wire             swi_irq     ,
    input  wire [3:0]       plic_irq    ,
    output wire [3:0]       irq_out     
);
    reg rom_flag;
    wire [3:0] irq_in;
    wire plic;
    assign plic = (plic_irq != 4'd0) ? 1'b1 : 1'b0;
    
    assign irq_in = {debug_irq,plic,timer_irq,swi_irq};
    always @(posedge clk) begin
        if(!rstn | hold_flag_i)
            rom_flag <= `Disable;
        else
            rom_flag <= `Enable;
    end

    assign inst_o = rom_flag ? inst_i : `INST_NOP;

    DFF #(32) addr_dff((clk),(rstn),(hold_flag_i),(`ZeroWord),(addr_i),(addr_o));
    DFF #(4)  irq_dff((clk),(rstn),(hold_flag_i),(4'd0),(irq_in),(irq_out));
endmodule