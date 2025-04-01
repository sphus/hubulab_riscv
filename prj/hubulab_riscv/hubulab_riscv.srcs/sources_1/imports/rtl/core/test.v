module test(
    input wire clk,
    input wire rstn,
    input wire jtag_halt_i,

    // tset
    output wire jtag_halt_o,    // jtag是否已经halt住CPU信号
    output reg  over,           // 测试是否完成信号
    output reg  pass            // 测试是否成功信号
);

    assign jtag_halt_o = ~jtag_halt_i;

    always @ (posedge clk) begin
        if (!rstn) begin
            over <= 1'b1;
            pass <= 1'b1;
        end 
        else begin
            over <= ~riscv_inst.register_inst.reg_mem[26];  // when = 1, run over
            pass <= ~riscv_inst.register_inst.reg_mem[27];  // when = 1, run pass, otherwise fail
        end
    end

endmodule
