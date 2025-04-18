`include "../defines.v"

module riscv(
        input  wire                 clk             ,
        input  wire                 rstn            ,
        input  wire                 busy            ,
        input  wire [`RegBus]       inst_rom        ,
        output wire [`RegBus]       inst_addr_rom   ,

        input  wire [`RegBus]       mem_rdata       ,
        output wire [`RegBus]       mem_wdata       ,
        output wire [`RegBus]       mem_addr        ,
        output wire [`mem_type_bus] mem_type        ,
        output wire                 mem_sign        ,
        output wire                 rmem            ,
        output wire                 wmem			,

        // jtag
        input  wire					halt_req_i		,
        input  wire					reset_req_i
    );

    // ------------------- HAZARD DETECTION ------------------- //
    wire [`Hold_Bus     ]   hold;
    wire                    jump;
    wire [`Flush_Bus    ]   flush;
    // ------------------- HAZARD DETECTION ------------------- //

    // -------------------------- ID -------------------------- //
    // data
    wire [`RegBus       ]   inst         ;
    wire [`RegBus       ]   inst_addr    ;
    wire [`RegAddrBus   ]   rs1_addr     ;
    wire [`RegAddrBus   ]   rs2_addr     ;
    wire [`RegAddrBus   ]   rd_addr      ;
    wire [`RegBus       ]   rs1_data     ;
    wire [`RegBus       ]   rs2_data     ;

    // control
    wire                    wen          ;  // register write enable
    wire                    jmp          ;  // Jump
    wire                    jcc          ;  // Jump on Condition
    wire [`ALU_ctrl_bus ]   alu_ctrl     ;  // ALU Control
    wire                    jal          ;  // JAL  Instruction
    wire                    jalr         ;  // JALR Instruction
    wire                    lui          ;  // LUI Instruction
    wire                    auipc        ;  // AUIPC Instruction
    wire                    inst_R       ;  // INST TYPE R
    wire                    sign         ;  // ALU SIGN
    wire                    sub          ;  // ALU SUB
    wire [`RegBus       ]   imm          ;  // immediate
    wire [`StateBus     ]   state       ;  // immediate
    wire                    JC          ;  // ALU SUB
    // -------------------------- ID -------------------------- //

    // -------------------------- EX -------------------------- //
    // data
    wire [`RegBus       ]   result       ;
    wire [`RegBus       ]   jump_addr    ;
    wire [`RegBus]          rd_data      ;
    // -------------------------- EX -------------------------- //


    wire [`Hold_Bus] halt_req = {`Hold_num{halt_req_i}};
    wire reset_req = reset_req_i;

    pc pc_inst(
           .clk         (clk            ),
           .rstn        (rstn|reset_req ),
           .hold        (hold|halt_req  ),
           .jump        (jump           ),
           .jump_addr   (jump_addr      ),
           .pc          (inst_addr_rom  )
       );


`ifdef COMBINATION_ROM
       assign inst_addr = inst_addr_rom;
       assign inst = inst_rom;
`else

    if_id if_id_inst(
              .clk      (clk            ),
              .rstn     (rstn           ),
              .hold     (hold|halt_req  ),
              .flush    (flush          ),
              .inst_i   (inst_rom       ),
              .addr_i   (inst_addr_rom  ),
              .inst_o   (inst           ),
              .addr_o   (inst_addr      )
          );
`endif


    // 分线
    // assign  rs1_addr  = inst[19:15];
    // assign  rs2_addr  = inst[24:20];
    // assign  rd_addr   = inst[11: 7];

    wire  [`sw_imm_bus]   imm_ctrl    ;   // Immediate Control

    control control_inst(
                .clk        (clk        ),
                .rstn       (rstn       ),
                .hold       (hold       ),
                .inst       (inst       ),
                .JC         (JC         ),
                .imm_ctrl   (imm_ctrl   ),
                .rs1_addr   (rs1_addr   ),
                .rs2_addr   (rs2_addr   ),
                .rd_addr    (rd_addr    ),
                .rmem       (rmem       ),
                .wmem       (wmem       ),
                .wen        (wen        ),
                .jmp        (jmp        ),
                .jcc        (jcc        ),
                .alu_ctrl   (alu_ctrl   ),
                .jal        (jal        ),
                .jalr       (jalr       ),
                .lui        (lui        ),
                .auipc      (auipc      ),
                .inst_R     (inst_R     ),
                .mem_type   (mem_type   ),
                .mem_sign   (mem_sign   ),
                .sign       (sign       ),
                .sub        (sub        ),
                .state      (state      ),
                .jump       (jump       )
            );

    imm_gen imm_gen_inst(
                .inst     (inst     ),
                .imm_ctrl (imm_ctrl ),
                .imm      (imm      )
            );

    register register_inst(
                 .clk       (clk        ),
                 .rstn      (rstn       ),
                 .rs1_raddr (rs1_addr   ),
                 .rs2_raddr (rs2_addr   ),
                 .rd_waddr  (rd_addr    ),
                 .rd_wdata  (rd_data    ),
                 .wen       (wen        ),
                 .rs1_data  (rs1_data   ),
                 .rs2_data  (rs2_data   )
             );

    ex ex_inst(
           .inst_addr (inst_addr),
           .rs1_data  (rs1_data ),
           .rs2_data  (rs2_data ),
           .imm       (imm      ),
           .alu_ctrl  (alu_ctrl ),
           .alu_sel   (alu_sel  ),
           .sign      (sign     ),
           .sub       (sub      ),
           .result    (result   ),
           .JC        (JC       )
       );

    // MEM_inst
    assign mem_addr     = result;
    assign mem_wdata    = rs2_data;

    wb wb_inst(
           .mem_rdata (mem_rdata ),
           .result    (result    ),
           .rmem      (rmem      ),
           .rd_data   (rd_data   )
       );

    hazard_detection hazard_detection_inst(
                         .clk     (clk      ),
                         .rstn    (rstn     ),
                         .jump    (jump     ),
                         .ID_rs1  (rs1_addr ),
                         .ID_rs2  (rs2_addr ),
                         .EX_rd   (rd_addr  ),
                         .EX_rmem (rmem     ),
                         .busy    (busy     ),
                         .hold    (hold     ),
                         .flush   (flush    )
                     );

endmodule

