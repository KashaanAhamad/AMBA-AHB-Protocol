`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 12:20:13
// Design Name: 
// Module Name: address_loader_s2
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


module address_loader_s2(
	input logic hclk_s2,
	input logic hreset_s2,
	input logic load_addrs_s2,
	input logic [31:0] haddr_s2,
	input logic hwrite_s2,
	
	output logic [31:0] address_in_s2
    );
    //always_ff @(posedge hclk_s2)
    always_comb
    begin
     if(load_addrs_s2)
     begin
     	if(haddr_s2 <1536)
     	begin
     		if(hwrite_s2)
     			address_in_s2 <= haddr_s2;
     	end
     	else
     	begin
     		if(!hwrite_s2)
     			address_in_s2 <=haddr_s2;
     		end
     	end
     end
endmodule
