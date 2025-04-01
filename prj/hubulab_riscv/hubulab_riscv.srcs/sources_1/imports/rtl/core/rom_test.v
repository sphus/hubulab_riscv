module rom_test(
    input wire clk,
    input wire rstn,

    // 主机信号
    input wire we_i,            // write enable
    input wire[31:0] addr_i,    // addr
    input wire[31:0] data_i,
    input wire       flag,      // 总线请求

    output reg [31:0] data_o     // read data
    );

    // 从机信号
    reg rom_we_i;
    reg [31:0] rom_addr_i;
    reg [31:0] rom_data_i;
    reg [31:0] rom_data_o;

    // 当flag && (addr_i[31:28] == 4'h0)时，将主机信号传递给从机
    always @ (*) begin
        if(flag && (addr_i[31:28] == 4'h0)) begin
            rom_we_i = we_i;
            rom_addr_i =  {{4'h0}, {addr_i[27:0]}};
            rom_data_i = data_i;
            data_o = rom_data_o;
        end
        else begin
            rom_we_i = 1'b0;
            rom_addr_i = 32'h0;
            rom_data_i = 32'h0;
            data_o = 32'h0;
        end
    end

    reg[31:0] _rom[0:4096 - 1];

    always @ (posedge clk) begin
        if (rom_we_i == 1'b1) begin
            _rom[rom_addr_i[31:2]] <= rom_data_i;
        end
    end

    always @ (*) begin
        if (rstn == 1'b0) begin
            rom_data_o = 32'h0;
        end 
        else begin
            rom_data_o = _rom[rom_addr_i[31:2]];
        end
    end
    
    // dual_ram #(
    //     .DW      	(32    ),
    //     .AW      	(32  ),
    //     .MEM_NUM 	(4096))
    // dual_ram_inst(
    //     .clk    	(clk         ),
    //     .rstn   	(1'b0),
    //     .wen    	(rom_we_i         ),
    //     .w_addr 	(rom_addr_i),// addr/4,because DW/8(byte) = 4
    //     .w_data 	(rom_data_i      ),
    //     .ren    	(1'b1         ),
    //     .r_addr 	(rom_addr_i),// addr/4,because DW/8(byte) = 4
    //     .r_data 	(rom_data_o      )
    // );
// 如果(flag && (addr_i[31:28] == 4'h0))这个条件不成立，则rom_we_i，rom_addr_i，rom_data_i，rom_data_o的值会改变吗

endmodule
