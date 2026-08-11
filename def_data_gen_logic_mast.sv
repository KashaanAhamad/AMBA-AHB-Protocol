`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 18:48:37
// Design Name: 
// Module Name: data_gen_logic_mast_def
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


module data_gen_logic_mast_def(
    input wire def_hclk,
	input wire def_hreset,
	input wire def_hready,
	input wire def_load_out,
	
	output reg [31:0]def_data_out
    );
    parameter reg [31:0] def_data=32'h01a7_d34c;
    //Next data Generation Logic to write in slave
    always @(posedge def_hclk,negedge def_hreset)
    	begin
    	  if(!def_hreset)
    	   def_data_out<=def_data;
    	  else if(def_load_out && def_hready)
    	    def_data_out <= def_data_out+32'h0000_0010;
    	end
endmodule
