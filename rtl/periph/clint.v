`include "../core/defines.v" 

module clint(
    input  wire clk,
    input  wire rstn,
    // swi
    input  wire swi_en,
    output wire swi_irq,
    // timer
    input  wire[31:0] timer_data_i,
    input  wire[31:0] timer_addr_i,
    input  wire timer_we,
    output wire [31:0] data_o,
    output wire timer_irq
);

// swi
reg [31:0] msip; // machine software interrupt

assign swi_irq = msip[0];

always @(posedge clk) begin
    if (!rstn) begin
        msip <= 32'b0;
    end 
    else if (swi_en) begin
        msip <= 32'b1;
    end 
    else begin
        msip <= 32'b0;
    end
end

// timer
timer timer_init(
    .clk(clk),
    .rstn(rstn),
    .data_i(timer_data_i),
    .addr_i(timer_addr_i),
    .we_i(timer_we),
    .data_o(data_o),
    .int_sig_o(timer_irq)
);

endmodule