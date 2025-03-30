
`include "../core/defines.v" 
module rom #(
        parameter DW = 32,
        parameter AW = 32,
        parameter MEM_NUM = 2**12
    )
    (
        input   wire            clk      ,
        input   wire 			rstn     ,
        input   wire 			wen      ,
        input   wire [AW-1:0]   w_addr   ,
        input   wire [DW-1:0]   w_data   ,
        input   wire 			ren      ,
        input   wire [AW-1:0]	r_addr   ,
        output  wire [DW-1:0]   r_data
    );

    dual_ram #(
                 .DW      	(DW    ),
                 .AW      	(AW-2  ),
                 .MEM_NUM 	(MEM_NUM))
             dual_ram_inst(
                 .clk    	(clk         ),
                 // 这样不会导致读写同一地址会出现问题吗
                // .rstn   	(`RstnEnable ),
                 .rstn   	(rstn ),                 
                 .wen    	(wen         ),
                 .w_addr 	(w_addr[31:2]),// addr/4,because DW/8(byte) = 4
                 .w_data 	(w_data      ),
                 .ren    	(ren         ),
                 .r_addr 	(r_addr[31:2]),// addr/4,because DW/8(byte) = 4
                 .r_data 	(r_data      )
             );

endmodule
