
`include "defines.v"
module if_id (
    input  wire         clk         ,
    input  wire         rstn        ,
    input  wire         hold_flag_i ,
    input  wire [31:0]  inst_i      ,
    input  wire [31:0]  addr_i      ,
    output wire [31:0]  inst_o      ,
    output wire [31:0]  addr_o
);
    reg rom_flag;

    always @(posedge clk) begin
        if(!rstn | hold_flag_i)
            rom_flag <= 1'b0;
        else
            rom_flag <= 1'b1;
    end

    assign inst_o = rom_flag ? inst_i : `INST_NOP;

    // DFF #(32) inst_dff(.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(`INST_NOP),.d(inst_i ),.q(inst_o));
    DFF #(32) addr_dff(.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(32'd0    ),.d(addr_i),.q(addr_o));
    
endmodule