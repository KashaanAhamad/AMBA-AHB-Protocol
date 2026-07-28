`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 23:11:04
// Design Name: 
// Module Name: address_cal_logic_mast_2
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

//combinational
module address_cal_logic_mast_2(
	input wire burst_size_m2,
	
	output reg [7:0]wrap_byte_variable_m2,
	output reg [31:0]start_wrap_address_m2,
	output reg [31:0]end_wrap_address_m2,
	output reg [31:0]remainder_temp_m2,
	output reg [31:0]quotient_temp_m2
    );
   parameter reg [31:0]start_addrs_m2=32'h0000_0600;
    
    always_comb
    begin
    	wrap_byte_variable_m2 = 4*burst_size_m2;
    	remainder_temp_m2 = start_addrs_m2 % wrap_byte_variable_m2;	//remainder_temp_m1=addr_out_m1 - start_wrap_address_m1
    	quotient_temp_m2 = start_addrs_m2/wrap_byte_variable_m2;
    	start_wrap_address_m2 = wrap_byte_variable_m2 * quotient_temp_m2;
    	end_wrap_address_m2 = start_wrap_address_m2 + wrap_byte_variable_m2 -4;
    end
endmodule

