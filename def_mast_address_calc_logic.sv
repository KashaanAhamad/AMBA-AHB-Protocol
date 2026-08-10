`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2026 23:25:35
// Design Name: 
// Module Name: def_address_calc_logic
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

//Comb
module def_address_calc_logic( 
	input wire [3:0]def_burst_size,
	
	output reg [7:0]  def_wrap_byte_variable,
	output reg [31:0] def_start_wrap_address,
	output reg [31:0] def_end_wrap_address
    );
   parameter reg [31:0] def_start_addrs=32'h0000_0600;	//change start address
   
   logic [31:0] def_remainder_temp;
   logic [31:0] def_quotient_temp;

always_comb
    begin
    	def_wrap_byte_variable = 4*def_burst_size;
    	def_remainder_temp = def_start_addrs % def_wrap_byte_variable;	//remainder_temp_m1=addr_out_m1 - start_wrap_address_m1
    	def_quotient_temp = def_start_addrs/ def_wrap_byte_variable;
    	def_start_wrap_address = def_wrap_byte_variable * def_quotient_temp;
    	def_end_wrap_address = def_start_wrap_address + def_wrap_byte_variable -4;
    end
endmodule
