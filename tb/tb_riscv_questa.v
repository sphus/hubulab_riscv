
`timescale 1ns/1ns
module tb_riscv_questa();

`define CLK_PERIOD 20

    // initial begin
    //     $dumpfile("wave.vcd");
    //     $dumpvars;
    // end

    reg  clk ;
    reg  rstn;

    always #(`CLK_PERIOD / 2) clk = ~clk;

    initial begin
        clk  = 1'b1;
        rstn = 1'b0;
        #(`CLK_PERIOD * 1.5);
        rstn = 1'b1;
    end

    // initial rom
    initial begin
        $readmemh("./generated/rv32ui-p-sra.txt",tb_riscv_questa.riscv_soc_uut.rom_inst.dual_ram_inst.dual_ram_template_inst.memory);
        // $readmemh("../generated/inst_data.txt",tb_riscv_questa.riscv_soc_uut.rom_inst.dual_ram_inst.dual_ram_template_inst.memory);
    end


    wire [31:0] pc_pc     = tb_riscv_questa.riscv_soc_uut.riscv_inst.inst_addr_rom;
    wire [31:0] pc_id     = tb_riscv_questa.riscv_soc_uut.riscv_inst.inst_addr_if_id;
    wire [31:0] pc_ex     = tb_riscv_questa.riscv_soc_uut.riscv_inst.inst_addr_id_ex;
    wire        jump_flag = tb_riscv_questa.riscv_soc_uut.riscv_inst.jump_en_ctrl;
    wire [31:0] jump_addr = tb_riscv_questa.riscv_soc_uut.riscv_inst.jump_addr_ctrl;

    wire [31:0] pc [2:0];
    assign pc[0] = tb_riscv_questa.riscv_soc_uut.inst_addr_rom;
    assign pc[1] = (pc[0] > 0) ? (pc[0] - 4) : 0;
    assign pc[2] = (pc[1] > 0) ? (pc[1] - 4) : 0;


    reg         jump_flag_end ;
    reg [31:0]  pc_reg      ;
    reg [31:0]  pc_jump_before ;
    reg [31:0]  pc_jump_last ;


    always @(posedge clk) begin
        if(!rstn) begin
            pc_reg <= 32'd0;
            jump_flag_end <= 0;
            pc_jump_before <= 32'd0;
            pc_jump_last <= 32'd0;
        end

        pc_reg <= pc[0];
        if((pc_reg != pc[0] - 4) && (pc_reg != 0) && (pc[0] != 0)) begin
            jump_flag_end <= 1;
            pc_jump_before <= pc_reg;
            pc_jump_last <= pc[0];
        end
        if (jump_flag_end)
            jump_flag_end <= 0;
    end


    wire [31:0] x [31:0];

    genvar i;

    generate
        for(i = 0 ; i < 31; i = i + 1) begin
            assign x[i] = tb_riscv_questa.riscv_soc_uut.riscv_inst.register_inst.reg_mem[i];
        end
    endgenerate


    integer r;

    initial begin

        wait(x[26] == 32'b1);
        #(`CLK_PERIOD*3);
        if(x[27] == 32'b1) begin
            $display("############################");
            $display("########  pass  !!!#########");
            $display("############################");
        end
        else begin
            for(r = 0;r < 31; r = r + 4) begin
                // $display("x%2d register value is %d",r,x[r]);
                $display("x%2d to x%2d:%x %x %x %x",r,r+3,x[r],x[r+1],x[r+2],x[r+3]);
            end
            $display("############################");
            $display("########  fail  !!!#########");
            $display("############################");
            $display("fail testnum = %2d", x[3]);
        end
        $stop;
        // $finish;
    end

    always @(negedge clk) begin
        // if(jump_flag_end) begin
        //     $display("before:   %x jump to %x at %d", pc_jump_before,pc_jump_last,$time);
        // end
        if(jump_flag) begin
            // $display("last:     %x jump to %x at %d", pc_ex,jump_addr,$time);
            $display("%x jump to %x at %d", pc_ex,jump_addr,$time);
        end

        // if (jump_flag_end | jump_flag) begin
        //     if((pc_jump_before == pc_ex) && (pc_jump_last == jump_addr))
        //         $display("test true:%x jump to %x at %d", pc_ex,jump_addr,$time);
        //     else begin
        //         $display("test fail!");
        //         $display("before:   %x jump to %x at %d", pc_jump_before,pc_jump_last,$time);
        //         $display("last:     %x jump to %x at %d", pc_ex,jump_addr,$time);
        //     end
        // end

        // $monitor("timms is %d",$time);
        // $monitor("pc: 1st:%x, 2nd:%x ,3rd:%x",pc[0],pc[1],pc[2]);
        // $monitor("x3 register value is %d",x[3]);
        // $monitor("x26 register value is %d",x[26]);
        // $monitor("x27 register value is %d",x[27]);
        //     $display("---------------------------");
    end



    riscv_soc riscv_soc_uut(
                  .clk  (clk    ),
                  .rstn (rstn   )
              );

endmodule
