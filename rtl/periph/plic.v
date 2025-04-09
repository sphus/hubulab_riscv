module plic #(
    parameter                           MUN = 4                     
)
(
    input  wire                         io0_irq                    ,
    input  wire                         io1_irq                    ,
    input  wire                         io2_irq                    ,
    input  wire                         io3_irq                    ,

    output wire        [MUN-1:0]        irq_o                       
);

wire [MUN-1:0] irq_i;
assign irq_i = {io3_irq,io2_irq,io1_irq,io0_irq};

assign irq_o = irq_i&(~(irq_i-1));

endmodule