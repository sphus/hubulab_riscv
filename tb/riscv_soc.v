module riscv_soc (
        input  wire clk ,
        input  wire rstn
    );

    wire [31:0] inst_addr_rom   ;
    wire [31:0] inst_rom        ;

    // output declaration of module rom
    wire [12-1:0] r_data;

    parameter DW = 32;
    parameter AW = 32;

    rom #(
            .DW      	(DW    ),
            .AW      	(AW    ),
            .MEM_NUM 	(4096  ))
        rom_inst(
            .clk    	(clk            ),
            .rstn   	(rstn           ),
            .wen    	(1'b0           ),
            .w_addr 	({AW{1'b0}}     ),
            .w_data 	({DW{1'b0}}     ),
            .ren    	(1'b1           ),
            .r_addr 	(inst_addr_rom  ),
            .r_data 	(inst_rom       )
        );



    riscv riscv_inst(
              .clk          (clk            ),
              .rstn         (rstn           ),
              .inst_rom     (inst_rom       ),
              .inst_addr_rom(inst_addr_rom  )
          );
endmodule
