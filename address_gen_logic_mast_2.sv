`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 23:17:14
// Design Name: 
// Module Name: address_gen_logic_mast_2
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
module address_gen_logic_mast_2(

   	input hclk_m2,
	input hreset_m2,
	input wire [3:0]hburst_m2,
	input wire [7:0]wrap_byte_variable_m2,
	input wire [31:0]start_wrap_address_m2,
	input wire [31:0]end_wrap_address_m2,
	input wire [31:0]remainder_temp_m2,
	
	input wire load_addr_m2,
	input wire hready_m2,
	
	input wire [31:0]haddr_m2,
	
	output reg [31:0]addr_out_m2
	
    );
    parameter reg [31:0]start_addrs_m2;
    //Next address generation logic sequential
    
    always @(posedge hclk_m2,negedge hreset_m2)
    begin
    	if(!hreset_m2)
    	  addr_out_m2 <= start_addrs_m2;
    	else if(load_addr_m2 && hready_m2)begin
    	  if((hburst_m2 == 3'b010) || (hburst_m2 ==3'b100) || (hburst_m2 ==3'b110))
    	   begin
    	   	if(remainder_temp_m2 !=0)	//I am already inside wrap region, so now I must check whether to wrap back or just increment
    	   	 addr_out_m2 <=(addr_out_m2 ==end_wrap_address_m2)? start_wrap_address_m2 : ((addr_out_m2 == (start_addrs_m2-4))?addr_out_m2:(addr_out_m2+4));
    	   	else 
    	   	 addr_out_m2 <= (haddr_m2 ==((start_addrs_m2 + wrap_byte_variable_m2)-1))?addr_out_m2:(addr_out_m2 +4);
    	   	 //non-wrap burst
    	   end
    	 else
    	  addr_out_m2 <= addr_out_m2;
    end
   end
endmodule
