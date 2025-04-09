`include "../defines.v"

module DFFC #(
        parameter WIDTH = 1
    ) (
        input  wire             clk     ,
        input  wire             rstn    ,
        input  wire             flush   ,
        input  wire             CE      ,
        input  wire [WIDTH-1:0] set_data,
        input  wire [WIDTH-1:0] d       ,
        output wire [WIDTH-1:0] q
    );

    wire [WIDTH-1:0] data_in = flush ? set_data : d;

    DFF #(WIDTH) DFF_inst(
            .clk      (clk      ),
            .rstn     (rstn     ),
            .CE       (CE       ),
            .set_data (set_data ),
            .d        (data_in  ),
            .q        (q        )
        );

endmodule //DFFC
