`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 13:20:00
// Design Name: 
// Module Name: response_generator_s2
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


module response_generator_s2(
	input logic hclk_s2,
	input logic [31:0]haddr_s2,
	input logic hwrite_s2,
	
	//Signal comming from FSM
	input logic load_resp_s2,
	
	//Signal going to FSM
	output logic [1:0]resp_out_s2
    );
    
    always_ff @(posedge hclk_s2)
    begin
    if(load_resp_s2)
    	begin
    		if(haddr_s2 < 1536) begin
    		if(hwrite_s2)
    		begin	
    			resp_out_s2 <=2'b00;
    		end
    		else
    			resp_out_s2 <= 2'b01;
    	end
    	else
    	begin
    		if(!hwrite_s2) begin
    			resp_out_s2 <= 2'b00;
    		end
    		else
    			resp_out_s2 <=2'b01; //blocking assignmnet was used here
    		end
    	end
    	else
    	 	resp_out_s2 <= 2'b00;
    	end
endmodule
