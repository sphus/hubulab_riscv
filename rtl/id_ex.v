
`include "defines.v"
module id_ex (
        input  wire         clk         ,
        input  wire         rstn        ,
        // from ctrl
        input  wire         hold_flag_i ,
        // from id_ex
        input  wire [31:0]  inst_i      ,
        input  wire [31:0]  inst_addr_i ,
        input  wire [31:0]  base_addr_i ,
        input  wire [31:0]  offset_addr_i,
        input  wire [31:0]  op1_i       ,   // operands 1
        input  wire [31:0]  op2_i       ,   // operands 2
        input  wire [ 4:0]  rd_addr_i   ,   // rd address
        input  wire         reg_wen_i   ,   // reg write enable

        output wire [31:0]  inst_o      ,
        output wire [31:0]  inst_addr_o ,
        output wire [31:0]  base_addr_o ,
        output wire [31:0]  offset_addr_o,
        output wire [31:0]  op1_o       ,   // operands 1
        output wire [31:0]  op2_o       ,   // operands 2
        output wire [ 4:0]  rd_addr_o   ,   // rd address
        output wire         reg_wen_o       // reg write enable
    );


    DFF #(32) inst_dff          (clk,rstn,hold_flag_i,`INST_NOP ,inst_i         ,inst_o         );
    DFF #(32) inst_addr_dff     (clk,rstn,hold_flag_i,32'd0     ,inst_addr_i    ,inst_addr_o    );
    DFF #(32) base_addr_dff     (clk,rstn,hold_flag_i,32'd0     ,base_addr_i    ,base_addr_o    );
    DFF #(32) offset_addr_dff   (clk,rstn,hold_flag_i,32'd0     ,offset_addr_i  ,offset_addr_o  );
    DFF #(32) op1_dff           (clk,rstn,hold_flag_i,32'd0     ,op1_i          ,op1_o          );
    DFF #(32) op2_dff           (clk,rstn,hold_flag_i,32'd0     ,op2_i          ,op2_o          );
    DFF #( 5) rd_addr_dff       (clk,rstn,hold_flag_i,5'd0      ,rd_addr_i      ,rd_addr_o      );
    DFF #( 1) reg_wen_dff       (clk,rstn,hold_flag_i,1'b0      ,reg_wen_i      ,reg_wen_o      );

endmodule
