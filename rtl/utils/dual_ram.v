//读写冲突 等于新值的 双端口ram
module dual_ram #(
        parameter DW = 32,
        parameter AW = 32,
        parameter MEM_NUM = 4096
    )
    (
        input   wire            clk   ,
        input   wire 			rstn  ,
        input   wire 			wen   ,
        input   wire [AW-1:0]	w_addr,
        input   wire [DW-1:0]   w_data,
        input   wire 			ren   ,
        input   wire [AW-1:0]	r_addr,
        // output  wire [DW-1:0]   r_data
        output  reg  [DW-1:0]   r_data
    );

    reg[DW-1:0] memory[0:MEM_NUM-1];

    // read ram
    always @(posedge clk)
    begin
        if(ren)
            if (wen && (w_addr == r_addr))
                r_data <= w_data;
            else
                r_data <= memory[r_addr];
    end

    // write ram
    always @(posedge clk) begin
        if(wen)
            memory[w_addr] <= w_data;
    end

endmodule
