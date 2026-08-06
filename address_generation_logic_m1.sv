`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 15:27:52
// Design Name: 
// Module Name: address_generation_logic
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

//Sequential
module address_generation_logic(
	input hclk_m1,
	input hreset_m1,
	input wire [2:0]hburst_m1,
	input wire [7:0]wrap_byte_variable_m1,
	input wire [31:0]start_wrap_address_m1,
	input wire [31:0]end_wrap_address_m1,
	input wire [31:0]remainder_temp_m1,
	
	input wire load_addr_m1,
	input wire hready_m1,
	
	input wire [31:0]haddr_m1,
	
	output reg [31:0]addr_out_m1
	
    );
    parameter reg [31:0]start_addrs_m1;
    //Next address generation logic sequential
    
    always @(posedge hclk_m1,negedge hreset_m1)
    begin
    	if(!hreset_m1)
    	  addr_out_m1 <= start_addrs_m1;
    	else if(load_addr_m1 && hready_m1)begin
    	  if((hburst_m1 == 3'b010) || (hburst_m1 ==3'b100) || (hburst_m1 ==3'b110))
    	   begin
    	   	if(remainder_temp_m1 !=0)	//I am already inside wrap region, so now I must check whether to wrap back or just increment
    	   	 addr_out_m1 <=(addr_out_m1 ==end_wrap_address_m1)? start_wrap_address_m1 : ((addr_out_m1 == (start_addrs_m1-4))?addr_out_m1:(addr_out_m1+4));
    	   	else 
    	   	 addr_out_m1 <= (haddr_out_m1 ==((start_addrs_m1 + wrap_byte_variable_m1)-1))?addr_out_m1:(addr_out_m1 +4);
    	   	 //non-wrap burst
    	   end
    	 else
    	  addr_out_m1 <= addr_out_m1;
    end
   end
endmodule
