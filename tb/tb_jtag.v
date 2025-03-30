`timescale 1 ns / 1 ps

// select one option only  选择一个模式:测试jtag,还是测试工程
// `define TEST_PROG  1
`define TEST_JTAG  1


// testbench module
module tb_jtag;

    reg clk;
    reg rstn;

    wire jtag_halt_led;
    wire over         ;
    wire pass         ;


    always #10 clk = ~clk;     // 50MHz

    wire[31:0] x3  = riscv_soc_inst.riscv_inst.register_inst.reg_mem[3];
    wire[31:0] x26 = riscv_soc_inst.riscv_inst.register_inst.reg_mem[26];
    wire[31:0] x27 = riscv_soc_inst.riscv_inst.register_inst.reg_mem[27];

    integer r;

    
    // 条件编译,如果下面出现TEST_JTAG，则下面的参数才会被编译
    `ifdef TEST_JTAG
        reg TCK;
        reg TMS;
        reg TDI;
        wire TDO;

        integer i;              // 用于计数
        reg[39:0] shift_reg;    // 40-bit 移位寄存器，可能用于 存储 JTAG 信号或传输的数据
        reg in;                 // 输入的TDI的数据
        wire[39:0] req_data = riscv_soc_inst.u_jtag_top.u_jtag_driver.dtm_req_data;    // 传给dm模块的数据
        wire[4:0]  ir_reg = riscv_soc_inst.u_jtag_top.u_jtag_driver.ir_reg;            // 这是指令寄存器（IR），用于存储当前 JTAG 状态机中的指令
        wire dtm_req_valid = riscv_soc_inst.u_jtag_top.u_jtag_driver.dtm_req_valid;    // 传给dm模块请求数据是否有效

        wire[31:0] dmstatus = riscv_soc_inst.u_jtag_top.u_jtag_dm.dmstatus;            // 调试模块的状态
    `endif


`ifdef TEST_JTAG
    task DR_init(
        input [39:0] DR_NUM
    );
        begin
            // IR(需要进行操作的的类别)和DR（对应的数据）
            // 所以一次操作需要设置IR和读写DR
            // IR（0x11,对应的DR是dmi）
            // IR操作
            shift_reg = 40'b10001;

            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // SELECT-DR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // SELECT-IR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // CAPTURE-IR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // SHIFT-IR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // SHIFT-IR & EXIT1-IR
            // shift_reg = 40'b10001;
            // 环型输出IR
            for (i = 5; i > 0; i = i - 1) begin     // 10001
                if (shift_reg[0] == 1'b1)
                    TDI = 1'b1;
                else
                    TDI = 1'b0;

                if (i == 1)
                    TMS = 1;

                TCK = 0;
                #100
                in = TDO;             // 存下shift_reg移除的数据
                TCK = 1;
                #100
                TCK = 0;

                shift_reg = {{(35){1'b0}}, in, shift_reg[4:1]}; // 将移除的数据存入shift_reg的第5位，其余位右移一位？
                                                                // 这做的意义是什么
            end

            // PAUSE-IR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // EXIT2-IR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // UPDATE-IR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;

            // DR操作
            shift_reg = DR_NUM;
            // SELECT-DR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // CAPTURE-DR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // SHIFT-DR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // SHIFT-DR & EXIT1-DR
            // 环型输出DR
            for (i = 40; i > 0; i = i - 1) begin
                if (shift_reg[0] == 1'b1)
                    TDI = 1'b1;
                else
                    TDI = 1'b0;
                if (i == 1)
                    TMS = 1;
                TCK = 0;
                #100
                in = TDO;
                TCK = 1;
                #100
                TCK = 0;
                shift_reg = {in, shift_reg[39:1]};
            end
            // PAUSE-DR
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // EXIT2-DR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // UPDATE-DR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // IDLE
            TMS = 0;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
            // SELECT-DR
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
        end
    endtask 
`endif

    initial begin
        clk = 0;
        rstn = 1'b0;
`ifdef TEST_JTAG
        TCK = 1;
        TMS = 1;
        TDI = 1;
`endif
        $display("test running...");
        #40
        rstn = 1'b1;
        #200

`ifdef TEST_PROG
        wait(x26 == 32'b1)   // wait sim end, when x26 == 1
        #100
        if (x27 == 32'b1) begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_PASS ~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~ #####     ##     ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #    #   #  #   #       #     ~~~~~~~~~");
            $display("~~~~~~~~~ #    #  #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~ #####   ######       #       #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #  #    #  #    #~~~~~~~~~");
            $display("~~~~~~~~~ #       #    #   ####    #### ~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
        end 
        else begin
            $display("~~~~~~~~~~~~~~~~~~~ TEST_FAIL ~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("~~~~~~~~~~######    ##       #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#        #  #      #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#####   #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       ######     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    #     ~~~~~~~~~~");
            $display("~~~~~~~~~~#       #    #     #    ######~~~~~~~~~~");
            $display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
            $display("fail testnum = %2d", x3);
            for (r = 0; r < 32; r = r + 1)
                $display("x%2d = 0x%x", r, riscv_soc_inst.riscv_inst.register_inst.reg_mem[r]);
        end
`endif

/***************************************************************************************/
// jtag操作总的来说，就是操作IR和DR进行读写外设。（读,写可以空操作一次让上次操作的值输出）
/***************************************************************************************/

`ifdef TEST_JTAG
        // jtag复位(根据jtag的状态转移图看出，只要连续5个TMS为1（TCK在上升沿时），即可回到初始状态)
        for (i = 0; i < 8; i = i + 1) begin
            TMS = 1;
            TCK = 0;
            #100
            TCK = 1;
            #100
            TCK = 0;
        end       
        // // shift_reg = {6'h11, {(32){1'b0}}, 2'b01};
        // 设置sbcs寄存器,使其地址自增4
        DR_init({6'h38,32'h20050404,2'b10});
        // 空拍
        DR_init({6'h38,32'h00000000,2'b00});
        // 设置初始地址
        DR_init({6'h39,32'h00000008,2'b10});
        DR_init({6'h39,32'h00000000,2'b00});
        DR_init({6'h3C,32'h00000005,2'b10});
        DR_init({6'h3C,32'h00000000,2'b00});
        DR_init({6'h3C,32'h00000008,2'b10});
        DR_init({6'h3C,32'h00000000,2'b00});
        DR_init({6'h3C,32'h00000005,2'b10});
        DR_init({6'h3C,32'h00000000,2'b00});
        DR_init({6'h3C,32'h00000008,2'b10});
        DR_init({6'h3C,32'h00000000,2'b00});
    
        // // 开始写入数据
        // for (i = 6; i > 0; i = i - 1 ) begin
        //     DR_init({6'h3C,32'h00000005 + (i+i),2'b10});
        //     DR_init({6'h3C,32'h00000000,2'b00});
        // end
`endif

//        $finish;
    end

    // // sim timeout
    // initial begin
    //     #500000
    //     $display("Time Out.");
    //     $finish;
    // end

/*
    // read mem data,将二进制数据写入rom里
    initial begin
        $readmemh ("inst.data", riscv_soc_inst.u_rom._rom);
    end

    // generate wave file, used by gtkwave
    initial begin
        $dumpfile("tinyriscv_soc_tb.vcd");
        $dumpvars(0, tinyriscv_soc_tb);
    end
*/

    riscv_soc riscv_soc_inst(
        .clk (clk),
        .rstn(rstn),
`ifdef TEST_JTAG
        .jtag_TCK(TCK),
        .jtag_TMS(TMS),
        .jtag_TDI(TDI),
        .jtag_TDO(TDO),
`endif
        .jtag_halt_led(jtag_halt_led),
        .over         (over         ),
        .pass         (pass         )
    );

endmodule
