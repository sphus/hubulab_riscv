
`include "../defines.v"
module wb (
        // data
        input  wire [`RegBus]          WB_mem_rdata,
        input  wire [`RegBus]          WB_result   ,
        // control
        input  wire                    WB_rmem     ,

        // data
        output wire [`RegBus]          WB_rd_data   

    );

    assign WB_rd_data = WB_rmem ? WB_mem_rdata : WB_result;

endmodule
