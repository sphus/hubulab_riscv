
`include "../defines.v"
module wb (
        // data
        input  wire [`RegBus]          mem_rdata,
        input  wire [`RegBus]          result   ,
        // control
        input  wire                    rmem     ,

        // data
        output wire [`RegBus]          rd_data   

    );

    assign rd_data = rmem ? mem_rdata : result;

endmodule
