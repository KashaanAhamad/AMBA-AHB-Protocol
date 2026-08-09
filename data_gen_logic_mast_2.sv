`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 23:15:04
// Design Name: 
// Module Name: data_gen_logic_mast_2
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


module data_gen_logic_mast_2(

    input wire hclk_m2,
	input wire hreset_m2,
	input wire hready_m2,
	input wire load_out_m2,
	
	output reg [31:0]data_out_m2
    );
    parameter reg[31:0] data_m2=32'hffff_d34c;
    //Next data Generation Logic to write in slave
    always @(posedge hclk_m2,negedge hreset_m2)
    	begin
    	  if(!hreset_m2)
    	    data_out_m2<=data_m2;
    	  else if(load_out_m2 && hready_m2)
    	    data_out_m2 <= data_out_m2+32'h0000_0010; //might need to change the value.
    	end
endmodule

