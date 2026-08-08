`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 12:52:58
// Design Name: 
// Module Name: response_generator_slave_1
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


module response_generator_slave_1( 
	input logic hclk_s1,
	input logic [31:0]haddr_s1,
	input logic hwrite_s1,
	
	//Signal comming from FSM
	input logic load_resp_s1,
	
	//Signal going to FSM
	output logic [1:0]resp_out_s1
    );
    
  always_ff @(posedge hclk_s1)
  begin
  	if(load_resp_s1)
  	begin
    	if(haddr_s1 < 512) begin
    	if(hwrite_s1)
    	begin
    		resp_out_s1 <= 2'b00;
    	end
    	else
    		resp_out_s1 <= 2'b01;
    end
    else
    begin
    	if(!hwrite_s1) begin
    		resp_out_s1 <= 2'b00;
    	end
    	else	
    		resp_out_s1 <=2'b01;//blocking to non blocking
    	end
    end
   else
    	resp_out_s1 <= 2'b00;//blocking to non blocking changes made
    end    		
endmodule
