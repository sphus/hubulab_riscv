`include "../defines.v"

module csr_reg (
    input wire clk,
    input wire rstn,

    // from ex
    input wire csr_wen_i,
    input wire [`RegBus] csr_wdata_i,
    input wire [`RegBus] csr_waddr_i,

    // from id
    input  wire [`RegBus] csr_raddr_i,
    // to id 
    output reg  [`RegBus] csr_rdata_o
);

    //csr_reg
    reg[`DoubleRegBus] cycle;   //64位的计数器（复位撤销后就一直计数，计数器统计自CPU复位以来共运行了多少个周期。
    reg[`RegBus] mtvec;         //发生异常时处理器需要跳转的地址（用来设置中断和异常的入口）。
    reg[`RegBus] mcause;        //当产生中断和异常时，mcause寄存器中会记录当前产生的中断或者异常类型。
    reg[`RegBus] mepc;          //保存发生异常指令的地址。
    reg[`RegBus] mie;           //指明处理器目前能处理和忽略的中断。三种中断类型在m模式和s模式下都有相应的中断使能位设置，这是通过mie寄存器实现的。
    reg[`RegBus] mstatus;       //全局中断使能和其他状态信息
    reg[`RegBus] mscratch;      //mscratch寄存器用于机器模式下的程序临时保存某些数据

    //cycle counter
    always @(posedge clk) begin
        if (!rstn) begin
            cycle <= {`ZeroWord,`ZeroWord};
        end
        else begin
            cycle <= cycle + 1'b1;
        end
    end

    //wirte csr_reg
    always @(posedge clk) begin
        if (!rstn) begin
            // mtvec     <= 32'd1;   
            // mcause    <= 32'd2;  
            // mepc      <= 32'd3;    
            // mie       <= 32'd4;     
            // mstatus   <= 32'd3; 
            // mscratch  <= 32'd9;
            mtvec     <= `ZeroWord;   
            mcause    <= `ZeroWord;  
            mepc      <= `ZeroWord;    
            mie       <= `ZeroWord;     
            mstatus   <= `ZeroWord; 
            mscratch  <= `ZeroWord;
        end
        else begin
            if(csr_wen_i == `Enable) begin
                case (csr_waddr_i[11:0])
                    `CSR_MTVEC    : mtvec    <= csr_wdata_i;
                    `CSR_MCAUSE   : mcause   <= csr_wdata_i;
                    `CSR_MEPC     : mepc     <= csr_wdata_i;
                    `CSR_MIE      : mie      <= csr_wdata_i;
                    `CSR_MSTATUS  : mstatus  <= csr_wdata_i;
                    `CSR_MSCRATCH : mscratch <= csr_wdata_i;
                    default:    ;
                endcase
            end
        end
    end

    //read csr_reg
    always @(*) begin
        if((csr_raddr_i[11:0] == csr_waddr_i[11:0]) && (csr_wen_i == `Enable)) begin
            csr_rdata_o = csr_wdata_i;
        end
        else begin
            case (csr_raddr_i[11:0]) 
                `CSR_CYCLE    : csr_rdata_o = cycle[31:0];
                `CSR_CYCLEH   : csr_rdata_o = cycle[63:32];
                `CSR_MTVEC    : csr_rdata_o = mtvec;
                `CSR_MCAUSE   : csr_rdata_o = mcause;
                `CSR_MEPC     : csr_rdata_o = mepc;
                `CSR_MIE      : csr_rdata_o = mie;
                `CSR_MSTATUS  : csr_rdata_o = mstatus;
                `CSR_MSCRATCH : csr_rdata_o = mscratch;
                default       : csr_rdata_o = `ZeroWord;
            endcase
        end    
    end
    
endmodule //csr_reg