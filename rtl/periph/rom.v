
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

    // dual_ram #(
    //              .DW      	(DW    ),
    //              .AW      	(AW-2  ),
    //              .MEM_NUM 	(MEM_NUM))
    //          dual_ram_inst(
    //              .clk    	(clk        ),
    //              .rstn   	(`RstnEnable),
    //              .wen    	(wen        ),
    //              .w_addr 	(w_addr[31:2]),// addr/4,because DW/8(byte) = 4
    //              .w_data 	(w_data     ),
    //              .ren    	(ren        ),
    //              .r_addr 	(r_addr[31:2]),// addr/4,because DW/8(byte) = 4
    //              .r_data 	(r_data     )
    //          );


    reg[DW-1:0] memory[0:MEM_NUM-1];


    always @(posedge clk) begin
        if(ren)
            r_data <= memory[r_addr];
    end

    always @(posedge clk) begin
        // if(rstn && wen)
        if(wen)
            memory[w_addr] <= w_data;
    end

endmodule
