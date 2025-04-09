`include "../defines.v"

module ram_interface (
        input  wire                 clk         ,
        input  wire                 rstn        ,


        output reg  [`RegBus]       mem_rdata   ,
        input  wire [`RegBus]       mem_wdata   ,
        input  wire [`RegBus]       mem_addr    ,
        input  wire [`mem_type_bus] mem_type    ,
        input  wire                 mem_sign    ,
        input  wire                 rmem        ,
        input  wire                 wmem        ,

        input  wire [`RegBus]       r_data      ,
        output reg  [`RegBus]       w_data      ,
        output wire [`RegBus]       addr        ,
        output reg  [3:0]           wen         ,
        output wire                 busy        ,
        output wire                 ren
    );

    assign addr =  mem_addr;
    assign ren  = rmem;

    reg busy_buff;

    always @(posedge clk or negedge rstn)
    begin
        if (!rstn)
            busy_buff <= `Disable;
        else
            busy_buff <= rmem;
    end

    assign busy = ~busy_buff & rmem;

    reg [`mem_type_bus] type_reg;
    reg [1:0]   addr_reg;
    reg         sign_reg;



    // always @(posedge clk) begin
    //     busy <= rstn ? rmem : `Disable;
    // end

    always @(posedge clk)
    begin
        type_reg <= rstn ? mem_type : `LS_B;
    end

    always @(posedge clk)
    begin
        addr_reg <= rstn ? mem_addr[1:0] : `ZeroWord;
    end

    always @(posedge clk)
    begin
        sign_reg <= rstn ? mem_sign : `Disable;
    end

    always @(*)
    begin
        if (wmem)
        begin
            case (mem_type)
                `LS_B:
                case (mem_addr[1:0])
                    2'd0:
                        {wen,w_data} = {4'b0001,24'b0,mem_wdata[7:0]};
                    2'd1:
                        {wen,w_data} = {4'b0010,16'b0,mem_wdata[7:0],8'b0};
                    2'd2:
                        {wen,w_data} = {4'b0100,8'b0,mem_wdata[7:0],16'b0};
                    2'd3:
                        {wen,w_data} = {4'b1000,mem_wdata[7:0],24'b0};
                    default:
                        {wen,w_data} = {4'b0000,`ZeroWord};
                endcase
                `LS_H:
                case (mem_addr[1])
                    1'd0:
                        {wen,w_data} = {4'b0011,16'b0,mem_wdata[15: 0]};
                    1'd1:
                        {wen,w_data} = {4'b1100,mem_wdata[15: 0],16'b0};
                    default:
                        {wen,w_data} = {4'b0000,`ZeroWord};
                endcase
                `LS_W:
                    {wen,w_data} = {4'b1111,mem_wdata};
                default:
                    {wen,w_data} = {4'b0000,`ZeroWord};
            endcase
        end
        else
            {wen,w_data} = {4'b0000,`ZeroWord};
    end

    always @( *)
    begin
        case (type_reg)
            `LS_B    :
            begin
                case (addr_reg[1:0])
                    2'd0:
                        mem_rdata = {{24{r_data[ 7]& ~sign_reg}},r_data[ 7: 0]};
                    2'd1:
                        mem_rdata = {{24{r_data[15]& ~sign_reg}},r_data[15: 8]};
                    2'd2:
                        mem_rdata = {{24{r_data[23]& ~sign_reg}},r_data[23:16]};
                    2'd3:
                        mem_rdata = {{24{r_data[31]& ~sign_reg}},r_data[31:24]};
                    default:
                        mem_rdata = `ZeroWord;
                endcase
            end
            `LS_H    :
            begin
                case (addr_reg[1])
                    1'b0:
                        mem_rdata = {{16{r_data[15]& ~sign_reg}},r_data[15: 0]};
                    1'b1:
                        mem_rdata = {{16{r_data[31]& ~sign_reg}},r_data[31:16]};
                    default:
                        mem_rdata = `ZeroWord;
                endcase
            end
            `LS_W    :
                mem_rdata = r_data;
            default     :
                mem_rdata = `ZeroWord;
        endcase
    end


endmodule //ram_interface
