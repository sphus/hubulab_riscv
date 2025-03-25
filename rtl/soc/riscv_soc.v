`include "../defines.v"
module riscv_soc (
        input  wire clk ,
        input  wire rstn,
        output wire start
    );

    parameter DW = 32;
    parameter AW = 32;

    wire [31:0] inst_addr_rom   ;
    wire [31:0] inst_rom        ;

    assign start = (inst_addr_rom != `ZeroWord);
    wire [`RegBus]          mem_rdata   ;
    wire [`RegBus]          mem_wdata   ;
    wire [`RegBus]          mem_addr    ;
    wire [`mem_type_bus]    mem_type    ;
    wire                    mem_sign    ;
    wire                    rmem        ;
    wire                    wmem        ;
    wire [`RegBus]          addr        ;

    wire [3:0]		        wen         ;
    wire [AW-1:0]	        w_addr      ;
    wire [DW-1:0]           w_data      ;
    wire 			        ren         ;
    wire [AW-1:0]	        r_addr      ;
    wire [DW-1:0]           r_data      ;



    riscv riscv_inst(
              .clk           (clk           ),
              .rstn          (rstn          ),
              .inst_rom      (inst_rom      ),
              .inst_addr_rom (inst_addr_rom ),
              .mem_rdata     (mem_rdata     ),
              .mem_wdata     (mem_wdata     ),
              .mem_addr      (mem_addr      ),
              .mem_type      (mem_type      ),
              .mem_sign      (mem_sign      ),
              .rmem          (rmem          ),
              .wmem          (wmem          )
          );


    rom #(
            .DW      	(DW    ),
            .AW      	(AW    ),
            .MEM_NUM 	(2**12  ))
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


    ram_interface ram_interface_inst(
                      .clk      (clk        ),
                      .rstn     (rstn       ),
                      .mem_rdata(mem_rdata  ),
                      .mem_wdata(mem_wdata  ),
                      .mem_addr (mem_addr   ),
                      .mem_type (mem_type   ),
                      .mem_sign (mem_sign   ),
                      .rmem     (rmem       ),
                      .wmem     (wmem       ),
                      .r_data   (r_data     ),
                      .w_data   (w_data     ),
                      .addr     (addr       ),
                      .wen      (wen        ),
                      .ren      (ren        )
                  );


    ram  #(
             .DW      	(DW    ),
             .AW      	(AW    ),
             .MEM_NUM 	(2**13  ))
         ram_inst(
             .clk    (clk    ),
             .rstn   (rstn   ),
             .wen    (wen    ),
             .w_addr (addr   ),
             .w_data (w_data ),
             .ren    (ren    ),
             .r_addr (addr   ),
             .r_data (r_data )
         );



endmodule
