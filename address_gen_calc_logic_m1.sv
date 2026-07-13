`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 15:03:04
// Design Name: 
// Module Name: address_gen_calc_logic
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
module address_calc_logic(
	input wire burst_size_m1,
	
	output reg [7:0]wrap_byte_variable_m1,
	output reg [31:0]start_wrap_address_m1,
	output reg [31:0]end_wrap_address_m1,
	output reg [31:0]remainder_temp_m1,
	output reg [31:0]quotient_temp_m1
    );
   parameter reg [31:0]start_addrs_m1=32'h0000_0600;
    always_comb
    begin
    	wrap_byte_variable_m1 = 4*burst_size_m1;
    	remainder_temp_m1 = start_addrs_m1 % wrap_byte_variable_m1;	//remainder_temp_m1=addr_out_m1 - start_wrap_address_m1
    	quotient_temp_m1 = start_addrs_m1/wrap_byte_variable_m1;
    	start_wrap_address_m1 = wrap_byte_variable_m1 * quotient_temp_m1;
    	end_wrap_address_m1 = start_wrap_address_m1 + wrap_byte_variable_m1 -4;
    end
endmodule
