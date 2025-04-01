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

    wire [AW-1:0] inst_addr_rom   ;
    wire [DW-1:0] inst_rom        ;
    
    // rom
    wire          rom_wen   ;
    wire [AW-1:0] rom_w_addr;
    wire [DW-1:0] rom_w_data;
    wire          rom_ren   ;
    wire [AW-1:0] rom_r_addr;
    wire [DW-1:0] rom_r_data;  

    // jtag
    wire          jtag_flag   ; // jtag和soc共用一个rom,通过此信号进行切换  
    wire          jtag_wen    ;
    wire [AW-1:0] jtag_w_addr ;
    wire [DW-1:0] jtag_w_data ;
    wire [DW-1:0] jtag_r_data ;
    wire          jtag_halt_o ;
    wire          jtag_reset_o; 

    assign jtag_halt_led = ~jtag_halt_o;

    wire [31:0] x26 = riscv_inst.register_inst.reg_mem[26];  // when = 1, run over;
    wire [31:0] x27 = riscv_inst.register_inst.reg_mem[27];  // when = 1, run pass, otherwise fail;
    reg [31:0] x27_delay;
    wire x27_flag = x27 ^ x27_delay;

    wire [31:0] inst_data = riscv_inst.inst_id_ex     ;
    wire [31:0] inst_addr = riscv_inst.inst_addr_id_ex;

    // jump
    wire [31:0] jump_addr = riscv_inst.jump_addr_ctrl     ;
    wire jump_en = riscv_inst.jump_en_ctrl;

    always @ (posedge clk) begin
        if (!rstn) begin
            over <= 1'b1;
            pass <= 1'b1;
            x27_delay <= x27;
        end 
        else begin
            x27_delay <= x27;
            over <= ~ riscv_inst.register_inst.reg_mem[26];  // when = 1, run over
            pass <= ~ riscv_inst.register_inst.reg_mem[27];  // when = 1, run pass, otherwise fail
        end
    end

    rom_mux #(
            .DW      	(DW    ),
            .AW      	(AW    )
        )
        rom_mux_inst(
            .jtag_flag    (jtag_flag    ),
            .jtag_wen     (jtag_wen     ),
            .jtag_w_addr  (jtag_w_addr  ),
            .jtag_w_data  (jtag_w_data  ),
            .jtag_r_data  (jtag_r_data  ),
            .inst_addr_rom(inst_addr_rom),
            .inst_rom     (inst_rom     ),
            .rom_wen      (rom_wen      ),
            .rom_w_addr   (rom_w_addr   ),
            .rom_w_data   (rom_w_data   ),
            .rom_ren      (rom_ren      ),
            .rom_r_addr   (rom_r_addr   ),
            .rom_r_data   (rom_r_data   )  
        );

    rom #(
            .DW      	(DW    ),
            .AW      	(AW    ),
            .MEM_NUM 	(2**12  )
        )
        rom_inst(
            .clk    	(clk            ),
            .rstn   	(rstn           ),
            .wen    	(rom_wen        ),
            .w_addr 	(rom_w_addr     ),
            .w_data 	(rom_w_data     ),
            .ren    	(rom_ren        ),
            .r_addr 	(rom_r_addr     ),
            .r_data 	(rom_r_data     )
        );

    // rom_test rom_test_init (
    //         .clk(clk),
    //         .rstn(rstn),
    //         .we_i(jtag_wen),
    //         .addr_i(jtag_w_addr),
    //         .data_i(jtag_w_data),
    //         .flag(jtag_flag),
    //         .data_o(jtag_r_data)
    // );

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
            // 不需要jtag对reg进行读写
            .reg_we_o      (  ),
            .reg_addr_o    (  ),
            .reg_wdata_o   (  ),
            .reg_rdata_i   (32'h0  ),
            // jtag对mem进行读写
            .mem_we_o      (jtag_wen         ),
            .mem_addr_o    (jtag_w_addr      ), //高4位是从机的选择
            .mem_wdata_o   (jtag_w_data      ),
            .mem_rdata_i   (jtag_r_data      ),
            .op_req_o      (jtag_flag        ),

            .halt_req_o    (jtag_halt_o      ),
            .reset_req_o   (jtag_reset_o     ) 
        );
