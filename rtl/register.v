
module register (
        input  wire clk ,
        input  wire rstn,
        // from id
        input  wire [ 4:0]  rs1_raddr ,
        input  wire [ 4:0]  rs2_raddr ,
        // from ex
        input  wire [ 4:0]  rd_waddr  ,
        input  wire [31:0]  rd_wdata  ,
        input  wire         wen       ,
        // to id
        output reg  [31:0]  rs1_rdata ,
        output reg  [31:0]  rs2_rdata
    );

    reg [31:0] reg_mem [31:0];

    always @(*)
    begin
        if (!rstn)
            rs1_rdata = 32'd0;
        else if (rs1_raddr == 5'd0)
            rs1_rdata = 32'd0;
        else if(wen && (rs1_raddr == rd_waddr))
            rs1_rdata = rd_wdata;
        else
            rs1_rdata = reg_mem[rs1_raddr];
    end

    always @(*)
    begin
        if (!rstn)
            rs2_rdata = 32'd0;
        else if (rs2_raddr == 5'd0)
            rs2_rdata = 32'd0;
        else if(wen && (rs2_raddr == rd_waddr))
            rs2_rdata = rd_wdata;
        else
            rs2_rdata = reg_mem[rs2_raddr];
    end

    integer i;

    always @(posedge clk)
    begin
        if (!rstn)
            for (i = 0; i < 32; i = i + 1)
                reg_mem[i] <= 32'd0;
        else if(wen && (rd_waddr != 5'd0))
            reg_mem[rd_waddr] <= rd_wdata;
    end
endmodule
