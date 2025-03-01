
`include "defines.v"
module id_ex (
        input  wire         clk         ,
        input  wire         rstn        ,
        // from ctrl
        input  wire         hold_flag_i ,
        // from id_ex
        input  wire [31:0]  inst_i      ,
        input  wire [31:0]  inst_addr_i ,
        input  wire [31:0]  op1_i       ,   // operands 1
        input  wire [31:0]  op2_i       ,   // operands 2
        input  wire [ 4:0]  rd_addr_i   ,   // rd address
        input  wire         reg_wen_i   ,   // reg write enable

        output wire [31:0]  inst_o      ,
        output wire [31:0]  inst_addr_o ,
        output wire [31:0]  op1_o       ,   // operands 1
        output wire [31:0]  op2_o       ,   // operands 2
        output wire [ 4:0]  rd_addr_o   ,   // rd address
        output wire         reg_wen_o       // reg write enable
    );


    DFF #(32) inst_dff      (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(`INST_NOP  ),.d(inst_i       ),.q(inst_o     ));
    DFF #(32) inst_addr_dff (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(32'd0      ),.d(inst_addr_i  ),.q(inst_addr_o));
    DFF #(32) op1_dff       (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(32'd0      ),.d(op1_i        ),.q(op1_o      ));
    DFF #(32) op2_dff       (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(32'd0      ),.d(op2_i        ),.q(op2_o      ));
    DFF #( 5) rd_addr_dff   (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(5'd0       ),.d(rd_addr_i    ),.q(rd_addr_o  ));
    DFF #( 1) reg_wen_dff   (.clk(clk),.rstn(rstn),.hold_flag(hold_flag_i),.set_data(1'b0       ),.d(reg_wen_i    ),.q(reg_wen_o  ));

endmodule
