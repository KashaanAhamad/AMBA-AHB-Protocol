`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:30:31
// Design Name: 
// Module Name: master_to_slave_control_mux
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


module master_to_slave_control_mux(
	//First Master Signal
	input logic [2:0]hburst_m1,
	input logic [2:0]hsize_m1,
	input logic hwrite_m1,
	input logic [1:0]htrans_m1,
	
	//Second Master Signal
	input logic [2:0]hburst_m2,
	input logic [2:0]hsize_m2,
	input logic hwrite_m2,
	input logic [1:0]htrans_m2,
	
	//Default Master Signal
	input logic [2:0]def_hburst,
	input logic [2:0]def_hsize,
	input logic def_hwrite,
	input logic [1:0]def_htrans,
	
	//Arbiter Control signal
	input logic [3:0] hmaster,
	
	//Output Signals
	output logic [1:0]htrans,
	output logic hwrite,
	output logic [2:0]hsize,
	output logic [2:0]hburst
	 
    );
    
endmodule
