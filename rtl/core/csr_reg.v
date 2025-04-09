`include "defines.v"

module csr_reg #(
    parameter NUM    = 5,
    parameter ECALL  = 32'h000002c4,
    parameter EBREAK = 32'h000002c4,
    parameter TIMER  = 32'h000002C0,
    parameter DEBUG  = 32'h000002C0,
    parameter SWI    = 32'h000002C0,
    parameter PLIC   = 32'h000002C0
)
(
    input wire clk,
    input wire rstn,

    // from ex
    input wire ex_wen_i,
    input wire [`RegBus] ex_wdata_i,
    input wire [`RegBus] ex_waddr_i,
    input wire [`RegBus] id_raddr_i,
    // to ex 
    output reg [`RegBus] id_rdata_o,

    // from commit
    input  wire commit_wen_i,
    input  wire [`RegBus] commit_wdata_i,
    input  wire [`RegBus] commit_waddr_i,
    input  wire [`RegBus] commit_raddr_i,
    input  wire [NUM-1:0] int_type,
    output reg  [`RegBus] commit_rdata_o,
    output reg  [`RegBus] csr_mtvec,
    output wire [`RegBus] csr_mepc,
    output wire [`RegBus] csr_mstatus,
    output wire global_int_en_o
);

    //csr_reg
    reg[`DoubleRegBus] cycle;   //64位的计数器（复位撤销后就一直计数，计数器统计自CPU复位以来共运行了多少个周期。
    reg[`RegBus] mtvec;         //发生异常时处理器需要跳转的地址（用来设置中断和异常的入口）。
    reg[`RegBus] mcause;        //当产生中断和异常时，mcause寄存器中会记录当前产生的中断或者异常类型。
    reg[`RegBus] mepc;          //保存发生异常指令的地址。
    reg[`RegBus] mie;           //指明处理器目前能处理和忽略的中断。三种中断类型在m模式和s模式下都有相应的中断使能位设置，这是通过mie寄存器实现的。
    reg[`RegBus] mstatus;       //全局中断使能和其他状态信息
    reg[`RegBus] mscratch;      //mscratch寄存器用于机器模式下的程序临时保存某些数据


    assign global_int_en_o = (mstatus[3] == 1'b1) ? 1'b1 : 1'b0;     //全局异常使能
    // assign csr_mtvec = mtvec;
    assign csr_mepc = mepc;
    assign csr_mstatus = mstatus;

    always @(*) begin
        case (int_type)
            5'b00010: csr_mtvec = ECALL;
            5'b00100: csr_mtvec = EBREAK;
            5'b00011: csr_mtvec = SWI;
            5'b00101: csr_mtvec = TIMER;
            5'b01001: csr_mtvec = PLIC;
            5'b10001: csr_mtvec = DEBUG;
            default: csr_mtvec =  mtvec;
        endcase 
    end

    //cycle counter
    always @(posedge clk) begin
        if (!rstn) begin
            cycle <= {`ZeroWord,`ZeroWord};
        end
        else begin
            cycle <= cycle + 1'b1;
        end
    end

    // wirte csr_reg
    // 优先响应ex的写操作
    always @(posedge clk) begin
        if (!rstn) begin
            mtvec     <= 32'h000002c4;
            mcause    <= `ZeroWord;  
            mepc      <= `ZeroWord;    
            mie       <= `ZeroWord;     
            mstatus   <= 32'h00000088; 
            mscratch  <= `ZeroWord;
        end
        else begin
            if(ex_wen_i == `Enable) begin
                case (ex_waddr_i[11:0])
                    `CSR_MTVEC    : mtvec    <= ex_wdata_i;
                    `CSR_MCAUSE   : mcause   <= ex_wdata_i;
                    `CSR_MEPC     : mepc     <= ex_wdata_i;
                    `CSR_MIE      : mie      <= ex_wdata_i;
                    `CSR_MSTATUS  : mstatus  <= ex_wdata_i;
                    `CSR_MSCRATCH : mscratch <= ex_wdata_i;
                    default:    ;
                endcase
            end
            else if(commit_wen_i == `Enable) begin
                case (commit_waddr_i[11:0])
                    `CSR_MTVEC    : mtvec    <= commit_wdata_i;
                    `CSR_MCAUSE   : mcause   <= commit_wdata_i;
                    `CSR_MEPC     : mepc     <= commit_wdata_i;
                    `CSR_MIE      : mie      <= commit_wdata_i;
                    `CSR_MSTATUS  : mstatus  <= commit_wdata_i;
                    `CSR_MSCRATCH : mscratch <= commit_wdata_i;
                    default:    ;
                endcase
            end
        end
    end

    //ex read csr_reg
    always @(*) begin
        if((ex_waddr_i[11:0] == id_raddr_i[11:0]) && (ex_wen_i == `Enable)) begin
            id_rdata_o = ex_wdata_i;
        end
        else begin
            case (id_raddr_i[11:0]) 
                `CSR_CYCLE    : id_rdata_o = cycle[31:0];
                `CSR_CYCLEH   : id_rdata_o = cycle[63:32];
                `CSR_MTVEC    : id_rdata_o = mtvec;
                `CSR_MCAUSE   : id_rdata_o = mcause;
                `CSR_MEPC     : id_rdata_o = mepc;
                `CSR_MIE      : id_rdata_o = mie;
                `CSR_MSTATUS  : id_rdata_o = mstatus;
                `CSR_MSCRATCH : id_rdata_o = mscratch;
                default       : id_rdata_o = `ZeroWord;
            endcase
        end    
    end
 
    //commit read csr_reg
    always @(*) begin
        if((commit_waddr_i[11:0] == commit_raddr_i[11:0]) && (commit_wen_i == `Enable)) begin
            commit_rdata_o = commit_wdata_i;
        end
        else begin
            case (id_raddr_i[11:0]) 
                `CSR_CYCLE    : commit_rdata_o = cycle[31:0];
                `CSR_CYCLEH   : commit_rdata_o = cycle[63:32];
                `CSR_MTVEC    : commit_rdata_o = mtvec;
                `CSR_MCAUSE   : commit_rdata_o = mcause;
                `CSR_MEPC     : commit_rdata_o = mepc;
                `CSR_MIE      : commit_rdata_o = mie;
                `CSR_MSTATUS  : commit_rdata_o = mstatus;
                `CSR_MSCRATCH : commit_rdata_o = mscratch;
                default       : commit_rdata_o = `ZeroWord;
            endcase
        end    
    end

endmodule //csr_reg
