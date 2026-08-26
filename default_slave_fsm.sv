`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 14:53:08
// Design Name: 
// Module Name: default_slave_fsm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module default_slave_fsm(
    input logic hclk_def,
    input logic hreset_def,
    input logic hsel_def,
    input logic hready_def,
    input logic [1:0] htrans_def,
    output logic hready_out_def,
    output logic [1:0] hresp_def
);

    reg [1:0] state_def, next_state_def;
    
    parameter 	IDLE_SLAVE_DEF=2'b00, ERROR_SLAVE_DEF=2'b01, 
    			OK_SLAVE_DEF =2'b10,  ERROR_CYCLE_SLAVE_DEF=2'b11;
    
    always_comb
    begin
        next_state_def = state_def;
        case(state_def)
            IDLE_SLAVE_DEF: begin
                if(hready_def) begin
                    if(hsel_def)
                        next_state_def = ((htrans_def == 2'b10) || (htrans_def == 2'b11)) ? ERROR_SLAVE_DEF : OK_SLAVE_DEF;
                    else
                        next_state_def = IDLE_SLAVE_DEF;
                end
            end
            
            OK_SLAVE_DEF: begin
                if(hready_def) begin
                    if(!hsel_def)
                        next_state_def = IDLE_SLAVE_DEF;
                    else
                        next_state_def = ((htrans_def == 2'b01) || (htrans_def == 2'b00)) ? OK_SLAVE_DEF : ERROR_SLAVE_DEF;
                end
            end
            
            ERROR_SLAVE_DEF: begin
                // Transition unconditionally since HREADYOUT is 0 (making hready_def 0)
                if(!hsel_def)
                    next_state_def = IDLE_SLAVE_DEF;
                else
                    next_state_def = ERROR_CYCLE_SLAVE_DEF;
            end
            
            ERROR_CYCLE_SLAVE_DEF: begin
                if(hready_def) begin
                    if(!hsel_def)
                        next_state_def = IDLE_SLAVE_DEF;
                    else if((htrans_def == 2'b10) || (htrans_def == 2'b11))
                        next_state_def = ERROR_CYCLE_SLAVE_DEF;
                    else
                        next_state_def = IDLE_SLAVE_DEF;
                end
            end
        endcase
   end
   
   always_ff @(posedge hclk_def, negedge hreset_def)
   begin
   	if(!hreset_def)
   		state_def <= IDLE_SLAVE_DEF;
   	else
   		state_def <= next_state_def;
   end
   
   always_comb
   begin
   	 if(state_def == IDLE_SLAVE_DEF)
   	 begin
   	 	hresp_def =2'b00;
   	 	hready_out_def =1;
   	 end
   	 else if(state_def == OK_SLAVE_DEF)
   	 begin
   	 	hresp_def =2'b00;
   	 	hready_out_def =1;
   	 end
   	 else if(state_def == ERROR_SLAVE_DEF)
   	 begin
   	 	hresp_def =2'b01;
   	 	hready_out_def=0;
   	 end
   	 else if(state_def == ERROR_CYCLE_SLAVE_DEF)
   	 begin
   	 	hresp_def =2'b01;
   	 	hready_out_def=1;
   	 end
   	 else
   	 begin
   	 	hresp_def =2'b00;
   	 	hready_out_def =1;
   	 end
   end  			
endmodule
