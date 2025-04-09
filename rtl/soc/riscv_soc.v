module riscv_soc (
        input  wire clk ,
        input  wire rstn,
        
        // jtag
        input  wire jtag_TCK,     // JTAG TCK引脚
        input  wire jtag_TMS,     // JTAG TMS引脚
        input  wire jtag_TDI,     // JTAG TDI引脚
        output wire jtag_TDO,     // JTAG TDO引脚
        
        // test
        output wire jtag_halt_led,// JTAG Halt指示灯
        output wire over,         // 测试是否完成信号
        output wire pass,         // 测试是否成功信号

        // PLIC
        input wire io0_irq,
        input wire io1_irq,
        input wire io2_irq,
        input wire io3_irq
    );

    parameter DW = 32;
    parameter AW = 32;

    // rom
    wire [AW-1:0] inst_addr_rom ;
    wire [DW-1:0] inst_rom      ;
    
    // jtag
    wire          debug_irq       ;
    // regsiter signal
    wire          jtag_reg_wen    ;
    wire [4:0]    jtag_reg_addr   ;
    wire [DW-1:0] jtag_reg_w_data ;
    wire [DW-1:0] jtag_reg_r_data ;   
    // memory signal
    wire          jtag_mem_wen    ;
    wire [AW-1:0] jtag_mem_w_addr ;
    wire [DW-1:0] jtag_mem_w_data ;
    wire [DW-1:0] jtag_mem_r_data ;
    // ctrl signal
    wire          jtag_halt_o ;
    wire          jtag_reset_o; 

    // clint 
    wire swi_en;
    wire swi_irq;
    wire [DW-1:0] timer_data_i;
    wire [AW-1:0] timer_addr_i;
    wire timer_we;
    wire [DW-1:0] data_o;
    wire timer_irq;

    // plic
    wire [3:0] irq_o;

    // test signal
    assign jtag_halt_led = ~jtag_halt_o;
    assign over = ~ riscv_inst.register_inst.reg_mem[26];
    assign pass = ~ riscv_inst.register_inst.reg_mem[27];

    rom #(
            .DW      	(DW    ),
            .AW      	(AW    ),
            .MEM_NUM 	(2**12  )
        )
        rom_inst(
            .clk    	(clk             ),
            .rstn   	(rstn            ),
            .wen    	(jtag_mem_wen    ),
            .w_addr 	(jtag_mem_w_addr ),
            .w_data 	(jtag_mem_w_data ),
            .ren    	(1'b1            ),
            .r_addr 	(inst_addr_rom   ),
            .r_data 	(inst_rom        )
            // .r_addr 	(jtag_mem_w_addr ),
            // .r_data 	(jtag_mem_r_data )
        );

    riscv riscv_inst(
            .clk          (clk            ),
            .rstn         (rstn           ),
            // register
            .reg_wen      (jtag_reg_wen   ),
            .reg_addr     (jtag_reg_addr  ),
            .reg_w_data   (jtag_reg_w_data),
            .reg_r_data   (jtag_reg_r_data),
            // rom
            .inst_rom     (inst_rom       ),
            .inst_addr_rom(inst_addr_rom  ),
            // jtag
            .jtag_halt    (jtag_halt_o    ),
            .jtag_reset   (jtag_reset_o   ),
            .debug_irq    (debug_irq      ),
            // plic
            .plic_irq     (irq_o),
            // clint
            .swi_irq      (swi_irq),
            .timer_irq    (timer_irq)
        );

    clint clint_inst(
            .clk          (clk          ),
            .rstn         (rstn         ),
            .swi_en       (swi_en       ),
            .swi_irq      (swi_irq      ),
            .timer_data_i (timer_data_i ),
            .timer_addr_i (timer_addr_i ),
            .timer_we     (timer_we     ),
            .data_o       (data_o       ),
            .timer_irq    (timer_irq    ) 
        );

    plic #(
        .MUN(4)
    )
    plic_inst(
        .io0_irq (io0_irq),
        .io1_irq (io1_irq),
        .io2_irq (io2_irq),
        .io3_irq (io3_irq),
        .irq_o   (irq_o  )
    );

    jtag_top #(
            .DMI_ADDR_BITS(6),
            .DMI_DATA_BITS(32),
            .DMI_OP_BITS(2)) 
        u_jtag_top(
            .clk           (clk             ),
            .jtag_rst_n    (rstn            ),
            .jtag_pin_TCK  (jtag_TCK        ),
            .jtag_pin_TMS  (jtag_TMS        ),
            .jtag_pin_TDI  (jtag_TDI        ),
            .jtag_pin_TDO  (jtag_TDO        ),
            // write and read register
            .reg_we_o      (jtag_reg_wen    ),
            .reg_addr_o    (jtag_reg_addr   ),
            .reg_wdata_o   (jtag_reg_w_data ),
            .reg_rdata_i   (jtag_reg_r_data ),
            // write and read memory
            .mem_we_o      (jtag_mem_wen    ),
            .mem_addr_o    (jtag_mem_w_addr ),
            .mem_wdata_o   (jtag_mem_w_data ),
            .mem_rdata_i   (jtag_mem_r_data ),
            // jtag ctrl signal
            .halt_req_o    (jtag_halt_o     ),
            .reset_req_o   (jtag_reset_o    ),
            .debug_irq     (debug_irq       )
        );

endmodule
