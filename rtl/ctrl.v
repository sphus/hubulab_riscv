
module ctrl(
        // from ex
        input wire  [31:0]  jump_addr_i ,
        input wire          jump_en_i   ,
        input wire          hold_flag_i ,

        // from ctrl
        output wire [31:0]  jump_addr_o ,
        output wire         jump_en_o   ,
        output wire         hold_flag_o 
    );

    assign jump_addr_o  = jump_addr_i;
    assign jump_en_o    = jump_en_i;
    assign hold_flag_o  = hold_flag_i | jump_en_i;


endmodule //moduleName

