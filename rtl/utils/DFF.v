`include "../defines.v"

module DFF #(
        parameter WIDTH = 1
    ) (
        input  wire             clk     ,
        input  wire             rstn    ,
        input  wire             CE      ,
        input  wire [WIDTH-1:0] set_data,
        input  wire [WIDTH-1:0] d       ,
        output reg  [WIDTH-1:0] q
    );

    always @(posedge clk)
    begin
        if (rstn == `RstnEnable)
            q <= set_data;
        else if (CE)
            q <= d;
        else
            q <= q;
    end

endmodule //DFF
