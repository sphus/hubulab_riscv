
`include "defines.v" 
module DFF #(
        parameter WIDTH = 16
    ) (
        input  wire             clk     ,
        input  wire             rstn    ,
        input  wire             hold_flag,
        input  wire [WIDTH-1:0] set_data,
        input  wire [WIDTH-1:0] d       ,
        output reg  [WIDTH-1:0] q
    );
    reg [WIDTH-1:0] q_next;

    always @(*) begin
        if (rstn == `RstnEnable || hold_flag == `Enable)
            q_next = set_data;
        else
            q_next = d;
    end

    always @(posedge clk)
        q <= q_next;
        
endmodule
