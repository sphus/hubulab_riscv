
module rom #(
        parameter DW = 32,
        parameter AW = 32,
        parameter MEM_NUM = 2**12
    )
    (
        input   wire            clk   ,
        input   wire 			rstn  ,
        input   wire 			wen   ,
        input   wire [32-1:0]	w_addr,
        input   wire [32-1:0]   w_data,
        input   wire 			ren   ,
        input   wire [32-1:0]	r_addr,
        output  wire [32-1:0]   r_data
    );

    dual_ram #(
                 .DW      	(DW    ),
                 .AW      	(AW-2  ),
                 .MEM_NUM 	(MEM_NUM))
             dual_ram_inst(
                 .clk    	(clk     ),
                 .rstn   	(1'b1    ),
                 .rstn_data ({DW{1'b0}}),
                 .wen    	(wen     ),
                 .w_addr 	(w_addr[31:2]),// addr/4,because DW/8(byte) = 4
                 .w_data 	(w_data  ),
                 .ren    	(ren     ),
                 .r_addr 	(r_addr[31:2]),// addr/4,because DW/8(byte) = 4
                 .r_data 	(r_data  )
             );

endmodule
