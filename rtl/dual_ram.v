
module dual_ram #(
        parameter DW = 32,
        parameter AW = 12,
        parameter DEPTH = 4096
    )(
        input  wire             clk   ,
        input  wire             rstn  ,
        input  wire             w_en  ,
        input  wire             r_en  ,
        input  wire [AW-1:0]    w_addr,
        input  wire [DW-1:0]    w_data,
        input  wire [AW-1:0]    r_addr,
        output reg  [DW-1:0]    r_data,
    );

    reg [DW-1:0] ram [0:DEPTH-1];

    always @(posedge clk) begin
        if (w_en)
            ram[w_addr] <= w_data;
    end

    always @(posedge clk) begin
        if (r_en)
            r_data <= ram[r_addr];
    end

endmodule
