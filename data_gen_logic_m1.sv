`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 14:45:26
// Design Name: 
// Module Name: data_gen_logic
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


module data_gen_logic(
	input wire hclk_m1,
	input wire hreset_m1,
	input wire hready_m1,
	input wire load_out_m1,
	
	output reg data_out_m1
    );
    parameter reg[31:0] data_m1=32'h01a7_d34c;
    //Next data Generation Logic to write in slave
    always @(posedge hclk_m1,negedge hreset_m1)
    	begin
    	  if(hreset_m1)
    	    data_out_m1<=data_m1;
    	  else if(load_out_m1 && hready_m1)
    	    data_out_m1 <= data_out_m1+32'h0000_0010;
    	end
endmodule
