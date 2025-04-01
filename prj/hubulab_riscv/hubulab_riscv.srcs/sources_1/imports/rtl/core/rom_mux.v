module rom_mux #(
        parameter DW = 32,
        parameter AW = 32
    )
    (
        // jtag
        input   wire          jtag_flag    ,
        input   wire          jtag_wen     ,
        input   wire [AW-1:0] jtag_w_addr  ,
        input   wire [DW-1:0] jtag_w_data  ,
        output  wire [DW-1:0] jtag_r_data  ,
       
        // riscv
        input   wire [AW-1:0] inst_addr_rom,
        output  wire [DW-1:0] inst_rom     ,

        // rom
        output  wire          rom_wen      ,
        output  wire [AW-1:0] rom_w_addr   ,
        output  wire [DW-1:0] rom_w_data   ,
        output  wire          rom_ren      ,
        output  wire [AW-1:0] rom_r_addr   ,
        input   wire [DW-1:0] rom_r_data
    );
    
    // 写信号
    assign rom_wen =    (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? jtag_wen : 1'b0;
    assign rom_w_addr = (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? {{4'h0}, {jtag_w_addr[27:0]}} : {AW{1'b0}};     //感觉是地址的问题
    assign rom_w_data = (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? jtag_w_data : {DW{1'b0}};
    // 读信号
    assign rom_ren = 1'b1;
    // assign rom_r_addr = (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? {{4'h0}, {jtag_w_addr[27:0]}} : inst_addr_rom;
    assign rom_r_addr = inst_addr_rom;
    // 传入riscv的inst
    assign inst_rom = (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? {DW{1'b0}} : rom_r_data;
    // 传入jtag的r_data
    assign jtag_r_data = (jtag_flag && (jtag_w_addr[31:28] == 4'h0)) ? rom_r_data : {DW{1'b0}};

    // assign rom_wen =     1'b0;
    // assign rom_w_addr =  {AW{1'b0}};
    // assign rom_w_data =  {DW{1'b0}};
    // assign rom_ren = 1'b1;
    // assign inst_rom =  rom_r_data;
    // assign jtag_r_data =  {DW{1'b0}};
    // assign rom_r_addr = inst_addr_rom;

endmodule 
