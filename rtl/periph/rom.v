
`include "../defines.v"

module rom #(
        parameter DW = 32,
        parameter AW = 32,
        parameter MEM_NUM = 2**12
    )
    (
        input   wire            clk   ,
        input   wire 			rstn  ,
        input   wire 			wen   ,
        input   wire [`RegBus]  w_addr,
        input   wire [`RegBus]  w_data,
        input   wire 			ren   ,
        input   wire [`RegBus]	r_addr,
        output  reg  [`RegBus]  r_data
    );

    reg[DW-1:0] memory[0:MEM_NUM-1];

`ifdef COMBINATION_ROM
    always @(*)
            r_data = memory[r_addr >> 2];
`else
    always @(posedge clk)
        if(ren)
            r_data <= memory[r_addr >> 2];
`endif

    always @(posedge clk)
    begin
        if(wen)
            memory[w_addr >> 2] <= w_data;
    end

endmodule
