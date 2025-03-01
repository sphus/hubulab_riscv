module riscv_soc (
        input  wire clk ,
        input  wire rstn
    );

    wire [31:0] inst_addr_rom   ;
    wire [31:0] inst_rom        ;
    rom rom_inst(
            .addr_i(inst_addr_rom   ),
            .inst_o(inst_rom        )
        );

    riscv riscv_inst(
              .clk          (clk            ),
              .rstn         (rstn           ),
              .inst_rom     (inst_rom       ),
              .inst_addr_rom(inst_addr_rom  )
          );
endmodule
