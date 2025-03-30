`include "../defines.v"

module riscv(
        input  wire                 clk             ,
        input  wire                 rstn            ,

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
    wire nop;
    wire jump;
    // ------------------- HAZARD DETECTION ------------------- //

    // ----------------------- FORWAED ------------------------ //
    wire [`FwdBus    ]      fwd_rs1         ;
    wire [`FwdBus    ]      fwd_rs2         ;
    // ----------------------- FORWAED ------------------------ //

    // -------------------------- ID -------------------------- //
    // data
    // wire [`RegBus]          pc              ;
    wire [`RegBus]          ID_inst         ;
    wire [`RegBus]          ID_inst_addr    ;
    wire [`RegAddrBus]      ID_rs1_addr     ;
    wire [`RegAddrBus]      ID_rs2_addr     ;
    wire [`RegAddrBus]      ID_rd_addr      ;
    wire [`RegBus]          ID_rs1_data     ;
    wire [`RegBus]          ID_rs2_data     ;

    // control
    wire                    ID_rmem         ;    // memory   read  enable
    wire                    ID_wmem         ;    // memory   write enable
    wire                    ID_wen          ;    // register write enable
    wire                    ID_jmp          ;    // Jump
    wire                    ID_jcc          ;    // Jump on Condition
    wire [`ALU_ctrl_bus]    ID_alu_ctrl     ;    // ALU Control
    wire                    ID_jal          ;    // JAL  Instruction
    wire                    ID_jalr         ;    // JALR Instruction
    wire                    ID_lui          ;    // LUI Instruction
    wire                    ID_auipc        ;    // AUIPC Instruction
    wire                    ID_inst_R       ;   // INST TYPE R

    wire [`mem_type_bus]    ID_mem_type     ;    // load/store data type
    wire                    ID_mem_sign     ;    // load/store data sign
    wire                    ID_sign         ;    // ALU SIGN
    wire                    ID_sub          ;    // ALU SUB
    wire [`RegBus]          ID_imm          ;    // immediate
    // -------------------------- ID -------------------------- //

    // -------------------------- EX -------------------------- //
    // data
    wire [`RegBus]          EX_inst_addr    ;
    wire [`RegAddrBus]      EX_rs1_addr     ;
    wire [`RegAddrBus]      EX_rs2_addr     ;
    wire [`RegAddrBus]      EX_rd_addr      ;
    wire [`RegBus]          EX_result       ;
    wire [`RegBus]          EX_FD_rs2_data  ;
    wire [`RegBus]          EX_rs1_data     ;
    wire [`RegBus]          EX_rs2_data     ;
    wire [`RegBus]          EX_jump_addr    ;
    // control
    wire                    EX_rmem         ;    // memory   read  enable
    wire                    EX_wmem         ;    // memory   write enable
    wire                    EX_wen          ;    // register write enable
    wire                    EX_jmp          ;    // Jump
    wire                    EX_jcc          ;    // Jump on Condition
    wire                    EX_jump         ;    // Jump Signal
    wire [`ALU_ctrl_bus]    EX_alu_ctrl     ;    // ALU Control
    wire                    EX_jal          ;    // JAL  Instruction
    wire                    EX_jalr         ;    // JALR Instruction
    wire                    EX_lui          ;    // LUI Instruction
    wire                    EX_auipc        ;    // AUIPC Instruction
    wire                    EX_inst_R       ;    // INST TYPE R
    wire [`mem_type_bus]    EX_mem_type     ;    // load/store data type
    wire                    EX_mem_sign     ;    // load/store data sign
    wire                    EX_sign         ;    // ALU SIGN
    wire                    EX_sub          ;    // ALU SUB
    wire [`RegBus]          EX_imm          ;    // immediate
    // -------------------------- EX -------------------------- //

    // -------------------------- MEM-------------------------- //
    wire [`RegBus]          MEM_jump_addr   ;
    wire [`RegBus]          MEM_result      ;
    wire [`RegBus]          MEM_FD_rs2_data ;
    wire [`RegAddrBus]      MEM_rd_addr     ;
    wire                    MEM_rmem        ;
    wire                    MEM_wmem        ;
    wire                    MEM_wen         ;
    wire [`mem_type_bus]    MEM_mem_type    ;
    wire                    MEM_mem_sign    ;
    // -------------------------- MEM ------------------------- //

    // -------------------------- WB -------------------------- //
    wire [`RegBus]          WB_mem_rdata    ;
    wire [`RegBus]          WB_result       ;
    wire [`RegAddrBus]      WB_rd_addr      ;
    wire                    WB_rmem         ;
    wire                    WB_wen          ;
    wire [`RegBus]          WB_rd_data      ;
    // -------------------------- WB -------------------------- //

    pc pc_inst(
           .clk       (clk           ),
           .rstn      (rstn|reset_req_i),
           .nop       (nop|halt_req_i),
           .jump      (jump          ),
           .jump_addr (MEM_jump_addr ),
           .pc        (inst_addr_rom )
       );


    if_id if_id_inst(
              .clk    (clk             ),
              .rstn   (rstn            ),
              .nop    (nop|halt_req_i  ),
              .jump   (jump            ),
              .inst_i (inst_rom        ),
              .addr_i (inst_addr_rom   ),
              .inst_o (ID_inst         ),
              .addr_o (ID_inst_addr    )
          );

    id_unit id_unit_inst(
                .inst       (ID_inst    ),
                .rs1_addr_o (ID_rs1_addr),
                .rs2_addr_o (ID_rs2_addr),
                .rmem       (ID_rmem    ),
                .wmem       (ID_wmem    ),
                .wen        (ID_wen     ),
                .jmp        (ID_jmp     ),
                .jcc        (ID_jcc     ),
                .alu_ctrl   (ID_alu_ctrl),
                .jal        (ID_jal     ),
                .jalr       (ID_jalr    ),
                .lui        (ID_lui     ),
                .auipc      (ID_auipc   ),
                .inst_R     (ID_inst_R  ),
                .mem_type   (ID_mem_type),
                .mem_sign   (ID_mem_sign),
                .sign       (ID_sign    ),
                .sub        (ID_sub     ),
                .imm        (ID_imm     ),
                .rd_addr_o  (ID_rd_addr )
            );

    register register_inst(
                 .clk       (clk        ),
                 .rstn      (rstn       ),
                 .rs1_raddr (ID_rs1_addr),
                 .rs2_raddr (ID_rs2_addr),
                 .rd_waddr  (WB_rd_addr ),
                 .rd_wdata  (WB_rd_data ),
                 .wen       (WB_wen     ),
                 .rs1_rdata (ID_rs1_data),
                 .rs2_rdata (ID_rs2_data)
             );

    id_ex id_ex_inst(
              .clk          (clk          ),
              .rstn         (rstn         ),
              .nop          (nop|halt_req_i),
              .jump         (jump         ),
              .ID_inst_addr (ID_inst_addr ),
              .ID_rs1_addr  (ID_rs1_addr  ),
              .ID_rs2_addr  (ID_rs2_addr  ),
              .ID_rd_addr   (ID_rd_addr   ),
              .ID_rs1_data  (ID_rs1_data  ),
              .ID_rs2_data  (ID_rs2_data  ),
              .ID_rmem      (ID_rmem      ),
              .ID_wmem      (ID_wmem      ),
              .ID_wen       (ID_wen       ),
              .ID_jmp       (ID_jmp       ),
              .ID_jcc       (ID_jcc       ),
              .ID_alu_ctrl  (ID_alu_ctrl  ),
              .ID_jalr      (ID_jalr      ),
              .ID_jal       (ID_jal       ),
              .ID_lui       (ID_lui       ),
              .ID_auipc     (ID_auipc       ),
              .ID_inst_R    (ID_inst_R    ),
              .ID_mem_type  (ID_mem_type  ),
              .ID_mem_sign  (ID_mem_sign  ),
              .ID_sign      (ID_sign      ),
              .ID_sub       (ID_sub       ),
              .ID_imm       (ID_imm       ),
              .EX_inst_addr (EX_inst_addr ),
              .EX_rs1_addr  (EX_rs1_addr  ),
              .EX_rs2_addr  (EX_rs2_addr  ),
              .EX_rd_addr   (EX_rd_addr   ),
              .EX_rs1_data  (EX_rs1_data  ),
              .EX_rs2_data  (EX_rs2_data  ),
              .EX_rmem      (EX_rmem      ),
              .EX_wmem      (EX_wmem      ),
              .EX_wen       (EX_wen       ),
              .EX_jmp       (EX_jmp       ),
              .EX_jcc       (EX_jcc       ),
              .EX_alu_ctrl  (EX_alu_ctrl  ),
              .EX_jal       (EX_jal       ),
              .EX_jalr      (EX_jalr      ),
              .EX_lui       (EX_lui       ),
              .EX_auipc     (EX_auipc       ),
              .EX_inst_R    (EX_inst_R    ),
              .EX_mem_type  (EX_mem_type  ),
              .EX_mem_sign  (EX_mem_sign  ),
              .EX_sign      (EX_sign      ),
              .EX_sub       (EX_sub       ),
              .EX_imm       (EX_imm       )
          );

    ex ex_inst(
           .EX_inst_addr   (EX_inst_addr    ),
           .EX_rs1_data    (EX_rs1_data     ),
           .EX_rs2_data    (EX_rs2_data     ),
           .MEM_rd_data    (MEM_result      ),
           .WB_rd_data     (WB_rd_data      ),
           .fwd_rs1        (fwd_rs1         ),
           .fwd_rs2        (fwd_rs2         ),
           .EX_rmem        (EX_rmem         ),
           .EX_wmem        (EX_wmem         ),
           .EX_jmp         (EX_jmp          ),
           .EX_jcc         (EX_jcc          ),
           .EX_alu_ctrl    (EX_alu_ctrl     ),
           .EX_jal         (EX_jal          ),
           .EX_jalr        (EX_jalr         ),
           .EX_lui         (EX_lui          ),
           .EX_auipc        (EX_auipc       ),
           .EX_inst_R      (EX_inst_R       ),
           .EX_sign        (EX_sign         ),
           .EX_sub         (EX_sub          ),
           .EX_imm         (EX_imm          ),
           .EX_jump_addr   (EX_jump_addr    ),
           .EX_result      (EX_result       ),
           .EX_FD_rs2_data (EX_FD_rs2_data  ),
           .EX_jump        (EX_jump         )
       );



    ex_mem ex_mem_inst(
               .clk             (clk            ),
               .rstn            (rstn           ),
               .jump            (jump           ),
               .EX_jump_addr    (EX_jump_addr   ),
               .EX_result       (EX_result      ),
               .EX_FD_rs2_data  (EX_FD_rs2_data ),
               .EX_rd_addr      (EX_rd_addr     ),
               .EX_rmem         (EX_rmem        ),
               .EX_wmem         (EX_wmem        ),
               .EX_wen          (EX_wen         ),
               .EX_mem_type     (EX_mem_type    ),
               .EX_mem_sign     (EX_mem_sign    ),
               .EX_jump         (EX_jump        ),
               .MEM_jump_addr   (MEM_jump_addr  ),
               .MEM_result      (MEM_result     ),
               .MEM_FD_rs2_data (MEM_FD_rs2_data),
               .MEM_rd_addr     (MEM_rd_addr    ),
               .MEM_rmem        (MEM_rmem       ),
               .MEM_wmem        (MEM_wmem       ),
               .MEM_wen         (MEM_wen        ),
               .MEM_mem_type    (MEM_mem_type   ),
               .MEM_mem_sign    (MEM_mem_sign   ),
               .MEM_jump        (jump           )
           );


    // MEM_inst
    assign mem_wdata  = MEM_FD_rs2_data;
    assign mem_addr   = MEM_result;
    assign mem_type   = MEM_mem_type;
    assign mem_sign   = MEM_mem_sign;
    assign rmem       = MEM_rmem;
    assign wmem       = MEM_wmem;


    mem_wb mem_wb_inst(
               .clk           (clk           ),
               .rstn          (rstn          ),
               .MEM_result    (MEM_result    ),
               .MEM_rd_addr   (MEM_rd_addr   ),
               .MEM_rmem      (MEM_rmem      ),
               .MEM_wen       (MEM_wen       ),
               .WB_result     (WB_result     ),
               .WB_rd_addr    (WB_rd_addr    ),
               .WB_rmem       (WB_rmem       ),
               .WB_wen        (WB_wen        )
           );

    assign WB_mem_rdata = mem_rdata;

    wb wb_inst(
           .WB_mem_rdata (WB_mem_rdata ),
           .WB_result    (WB_result    ),
           .WB_rmem      (WB_rmem      ),
           .WB_rd_data   (WB_rd_data   )
       );



    forward forward_inst(
                .EX_MEM_wen (MEM_wen),
                .EX_MEM_rd  (MEM_rd_addr ),
                .MEM_WB_wen (WB_wen ),
                .MEM_WB_rd  (WB_rd_addr  ),
                .ID_EX_rs1  (EX_rs1_addr ),
                .ID_EX_rs2  (EX_rs2_addr ),
                .fwd_rs1    (fwd_rs1),
                .fwd_rs2    (fwd_rs2)
            );

    hazard_detection hazard_detection_inst(
                         .ID_rs1    (ID_rs1_addr   ),
                         .ID_rs2    (ID_rs2_addr   ),
                         .EX_rd     (EX_rd_addr    ),
                         .EX_rmem   (EX_rmem       ),
                         .nop       (nop           )
                     );

endmodule

