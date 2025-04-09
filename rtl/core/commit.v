`include "defines.v"

/******************************************************************************************/
//异常种类:
//同步异常(系统调用：ECALL,EBREAK)
//异步异常(定时器中断、外部中断、软件中断、调试中断)()
/******************************************************************************************/

/******************************************************************************************/
//特别注意:
//同步异常时，mepc存下的是ecall本身的地址，所以中断服务返回时要+4,但这里的写法不要求返回时+4
//异步异常时，要先让已经在执行的指令执行完，再将未执行的指令地址存入mepc，所以不用加4
/******************************************************************************************/

// core local interruptor module
// 核心中断管理、仲裁模块
module commit(
    input wire clk,
    input wire rstn,

    // from if_id
    input wire[`Interrupt_Bus] irq_i,           

    // from id
    input wire[`InstBus] inst_i,               
    input wire[`InstAddrBus] inst_addr_i,       

    // from ex
    input wire jump_flag_i,                     
    input wire[`InstBus] jump_addr_i,           

    // from csr_reg               
    input wire[`RegBus] csr_mtvec,              
    input wire[`RegBus] csr_mepc,               
    input wire[`RegBus] csr_mstatus,            
    input wire global_int_en_i,                 

    // to ctrl
    output wire hold_flag_o,                    

    // to csr_reg
    output reg we_o,                            
    output reg[`RegBus] waddr_o,                
    output reg[`RegBus] raddr_o,                
    output reg[`RegBus] data_o, 
    output reg[4:0]     int_type,                

    // to ex
    output reg[`InstAddrBus] int_addr_o,        
    output reg int_assert_o                     
);

    // 中断状态定义
    localparam S_INT_IDLE            = 4'b0001;   
    localparam S_INT_SYNC_ASSERT     = 4'b0010;   
    localparam S_INT_ASYNC_ASSERT    = 4'b0100;   
    localparam S_INT_MRET            = 4'b1000;   

    // 写CSR寄存器状态定义
    localparam S_CSR_IDLE            = 5'b00001;  
    localparam S_CSR_MEPC            = 5'b00010;  
    localparam S_CSR_MSTATUS         = 5'b00100;  
    localparam S_CSR_MCAUSE          = 5'b01000;  
    localparam S_CSR_MSTATUS_MRET    = 5'b10000;  

    reg[3:0] int_state;                           // 指令中断状态
    reg[4:0] csr_state;                           // 寄存器状态
    reg[`InstAddrBus] inst_addr;
    reg[31:0] cause;                              

    assign hold_flag_o = ((int_state != S_INT_IDLE) | (csr_state != S_CSR_IDLE))? `Enable: `Disable;

    // 中断仲裁逻辑（组合）
    always @ (*) begin                          // 优先级：同步中断 > 异步中断 > MRET（中断返回）
        if (rstn == `RstnEnable) begin          
            int_state = S_INT_IDLE;
            int_type = 5'b0;
        end 
        else begin
            // ECALL，EBREAK是系统调用
            if (inst_i == `INST_ECALL || inst_i == `INST_EBREAK) begin  
                int_state = S_INT_SYNC_ASSERT;
                int_type[0] = 1'b0;
                case(inst_i)
                    `INST_ECALL: int_type[1] = 1'b1;
                    `INST_EBREAK: int_type[2] = 1'b1;
                endcase
            end
            // irq_i中断输入信号、global_int_en_i全局中断使能,来自mstatus[3]
            else if (irq_i != 4'b0 && global_int_en_i == `Enable) begin 
                int_state = S_INT_ASYNC_ASSERT;
                int_type[0] = 1'b1;
                case(irq_i)
                    4'b0001: int_type[1] = 1'b1;
                    4'b0010: int_type[2] = 1'b1;
                    4'b0100: int_type[3] = 1'b1;
                    4'b1000: int_type[4] = 1'b1;
                endcase        
            end 
            else if (inst_i == `INST_MRET) begin        
                int_state = S_INT_MRET;
                int_type = 5'b0;
            end
            else begin
                int_state = S_INT_IDLE;
                int_type = int_type;
            end
        end
    end

    // 写CSR寄存器状态切换,一个时钟周期写一个csr寄存器
    always @ (posedge clk) begin
        if (rstn == `RstnEnable) begin
            csr_state <= S_CSR_IDLE;
            cause <= `ZeroWord;
            inst_addr <= `ZeroWord;                     
        end 
        else begin
            case (csr_state)
                S_CSR_IDLE: begin                               
                    if (int_state == S_INT_SYNC_ASSERT) begin
                        csr_state <= S_CSR_MEPC;                
                        // jump的信息是上一条指令在ex执行的结果
                        if (jump_flag_i == `Enable) begin       
                            inst_addr <= jump_addr_i;    
                        end 
                        else begin                                      // 跳转指令外的同步异常
                            inst_addr <= inst_addr_i + 4'd4;       
                        end     
                        case (inst_i)                                   // 异常原因的赋值可以查表
                            `INST_ECALL  : cause <= 32'h0000000b;       // 从M进行环境调用
                            `INST_EBREAK : cause <= 32'h00000003;       // 断点
                            default: cause <= 32'h8000000a;             // 从H进行环境调用      
                        endcase
                    end
                    // 异步中断 
                    else if (int_state == S_INT_ASYNC_ASSERT) begin
                        case (irq_i)                                    // 都是机器模式
                            4'b0001: cause <= 32'h80000003;             // 软件中断
                            4'b0010: cause <= 32'h80000007;             // 定时中断
                            4'b0100: cause <= 32'h8000000b;             // 外部中断
                            4'b1000: cause <= 32'h8000000c;             // 调试中断 
                            default: cause <= 32'h8000000d;             // 保留
                        endcase           
                        csr_state <= S_CSR_MEPC;
                        if (jump_flag_i == `Enable) begin       
                            inst_addr <= jump_addr_i;                                                                  
                        end
                        else begin
                            inst_addr <= inst_addr_i;
                        end
                    end
                    // 中断返回 
                    else if (int_state == S_INT_MRET) begin
                        csr_state <= S_CSR_MSTATUS_MRET;
                    end
                end
                S_CSR_MEPC: begin
                    csr_state <= S_CSR_MSTATUS;
                end
                S_CSR_MSTATUS: begin
                    csr_state <= S_CSR_MCAUSE;
                end
                S_CSR_MCAUSE: begin
                    csr_state <= S_CSR_IDLE;
                end 
                S_CSR_MSTATUS_MRET: begin
                    csr_state <= S_CSR_IDLE;
                end
                default: begin
                    csr_state <= S_CSR_IDLE;
                end
            endcase
        end
    end

    // 发出中断信号前，先写几个CSR寄存器（时序）
    always @ (posedge clk) begin
        if (rstn == `RstnEnable) begin
            we_o <= `Disable;
            waddr_o <= `ZeroWord;
            data_o <= `ZeroWord;
        end 
        else begin
            case (csr_state)
                // 将mepc寄存器的值设为当前指令地址
                S_CSR_MEPC: begin
                    we_o <= `Enable;
                    waddr_o <= {20'h0, `CSR_MEPC};  //CSR_MEPC寄存器的addr为： 12'h341
                    data_o <= inst_addr;            //把中断返回地址写到CSR_MEPC寄存器中
                end
				// 写mstatus,关闭全局中断
                S_CSR_MSTATUS: begin
                    we_o <= `Enable;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    data_o <= {csr_mstatus[31:4], 1'b0, csr_mstatus[2:0]};
                end
				// 写mcause,异常产生的原因
                S_CSR_MCAUSE: begin
                    we_o <= `Enable;
                    waddr_o <= {20'h0, `CSR_MCAUSE}; //CSR_MCAUSE  12'h342
                    data_o <= cause;
                end
                // 中断返回
                S_CSR_MSTATUS_MRET: begin
                    we_o <= `Enable;
                    waddr_o <= {20'h0, `CSR_MSTATUS};
                    // 将mstatus的mip写入mie
                    data_o <= {csr_mstatus[31:4], csr_mstatus[7], csr_mstatus[2:0]};
                end
                default: begin
                    we_o <= `Disable;
                    waddr_o <= `ZeroWord;
                    data_o <= `ZeroWord;
                end
            endcase
        end
    end

    // 发出中断信号给ex模块（时序）
    always @ (posedge clk) begin
        if (rstn == `RstnEnable) begin
            int_assert_o <= `InstDisable;
            int_addr_o <= `ZeroWord;
        end 
        else begin
            case (csr_state)
                // 写完mcause寄存器才能发中断进入信号
                S_CSR_MCAUSE: begin
                    int_assert_o <= `InstEnable;
                    int_addr_o <= csr_mtvec;            // 中断的目标地址
                end
                // 发出中断返回信号
                S_CSR_MSTATUS_MRET: begin
                    int_assert_o <= `InstEnable;
                    int_addr_o <= csr_mepc;             // 中断的返回地址(读是组合输出的)
                end
                default: begin
                    int_assert_o <= `InstDisable;
                    int_addr_o <= `ZeroWord;
                end
            endcase
        end
    end

endmodule
