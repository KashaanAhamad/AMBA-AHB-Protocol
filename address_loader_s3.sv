`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:59:07
// Design Name: 
// Module Name: address_loader_s3
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


module address_loader_s3(
	input hclk_s3,
	input logic load_addrs_s3,
	input logic hwrite_s3,
	input logic [31:0]haddr_s3,
	
	output logic [31:0]address_in_s3
    );
    
    always_ff @(posedge hclk_s3)
    begin
    	if(load_addrs_s3)
    	begin
    		if(haddr_s3 < 2560) begin
    		if(hwrite_s3)
    			address_in_s3 <= haddr_s3;
    		end
    		else
    		begin
    			if(!hwrite_s3)
    				address_in_s3 <= haddr_s3;
    		end
    	end
    end
endmodule