/*
        // jtag_top
        wire [39:0] dtm_req_data_i;
        wire [39:0] dm_resp_data_o;

        // jtag_dm
        wire [1:0]  op;
        wire [5:0]  address;
        wire [31:0] data;
        wire [31:0] sbcs;

        assign dtm_req_data_i = u_jtag_top.dtm_req_data_o;
        assign dm_resp_data_o = u_jtag_top.dm_resp_data_o;

        assign op      = u_jtag_top.u_jtag_dm.op;
        assign address = u_jtag_top.u_jtag_dm.address;
        assign data    = u_jtag_top.u_jtag_dm.data;
        assign sbcs    = u_jtag_top.u_jtag_dm.sbcs;
  
        // 这种写法是不对的，会消耗很多资源
        // rom
        wire [31:0] num_0;
        wire [31:0] num_1;
        wire [31:0] num_2;
        wire [31:0] num_3;
        wire [31:0] num_4;
        wire [31:0] num_5;

        // 物理的连线
        assign num_0 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[0];
        assign num_1 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[1];
        assign num_2 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[2];
        assign num_3 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[3];
        assign num_4 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[4];
        assign num_5 = rom_inst.dual_ram_inst.dual_ram_template_inst.memory[5];

        // 用reg作为中转站
        reg [31:0] num_0;
        reg [31:0] num_1;
        reg [31:0] num_2;
        reg [31:0] num_3;
        reg [31:0] num_4;
        reg [31:0] num_5;

        always @(posedge clk) begin
            num_0 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[0];
            num_1 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[1];
            num_2 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[2];
            num_3 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[3];
            num_4 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[4];
            num_5 <= rom_inst.dual_ram_inst.dual_ram_template_inst.memory[5];
        end

        ila_0 jtag_test (
            .clk(clk), // input wire clk
        
            // soc
            .probe0(jtag_TCK), // input wire [0:0]  probe0  
            .probe1(jtag_TMS), // input wire [0:0]  probe1 
            .probe2(jtag_TDI), // input wire [0:0]  probe2 
            .probe3(jtag_TDO), // input wire [0:0]  probe3 
            // jatg_top
            .probe4(jtag_wen     ), // input wire [0:0]  probe4 
            .probe5(jtag_flag    ), // input wire [0:0]  probe5 
            .probe6(jtag_halt_o  ), // input wire [0:0]  probe6 
            .probe7(jtag_reset_o ), // input wire [0:0]  probe7 
            .probe8 (jtag_w_addr), // input wire [31:0]  probe8 
            .probe9 (jtag_w_data), // input wire [31:0]  probe9 
            .probe10(jtag_r_data), // input wire [31:0]  probe10 
            // rom
            .probe11(rom_wen   ), // input wire [0:0]  probe11 
            .probe12(rom_ren   ), // input wire [0:0]  probe12 
            .probe13(rom_w_addr), // input wire [31:0]  probe13 
            .probe14(rom_w_data), // input wire [31:0]  probe14 
            .probe15(num_0), // input wire [31:0]  probe15 
            .probe16(num_1), // input wire [31:0]  probe16 
            .probe17(num_2), // input wire [31:0]  probe17 
            .probe18(num_3), // input wire [31:0]  probe18 
            .probe19(num_4), // input wire [31:0]  probe19 
            .probe20(num_5) // input wire [31:0]  probe20
        );
*/ 

wire [31:0] pc;

assign pc = riscv_inst.inst_addr_rom;

ila_0 pc_test (
	.clk(clk), // input wire clk


	.probe0(pc), // input wire [31:0]  probe0  
	.probe1(x26), // input wire [31:0]  probe1 
	.probe2(x27), // input wire [31:0]  probe2
    .probe3(jump_en),
    .probe4(jump_addr),
    .probe5(inst_addr),
    .probe6(rom_r_addr),
    .probe7(rom_r_data)
);
endmodule
