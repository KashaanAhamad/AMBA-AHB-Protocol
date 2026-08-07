`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 12:46:55
// Design Name: 
// Module Name: address_loader_slave_1
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


module address_loader_slave_1(
	input hclk_s1,
	input logic hwrite_s1,
	input logic [31:0]haddr_s1,
	
	//Signal comming from FSM
	input logic [31:0] load_addrs_s1,//check size here
	
	//Signal going to Data_generation_logic
	output logic address_in_s1
    );
    
    always_ff @(posedge hclk_s1)
    begin
    	if(load_addrs_s1)
    	begin
    		if(haddr_s1 < 512) begin
    		if(hwrite_s1)
    			address_in_s1 <= haddr_s1;
    		end
    		else
    		begin
    			if(!hwrite_s1)
    				address_in_s1 <= haddr_s1;
    		end
    	end
    end
endmodule
