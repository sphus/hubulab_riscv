
`timescale 1ns/1ns
module tb_ram();

`define CLK_PERIOD 20

    reg             clk ;
    reg             rstn;
    reg  [3:0]		wen   ;
    reg  [32-1:0]	w_addr;
    reg  [32-1:0]   w_data;
    reg 			ren   ;
    reg  [32-1:0]	r_addr;
    wire [32-1:0]   r_data;

    always #(`CLK_PERIOD / 2) clk = ~clk;

`define TIMES 16

    integer i = 0;

    initial begin
        clk  = 1'b1;
        rstn = 1'b0;
        w_addr = 32'd0;
        w_data = 32'd0;
        wen = 4'b0;
        r_addr = 32'd0;
        ren = 1'b0;
        #(`CLK_PERIOD);
        rstn = 1'b1;

        for (i = 0; i < `TIMES; i = i + 1) begin
            w_addr = i;
            w_data = i + 1;
            wen = 4'b1111;
            #`CLK_PERIOD;
        end
        w_addr = 32'd0;
        w_data = 32'd0;
        wen = 4'b0;
        for (i = 0; i < `TIMES; i = i + 1) begin
            r_addr = i;
            ren = 1'b1;
            #`CLK_PERIOD;
        end
        ren = 1'b0;
        $stop;
    end


    ram #(
            .DW      	(32    ),
            .AW      	(32    ),
            .MEM_NUM 	(4096  ))
        u_ram(
            .clk    	(clk     ),
            .rstn   	(rstn    ),
            .wen    	(wen     ),
            .w_addr 	(w_addr  ),
            .w_data 	(w_data  ),
            .ren    	(ren     ),
            .r_addr 	(r_addr  ),
            .r_data 	(r_data  )
        );



endmodule
