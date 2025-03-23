`include "../defines.v"

module ram_interface (
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
        output wire                 ren
    );

    assign addr =  mem_addr;
    assign ren  = rmem;


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
        case (mem_type)
            `LS_B    :
            begin
                case (mem_addr[1:0])
                    2'd0:
                        mem_rdata = {{24{r_data[ 7]& ~mem_sign}},r_data[ 7: 0]};
                    2'd1:
                        mem_rdata = {{24{r_data[15]& ~mem_sign}},r_data[15: 8]};
                    2'd2:
                        mem_rdata = {{24{r_data[23]& ~mem_sign}},r_data[23:16]};
                    2'd3:
                        mem_rdata = {{24{r_data[31]& ~mem_sign}},r_data[31:24]};
                    default:
                        mem_rdata = `ZeroWord;
                endcase
            end
            `LS_H    :
            begin
                case (mem_addr[1])
                    1'b0:
                        mem_rdata = {{16{r_data[15]& ~mem_sign}},r_data[15: 0]};
                    1'b1:
                        mem_rdata = {{16{r_data[31]& ~mem_sign}},r_data[31:16]};
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
