`include "defines.v" 

module riscv(
        input   wire            clk         ,
        input   wire            rstn        ,
        input   wire [`RegBus]  inst_rom    ,
        output  wire [`RegBus]  inst_addr_rom
    );
    // if_id to id
    wire [`RegBus]      inst_if_id;
    wire [`RegBus]      inst_addr_if_id;

    // id to register
    wire [`RegAddrBus]  rs1_addr;
    wire [`RegAddrBus]  rs2_addr;

    // id to csr_register
    wire [`RegBus]      csr_addr;

    // register to id
    wire [`RegBus]      rs1_data;
    wire [`RegBus]      rs2_data;

    // csr_register to id
    wire [`RegBus]      csr_data;

    // id to id_ex
    wire [`RegBus]      inst_id;
    wire [`RegBus]      inst_addr_id;
    wire [`RegAddrBus]  rd_addr_id;
    wire [`RegBus]      base_addr_id;
    wire [`RegBus]      offset_addr_id;
    wire [`RegBus]      op1_id;
    wire [`RegBus]      op2_id;
    wire                wen_id;
    wire [`RegBus]      csr_addr_id;
    wire                csr_wen_id;    

    // id to ram
    wire 		        ram_ren;
    wire [`RegBus]	    ram_r_addr;

    // id_ex to ex
    wire [`RegBus]      inst_id_ex;
    wire [`RegBus]      inst_addr_id_ex;
    wire [`RegAddrBus]  rd_addr_id_ex;
    wire [`RegBus]      base_addr_ex;
    wire [`RegBus]      offset_addr_ex;
    wire [`RegBus]      op1_id_ex;
    wire [`RegBus]      op2_id_ex;
    wire                wen_id_ex;
    wire [`RegBus]      csr_addr_id_ex;
    wire                csr_wen_id_ex; 

    // ram to ex
    wire [`RegBus]      ram_r_data;

    // ex to ram
    wire [3:0]		    ram_wen;
    wire [`RegBus]	    ram_w_addr;
    wire [`RegBus]      ram_w_data;

    // ex to register
    wire [`RegAddrBus]  rd_addr_ex;
    wire [`RegBus]      rd_data_ex;
    wire                en_ex;

    // ex to csr_register
    wire [`RegBus]      csr_addr_ex;
    wire [`RegBus]      csr_data_ex;
    wire                csr_wen_ex;

    // ex to ctrl
    wire  [`RegBus]     jump_addr_ex;
    wire                jump_en_ex;
    wire                hold_flag_ex;

    // ctrl to pc
    wire                jump_en_ctrl;
    wire [`RegBus]      jump_addr_ctrl;

    // ctrl to if_id,id_ex
    wire                hold_flag_ctrl;

    pc pc_inst(
           .clk         (clk            ),
           .rstn        (rstn           ),
           .jump_en     (jump_en_ctrl   ),
           .jump_addr   (jump_addr_ctrl ),
           .pc          (inst_addr_rom  )
       );

    if_id if_id_inst (
              .clk          (clk            ),
              .rstn         (rstn           ),
              .inst_i       (inst_rom       ),
              .hold_flag_i  (hold_flag_ctrl ),
              .addr_i       (inst_addr_rom  ),
              .inst_o       (inst_if_id     ),
              .addr_o       (inst_addr_if_id)
          );

    id id_inst(
           .inst_i      (inst_if_id     ),
           .inst_addr_i (inst_addr_if_id),
           .rs1_data_i  (rs1_data       ),
           .rs2_data_i  (rs2_data       ),
           .rs1_addr_o  (rs1_addr       ),
           .rs2_addr_o  (rs2_addr       ),
           .inst_o      (inst_id        ),
           .inst_addr_o (inst_addr_id   ),
           .base_addr   (base_addr_id   ),
           .offset_addr (offset_addr_id ),
           .op1_o       (op1_id         ),  // operands 1
           .op2_o       (op2_id         ),  // operands 2
           .rd_addr_o   (rd_addr_id     ),  // rd address
           .reg_wen     (wen_id         ),  // reg write enable
           .mem_ren     (ram_ren        ),  // memory read enable
           .mem_raddr   (ram_r_addr     ),  // memory address
           .csr_waddr_o (csr_addr_id    ),
           .csr_wen     (csr_wen_id     ),
           .csr_data_i  (csr_data       ),
           .csr_raddr_o (csr_addr       )
       );

    register register_inst(
                 .clk         (clk          ),
                 .rstn        (rstn         ),
                 .rs1_raddr   (rs1_addr     ),
                 .rs2_raddr   (rs2_addr     ),
                 .rd_waddr    (rd_addr_ex   ),
                 .rd_wdata    (rd_data_ex   ),
                 .wen         (wen_ex       ),
                 .rs1_rdata   (rs1_data     ),
                 .rs2_rdata   (rs2_data     )
             );

    csr_reg csr_reg_inst(
                 .clk           (clk          ),
                 .rstn          (rstn         ),
                 .csr_waddr_i   (csr_addr_ex  ),
                 .csr_wdata_i   (csr_data_ex  ),
                 .csr_wen_i     (csr_wen_ex  ),
                 .csr_raddr_i   (csr_addr     ),
                 .csr_rdata_o   (csr_data     )
             );

    id_ex id_ex_inst(
              .clk          (clk            ),
              .rstn         (rstn           ),
              .hold_flag_i  (hold_flag_ctrl ),
              .inst_i       (inst_id        ),
              .inst_addr_i  (inst_addr_id   ),
              .base_addr_i  (base_addr_id   ),
              .offset_addr_i(offset_addr_id ),
              .op1_i        (op1_id         ),   // operands 1
              .op2_i        (op2_id         ),   // operands 2
              .rd_addr_i    (rd_addr_id     ),   // rd address
              .reg_wen_i    (wen_id         ),   // reg write enable
              .inst_o       (inst_id_ex     ),
              .inst_addr_o  (inst_addr_id_ex),
              .base_addr_o  (base_addr_ex   ),
              .offset_addr_o(offset_addr_ex ),
              .op1_o        (op1_id_ex      ),   // operands 1
              .op2_o        (op2_id_ex      ),   // operands 2
              .rd_addr_o    (rd_addr_id_ex  ),   // rd address
              .reg_wen_o    (wen_id_ex      ),    // reg write enable
              .csr_waddr_i  (csr_addr_id    ),
              .csr_waddr_o  (csr_addr_id_ex ),
              .csr_wen_i    (csr_wen_id     ),
              .csr_wen_o    (csr_wen_id_ex  )          
              );

    ex ex_inst(
           .inst_i      (inst_id_ex     ),
           .inst_addr_i (inst_addr_id_ex),
           .op1         (op1_id_ex      ),   // operands 1
           .op2         (op2_id_ex      ),   // operands 2
           .base_addr   (base_addr_ex   ),
           .offset_addr (offset_addr_ex ),
           .rd_addr_i   (rd_addr_id_ex  ),
           .reg_wen_i   (wen_id_ex      ),   // reg write enable
           .rd_addr_o   (rd_addr_ex     ),
           .rd_data_o   (rd_data_ex     ),
           .reg_wen_o   (wen_ex         ),  // reg write enable
           .jump_addr_o (jump_addr_ex   ),
           .jump_en_o   (jump_en_ex     ),
           .hold_flag_o (hold_flag_ex   ),
           .mem_rd_data (ram_r_data     ),
           .mem_wr_addr (ram_w_addr     ),
           .mem_wr_data (ram_w_data     ),
           .mem_wen     (ram_wen ),
           .csr_addr_i  (csr_addr_id_ex ),
           .csr_wen_i   (csr_wen_id_ex  ),
           .csr_addr_o  (csr_addr_ex    ),
           .csr_wr_data (csr_data_ex    ),
           .csr_wen_o   (csr_wen_ex     )
       );

    ram #(
            .DW      	(32    ),
            .AW      	(32    ),
            .MEM_NUM 	(2**20))
        ram_inst(
            .clk    	(clk         ),
            .rstn   	(rstn        ),
            .wen    	(ram_wen     ),
            .w_addr 	(ram_w_addr  ),
            .w_data 	(ram_w_data  ),
            .ren    	(ram_ren     ),
            .r_addr 	(ram_r_addr  ),
            .r_data 	(ram_r_data  )
        );


    ctrl ctrl_inst(
             .jump_addr_i 	(jump_addr_ex   ),
             .jump_en_i   	(jump_en_ex     ),
             .hold_flag_i 	(hold_flag_ex   ),
             .jump_addr_o 	(jump_addr_ctrl ),
             .jump_en_o   	(jump_en_ctrl   ),
             .hold_flag_o 	(hold_flag_ctrl )
         );


endmodule

