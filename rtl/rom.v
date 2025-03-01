module rom (
        input  wire [31:0]  addr_i,
        output wire [31:0]  inst_o
    );
    reg [31:0]  rom_mem [1023:0];
    assign inst_o = rom_mem[addr_i >> 2];

endmodule
