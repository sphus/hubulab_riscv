
`include "../defines.v" 
module register (
        input  wire clk ,
        input  wire rstn,
        // from id
        input  wire [`RegAddrBus]   rs1_raddr ,
        input  wire [`RegAddrBus]   rs2_raddr ,
        // from ex
        input  wire [`RegAddrBus]   rd_waddr  ,
        input  wire [`RegBus]       rd_wdata  ,
        input  wire                 wen       ,
        // to id
        output reg  [`RegBus]       rs1_data ,
        output reg  [`RegBus]       rs2_data
    );

    reg [`RegBus] reg_mem [`RegBus];

    // read register 1
    always @(*)
    begin
        if (!rstn)
            rs1_data = `ZeroWord;
        else if (rs1_raddr == `ZeroReg)
            rs1_data = `ZeroWord;
        // else if(wen && (rs1_raddr == rd_waddr))
        //     rs1_data = rd_wdata;
        else
            rs1_data = reg_mem[rs1_raddr];
    end

    // read register 2
    always @(*)
    begin
        if (!rstn)
            rs2_data = `ZeroWord;
        else if (rs2_raddr == `ZeroReg)
            rs2_data = `ZeroWord;
        // else if(wen && (rs2_raddr == rd_waddr))
        //     rs2_data = rd_wdata;
        else
            rs2_data = reg_mem[rs2_raddr];
    end

    integer i;

    // write register 1
    always @(posedge clk)
    begin
        if (!rstn)
            for (i = 0; i < 32; i = i + 1)
                reg_mem[i] <= `ZeroWord;
        else if(wen && (rd_waddr != `ZeroReg))
            reg_mem[rd_waddr] <= rd_wdata;
    end
    
endmodule
