
`timescale 1ns/1ns
module tb_int();

`define CLK_PERIOD 20
// `define READ_FILE "../generated/inst_data.txt"
 `define READ_FILE "../generated/rv32ui-p-addi - interrupt.txt"

// `define DEBUG  1
// `define SWI  1
`define PLIC  1
// `define TIMER  1

    reg  clk ;
    reg  rstn;
    reg  jtag_TCK;
    reg  jtag_TMS;
    reg  jtag_TDI;
    wire jtag_TDO;
    wire over;
    wire pass;
    wire jtag_halt_led;
    reg  io0_irq;
    reg  io1_irq;
    reg  io2_irq;
    reg  io3_irq;

    always #(`CLK_PERIOD / 2) clk = ~clk;

    initial
    begin
        clk  = 1'b1;
        rstn = 1'b0;
        jtag_TCK = 1'b0;
        jtag_TMS = 1'b0;
        jtag_TDI = 1'b0;
        io0_irq = 1'b0;
        io1_irq = 1'b0;
        io2_irq = 1'b0;
        io3_irq = 1'b0;
        #(`CLK_PERIOD * 1.5);
        rstn = 1'b1;
        `ifdef DEBUG
        # 100
        tb_int.riscv_soc_inst.u_jtag_top.u_jtag_dm.dmcontrol = 32'h10000000;
        `endif

        `ifdef SWI
        # 100
        tb_int.riscv_soc_inst.clint_inst.msip = 32'h1;
        # 20 
        tb_int.riscv_soc_inst.clint_inst.msip = 32'h0;
        `endif

        `ifdef PLIC
        # 100
        io0_irq = 1'b0;
        io1_irq = 1'b1;
        io2_irq = 1'b1;
        io3_irq = 1'b0;
        # 20
        io0_irq = 1'b0;
        io1_irq = 1'b0;
        io2_irq = 1'b0;
        io3_irq = 1'b0;
        `endif

        `ifdef TIMER
        // 把timer的timer_ctrl和mtimecmp赋值一个初值就行
        `endif
    end

    parameter DEPTH = 2**20;  // 总地址 1M
    parameter RAM_DEPTH = DEPTH / 4;  // 每块 RAM 的大小 2^18

    reg [31:0] temp_mem [0:RAM_DEPTH-1]; // 读取 32-bit 数据

    integer i;

    // initial ram
    initial
    begin
        $readmemh(`READ_FILE, temp_mem); // 读取 32-bit 数据
        for (i = 0; i < RAM_DEPTH; i = i + 1)
        begin
            tb_int.riscv_soc_inst.riscv_inst.ram_inst.ram_byte0.dual_ram_template_inst.memory[i] = temp_mem[i][7:0];   // 低 8 位
            tb_int.riscv_soc_inst.riscv_inst.ram_inst.ram_byte1.dual_ram_template_inst.memory[i] = temp_mem[i][15:8];  // 次低 8 位
            tb_int.riscv_soc_inst.riscv_inst.ram_inst.ram_byte2.dual_ram_template_inst.memory[i] = temp_mem[i][23:16]; // 次高 8 位
            tb_int.riscv_soc_inst.riscv_inst.ram_inst.ram_byte3.dual_ram_template_inst.memory[i] = temp_mem[i][31:24]; // 高 8 位
        end
    end

    // initial rom
    initial
    begin
        $readmemh(`READ_FILE,tb_int.riscv_soc_inst.rom_inst.dual_ram_inst.dual_ram_template_inst.memory);
    end

    // wire [31:0] pc_pc     = tb_int.riscv_soc_inst.riscv_inst.inst_addr_rom;
    // wire [31:0] pc_id     = tb_int.riscv_soc_inst.riscv_inst.inst_addr_if_id;
    wire [31:0] pc_ex     = tb_int.riscv_soc_inst.riscv_inst.inst_addr_id_ex;
    wire        jump_flag = tb_int.riscv_soc_inst.riscv_inst.jump_en_ctrl;
    wire [31:0] jump_addr = tb_int.riscv_soc_inst.riscv_inst.jump_addr_ctrl;

    // wire [31:0] pc [2:0];
    // assign pc[0] = tb_int.riscv_soc_inst.inst_addr_rom;
    // assign pc[1] = (pc[0] > 0) ? (pc[0] - 4) : 0;
    // assign pc[2] = (pc[1] > 0) ? (pc[1] - 4) : 0;


    // reg         jump_flag_end ;
    // reg [31:0]  pc_reg      ;
    // reg [31:0]  pc_jump_before ;
    // reg [31:0]  pc_jump_last ;


    // always @(posedge clk) begin
    //     if(!rstn) begin
    //         pc_reg <= 32'd0;
    //         jump_flag_end <= 0;
    //         pc_jump_before <= 32'd0;
    //         pc_jump_last <= 32'd0;
    //     end

    //     pc_reg <= pc[0];
    //     if((pc_reg != pc[0] - 4) && (pc_reg != 0) && (pc[0] != 0)) begin
    //         jump_flag_end <= 1;
    //         pc_jump_before <= pc_reg;
    //         pc_jump_last <= pc[0];
    //     end
    //     if (jump_flag_end)
    //         jump_flag_end <= 0;
    // end


    wire [31:0] x [31:0];

    genvar y;

    generate
        for(y = 0 ; y < 31; y = y + 1)
        begin
            assign x[y] = tb_int.riscv_soc_inst.riscv_inst.register_inst.reg_mem[y];
        end
    endgenerate


    integer r;

    initial
    begin
        wait(x[26] == 32'b1);
        #(`CLK_PERIOD*3);
        if(x[27] == 32'b1)
        begin
            $display("############################");
            $display("########  pass  !!!#########");
            $display("############################");
        end
        else
        begin
            for(r = 0;r < 31; r = r + 4)
                $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
            $display("############################");
            $display("########  fail  !!!#########");
            $display("############################");
            $display("fail testnum = %2d", x[3]);
        end
        $stop;
        // $finish;
    end

    // always @(x[3])
    // begin
    //     $display("\n");
    //     for(r = 0;r < 31; r = r + 4)
    //         $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
    // end

    always @(posedge clk)
    begin
        if(jump_flag)
        begin
            $display("%x jump to %x at %d", pc_ex,jump_addr,$time);
        end

        if ($time >= 500000)
        begin
            for(r = 0;r < 31; r = r + 4)
                $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
            $display("############################");
            $display("######  timeout  !!!########");
            $display("############################");
            // $finish;
            // $stop;
        end
    end

    riscv_soc riscv_soc_inst(
            .clk           (clk    ),
            .rstn          (rstn   ),
            .jtag_TCK      (jtag_TCK),
            .jtag_TMS      (jtag_TMS),
            .jtag_TDI      (jtag_TDI),
            .jtag_TDO      (jtag_TDO),
            .over          (over),
            .pass          (pass),
            .jtag_halt_led (jtag_halt_led),
            .io0_irq       (io0_irq),
            .io1_irq       (io1_irq),
            .io2_irq       (io2_irq),
            .io3_irq       (io3_irq)
        );

endmodule
