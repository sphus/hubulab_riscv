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
        output reg  over,         // 测试是否完成信号
        output reg  pass          // 测试是否成功信号
    );

    parameter DW = 32;
    parameter AW = 32;

    // rom
    wire [AW-1:0] inst_addr_rom   ;
    wire [DW-1:0] inst_rom        ;
    
    // jtag
    wire          jtag_wen    ;
    wire [AW-1:0] jtag_w_addr ;
    wire [DW-1:0] jtag_w_data ;
    wire          jtag_halt_o ;
    wire          jtag_reset_o; 

    assign jtag_halt_led = ~jtag_halt_o;

    always @ (posedge clk) begin
        if (!rstn) begin
            over <= 1'b1;
            pass <= 1'b1;
        end 
        else begin
            over <= ~ riscv_inst.register_inst.reg_mem[26];  // when = 1, run over
            pass <= ~ riscv_inst.register_inst.reg_mem[27];  // when = 1, run pass, otherwise fail
        end
    end

    rom #(
            .DW      	(DW    ),
            .AW      	(AW    ),
            .MEM_NUM 	(2**12  )
        )
        rom_inst(
            .clk    	(clk            ),
            .rstn   	(rstn           ),
            .wen    	(jtag_wen        ),
            .w_addr 	(jtag_w_addr     ),
            .w_data 	(jtag_w_data     ),
            .ren    	(1'b1        ),
            .r_addr 	(inst_addr_rom     ),
            .r_data 	(inst_rom     )
        );

    riscv riscv_inst(
            .clk          (clk            ),
            .rstn         (rstn           ),
            // rom
            .inst_rom     (inst_rom       ),
            .inst_addr_rom(inst_addr_rom  ),
            // jtag
            .jtag_halt    (jtag_halt_o    ),
            .jtag_reset   (jtag_reset_o   )
        );

    jtag_top #(
            .DMI_ADDR_BITS(6),
            .DMI_DATA_BITS(32),
            .DMI_OP_BITS(2)) 
        u_jtag_top(
            .clk           (clk              ),
            .jtag_rst_n    (rstn             ),
            .jtag_pin_TCK  (jtag_TCK         ),
            .jtag_pin_TMS  (jtag_TMS         ),
            .jtag_pin_TDI  (jtag_TDI         ),
            .jtag_pin_TDO  (jtag_TDO         ),
            // jtag对mem进行读写
            .mem_we_o      (jtag_wen         ),
            .mem_addr_o    (jtag_w_addr      ), 
            .mem_wdata_o   (jtag_w_data      ),

            .halt_req_o    (jtag_halt_o      ),
            .reset_req_o   (jtag_reset_o     ) 
        );

endmodule
