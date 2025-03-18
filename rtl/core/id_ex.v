
`include "defines.v"

module id_ex (
        input  wire                 clk         ,
        input  wire                 rstn        ,
        // from ctrl
        input  wire                 hold_flag_i ,
        // from id
        input  wire [`RegBus]       inst_i      ,
        input  wire [`RegBus]       inst_addr_i ,
        input  wire [`RegBus]       base_addr_i ,
        input  wire [`RegBus]       offset_addr_i,
        input  wire [`RegBus]       op1_i       ,   // operands 1
        input  wire [`RegBus]       op2_i       ,   // operands 2
        input  wire [`RegAddrBus]   rd_addr_i   ,   // rd address
        input  wire                 reg_wen_i   ,   // reg write enable
        input  wire [`RegBus]       csr_waddr_i ,   // csr address
        input  wire                 csr_wen_i   ,   // csr write enable

        // to ex
        output wire [`RegBus]       inst_o      ,
        output wire [`RegBus]       inst_addr_o ,
        output wire [`RegBus]       base_addr_o ,
        output wire [`RegBus]       offset_addr_o,
        output wire [`RegBus]       op1_o       ,   // operands 1
        output wire [`RegBus]       op2_o       ,   // operands 2
        output wire [`RegAddrBus]   rd_addr_o   ,   // rd address
        output wire                 reg_wen_o   ,   // reg write enable
        output wire [`RegBus]       csr_waddr_o ,   // csr address
        output wire                 csr_wen_o        // csr write enable
    );

    DFF #(32) inst_dff          (clk,rstn,hold_flag_i,`INST_NOP ,inst_i         ,inst_o         );
    DFF #(32) inst_addr_dff     (clk,rstn,hold_flag_i,`ZeroWord ,inst_addr_i    ,inst_addr_o    );
    DFF #(32) base_addr_dff     (clk,rstn,hold_flag_i,`ZeroWord ,base_addr_i    ,base_addr_o    );
    DFF #(32) offset_addr_dff   (clk,rstn,hold_flag_i,`ZeroWord ,offset_addr_i  ,offset_addr_o  );
    DFF #(32) op1_dff           (clk,rstn,hold_flag_i,`ZeroWord ,op1_i          ,op1_o          );
    DFF #(32) op2_dff           (clk,rstn,hold_flag_i,`ZeroWord ,op2_i          ,op2_o          );
    DFF #( 5) rd_addr_dff       (clk,rstn,hold_flag_i,`ZeroReg  ,rd_addr_i      ,rd_addr_o      );
    DFF #( 1) reg_wen_dff       (clk,rstn,hold_flag_i,`Disable  ,reg_wen_i      ,reg_wen_o      );
    DFF #(32) csr_waddr_dff     (clk,rstn,hold_flag_i,`ZeroWord ,csr_waddr_i    ,csr_waddr_o    );
    DFF #( 1) csr_wen_dff       (clk,rstn,hold_flag_i,`Disable  ,csr_wen_i      ,csr_wen_o      );

endmodule
