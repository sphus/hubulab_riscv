
`include "../defines.v"
module if_id (
        input  wire                 clk     ,
        input  wire                 rstn    ,
        input  wire [`Hold_Bus]     hold    ,
        input  wire [`Flush_Bus]    flush   ,
        input  wire [`RegBus]       inst_i  ,
        input  wire [`RegBus]       addr_i  ,
        output wire [`RegBus]       inst_o  ,
        output wire [`RegBus]       addr_o
    );

    reg rom_flag;

    always @(posedge clk)
    begin
        if(!rstn | flush[1])
            rom_flag <= `Disable;
        else
            rom_flag <= `Enable;
    end

    assign inst_o = rom_flag ? inst_i : `INST_NOP;
    
    wire CE = ~{|hold};

    DFFC #(`Regnum) addr_dff (clk,rstn,flush[1],CE,`ZeroWord ,addr_i,addr_o);

endmodule
