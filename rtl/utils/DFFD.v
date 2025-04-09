`include "../defines.v"

module DFFD #(
        parameter WIDTH = 1
    ) (
        input  wire             clk     ,
        input  wire             rstn    ,
        input  wire             CE      ,
        input  wire [WIDTH-1:0] set_data,
        input  wire [WIDTH-1:0] d       ,
        output wire [WIDTH-1:0] q
    );

    DFF #(WIDTH) DFF_inst(
            .clk      (clk      ),
            .rstn     (rstn     ),
            .CE       (CE       ),
            .set_data (set_data ),
            .d        (d        ),
            .q        (q        )
        );

endmodule //DFFD
