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
						hclk_def,
						hreset_def,
						hsel_def,
						htrans_def,
						
						//unused signals
						haddr_def,
						hwrite_def,
						hsize_def,
						hburst_def,						
						hready_def,
						hwdata_def,		
						//output
						hready_out_def,
						hresp_def
						//hrdata_def
    			);
    			
    input [31:0]haddr_def,hwdata_def;
    input hwrite_def,hsel_def,hready_def;
    input hclk_def,hreset_def;
    input [2:0]hsize_def,hburst_def;
    input [1:0]htrans_def;
    
    output reg hready_out_def;
    output reg [1:0]hresp_def;
    //output reg [31:0]hrdata_def;
    
    reg [1:0] state_def, next_state_def;
    
    parameter 	IDLE_SLAVE_DEF=2'b00, ERROR_SLAVE_DEF=2'b01, 
    			OK_SLAVE_DEF =2'b10,  ERROR_CYCLE_SLAVE_DEF=2'b11;
    
    always_comb
    begin
    	case(state_def)
    		IDLE_SLAVE_DEF: begin
    			if(hsel_def)
    				next_state_def =((htrans_def ==2'b10) || (htrans_def == 2'b11))? ERROR_SLAVE_DEF: OK_SLAVE_DEF;
				else
					next_state_def = IDLE_SLAVE_DEF;
    		end
    		
    		OK_SLAVE_DEF: begin
    			if(!hsel_def)
    				next_state_def =IDLE_SLAVE_DEF;
    			else
    				next_state_def =((htrans_def ==2'b01) || (htrans_def ==2'b00))?OK_SLAVE_DEF: ERROR_SLAVE_DEF;
    		end
    		
    		ERROR_SLAVE_DEF: begin
    			if(!hsel_def)
    				next_state_def = IDLE_SLAVE_DEF;
    			else
    				next_state_def = ERROR_CYCLE_SLAVE_DEF;
    		end
    		
    		ERROR_CYCLE_SLAVE_DEF: begin
    			if(!hsel_def)
    				next_state_def = IDLE_SLAVE_DEF;
    			else if((htrans_def ==2'b10) || (htrans_def ==2'b11))
    				next_state_def = ERROR_CYCLE_SLAVE_DEF;
    			else
    				next_state_def = IDLE_SLAVE_DEF;
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
