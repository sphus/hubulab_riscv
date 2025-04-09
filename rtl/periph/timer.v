`include "../core/defines.v" 

// 32 bits count up timer module
module timer(

    input wire clk,
    input wire rstn,

    input wire[31:0] data_i,
    input wire[31:0] addr_i,
    input wire we_i,

    output reg[31:0] data_o,
    // 定时器中断信号
    output wire int_sig_o
);

	//寄存器地址规划
    localparam REG_CTRL  = 4'h0; //定时器使能 定时器中断使能 
    localparam REG_COUNT = 4'h4; //定时器计数器（只读类型）
    localparam REG_VALUE = 4'h8; //设置阈值

    // [0]: timer enable 1
    // [1]: timer int enable 1
    // [2]: timer int pending, write 1 to clear it ，C代码中初始化置1清零 1
	// *中断的等待(pending)状态，有效时表示表示定时器中断正在等待(pending)* //
    // addr offset: 0x00
    reg[31:0] timer_ctrl;

    // timer current count, read only
    // addr offset: 0x04
    reg[31:0] mtime;

    // timer expired value
    // addr offset: 0x08
    reg[31:0] mtimecmp;  //设置阈值

	// 定时器中断使能 且 定时器达到计数阈值 发出中断信号，通过取指打拍模块if_id传给中断模块clint模块进行中断仲裁及处理
    // 打拍是确保在异步异常在上一条指令工作完成后才起作用
    assign int_sig_o = ((timer_ctrl[1] == 1'b1) && (timer_ctrl[2] == 1'b1))? 1'b1: 1'b0;

    // counter
    always @ (posedge clk) begin
        if (rstn == `RstnEnable) begin
            mtime <= `ZeroWord;
        end 
        else begin
			//定时器使能 则定时器计数器开始计数 计数至阈值时清零
            if (timer_ctrl[0] == 1'b1) begin 
                mtime <= mtime + 1'b1;
                if (mtime >= mtimecmp) begin
                    mtime <= `ZeroWord;
                end
            end 
            else begin
                mtime <= `ZeroWord;
            end
        end
    end

    // write regs
    always @ (posedge clk) begin
        if (rstn == `RstnEnable) begin
            timer_ctrl <= `ZeroWord;
            mtimecmp <= `ZeroWord;
            // timer_ctrl <= 32'h00000003;
            // mtimecmp <= 32'h000000c8;
        end 
        else begin
            if (we_i == `Enable) begin
                case (addr_i[3:0])
                    REG_CTRL: begin
						//timer_ctrl[2] 写1清0
                        timer_ctrl <= {data_i[31:3], (timer_ctrl[2] & (~data_i[2])), data_i[1:0]};
                    end                                  //                ~1 = 0
                    REG_VALUE: begin
                        mtimecmp <= data_i;
                    end
                endcase
            end 
            else begin
                if ((timer_ctrl[0] == 1'b1) && (mtime >= mtimecmp)) begin
                    timer_ctrl[0] <= 1'b0;
					//定时器达到计数阈值，中断的等待(pending)状态置为1，触发中断
                    timer_ctrl[2] <= 1'b1; 
                end
            end
        end
    end

    // read regs
    always @ (*) begin
        if (rstn == `RstnEnable) begin
            data_o = `ZeroWord;
        end 
        else begin
            case (addr_i[3:0])
                REG_VALUE: begin
                    data_o = mtimecmp;
                end
                REG_CTRL: begin
                    data_o = timer_ctrl;
                end
                REG_COUNT: begin
                    data_o = mtime;
                end
                default: begin
                    data_o = `ZeroWord;
                end
            endcase
        end
    end

endmodule
