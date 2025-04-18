`include "../defines.v"

module ctrl (
    input  wire             clk     ,
    input  wire             rstn    ,
    input  wire             wen     ,
    input  wire             hold    ,
    output reg  [`StateBus] state
);

    always @(posedge clk or negedge rstn) begin
        if (!rstn) 
            state <= `IF_STATE;
        else if(hold) 
            state <= `IF_STATE;            
        else
            state <= {state[`Statenum-2:0],state[`Statenum-1]};
    end

    

endmodule //ctrl