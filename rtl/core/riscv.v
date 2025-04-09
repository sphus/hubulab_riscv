`include "defines.v" 

module riscv(
        input   wire                clk          ,
        input   wire                rstn         ,
        // register     
        input   wire                reg_wen      ,
        input   wire [`RegAddrBus]  reg_addr     ,
        input   wire [`RegBus]      reg_w_data   ,
        output  wire [`RegBus]      reg_r_data   ,
        // rom
        input   wire [`RegBus]      inst_rom     ,
        output  wire [`RegBus]      inst_addr_rom,
        // jtag 
        input   wire                jtag_halt    , // ctrl
        input   wire                jtag_reset   , // pc
        input   wire                debug_irq    , 
        input   wire                timer_irq    , 
        input   wire                swi_irq      , 
        input   wire  [3:0]         plic_irq      
    );

    // if_id to id
    wire [`RegBus]      inst_if_id;
    wire [`RegBus]      inst_addr_if_id;

    // id to register
    wire [`RegAddrBus]  rs1_addr;
    wire [`RegAddrBus]  rs2_addr;

    // register to id
    wire [`RegBus]      rs1_data;
    wire [`RegBus]      rs2_data;

    // id to csr_register
    wire [`RegBus]      csr_raddr_id;

    // csr_register to id
    wire [`RegBus]      csr_rdata_id;


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

    // csr to commit
    wire commit_wen_i;
    wire [`RegBus] commit_wdata_i;
    wire [`RegBus] commit_waddr_i;
    wire [`RegBus] commit_raddr_i;
    reg  [`RegBus] commit_rdata_o;
    wire [`RegBus] csr_mtvec;
    wire [`RegBus] csr_mepc;
    wire [`RegBus] csr_mstatus;
    wire global_int_en_o;

    // commit to ctrl
    wire commit_halt;

    // commit to ex
    wire [`InstAddrBus] int_addr;  
    wire int_assert;
    wire [3:0] irq_out;
    wire [4:0] int_type;

    pc pc_inst(
           .clk         (clk            ),
           .rstn        (rstn           ),
           .jump_en     (jump_en_ctrl   ),
           .jump_addr   (jump_addr_ctrl ),
           .jtag_reset  (jtag_reset    ),
           .halt        (hold_flag_ctrl),
           .pc          (inst_addr_rom  )
        );

    if_id if_id_inst (
              .clk          (clk            ),
              .rstn         (rstn           ),
              .inst_i       (inst_rom       ),
              .hold_flag_i  (hold_flag_ctrl ),
              .addr_i       (inst_addr_rom  ),
              .inst_o       (inst_if_id     ),
              .addr_o       (inst_addr_if_id),
              .debug_irq    (debug_irq      ),
              .timer_irq    (timer_irq      ),
              .swi_irq      (swi_irq        ),
              .plic_irq     (plic_irq       ),
              .irq_out      (irq_out        )
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
           .csr_data_i  (csr_rdata_id   ),
           .csr_raddr_o (csr_raddr_id   )
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
                 .rs2_rdata   (rs2_data     ),
                 // jtag
                 .jtag_wen    (reg_wen      ),
                 .jtag_addr   (reg_addr     ),
                 .jtag_wdata  (reg_w_data   ),
                 .jtag_rdata  (reg_r_data   )
            );

    csr_reg  #(
                .NUM   (5),
                .ECALL (32'h000002c4),
                .EBREAK(32'h000002c4),
                .TIMER (32'h000002C0),
                .DEBUG (32'h000002C0),
                .SWI   (32'h000002C0),
                .PLIC  (32'h000002C0)                
            )
    csr_reg_inst (
                .clk                (clk             ),
                .rstn               (rstn            ),
                .ex_waddr_i         (csr_addr_ex     ),
                .ex_wdata_i         (csr_data_ex     ),
                .ex_wen_i           (csr_wen_ex      ),
                .id_raddr_i         (csr_raddr_id    ),
                .id_rdata_o         (csr_rdata_id    ),
                .commit_waddr_i     (commit_waddr_i  ),
                .commit_wdata_i     (commit_wdata_i  ),
                .commit_wen_i       (commit_wen_i    ),
                .commit_raddr_i     (commit_raddr_i  ),
                .commit_rdata_o     (  ),
                .int_type           (int_type        ),
                .csr_mtvec          (csr_mtvec       ),
                .csr_mepc           (csr_mepc        ),
                .csr_mstatus        (csr_mstatus     ),
                .global_int_en_o    (global_int_en_o ) 
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
           .csr_wen_o   (csr_wen_ex     ),
           .int_addr    (int_addr       ),
           .int_assert  (int_assert     )
       );

    ram #(
            .DW      	(32    ),
            .AW      	(32    ),
            .MEM_NUM 	(2**12))
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
             .jtag_halt     (jtag_halt      ),
             .commmit_halt  (commit_halt    ),
             .jump_addr_o 	(jump_addr_ctrl ),
             .jump_en_o   	(jump_en_ctrl   ),
             .hold_flag_o 	(hold_flag_ctrl )
         );
    
    commit commit_init(
            .clk                (clk              ),
            .rstn               (rstn             ),
            .irq_i              (irq_out          ),
            // from id
            .inst_i             (inst_if_id       ),
            .inst_addr_i        (inst_addr_if_id  ),
            // from ex
            .jump_flag_i        (jump_en_ex       ),
            .jump_addr_i        (jump_addr_ex     ),
            // from csr
            .csr_mtvec          (csr_mtvec        ),
            .csr_mepc           (csr_mepc         ),
            .csr_mstatus        (csr_mstatus      ),
            .global_int_en_i    (global_int_en_o  ),
            // to ctrl
            .hold_flag_o        (commit_halt      ),
            // to csr
            .we_o               (commit_wen_i     ),
            .waddr_o            (commit_waddr_i   ),
            .raddr_o            (commit_raddr_i   ),
            .data_o             (commit_wdata_i   ),
            .int_type           (int_type         ),
            // to ex
            // 做为jump_addr
            .int_addr_o         (int_addr         ),
            .int_assert_o       (int_assert       ) 
    );

endmodule

