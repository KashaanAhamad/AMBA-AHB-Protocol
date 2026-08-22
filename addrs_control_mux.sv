`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:26:39
// Design Name: 
// Module Name: addrs_control_mux
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


module addrs_control_mux(
	input logic [31:0]haddr_m1,
	input logic [31:0]haddr_m2,
	input logic [31:0]haddr_def,
	input logic [3:0]hmaster,//comming from arbiter
	
	output logic [31:0] haddr_out
    );
    
    always @(hmaster,haddr_def,haddr_m1,haddr_m2) begin
    	case(hmaster)
    		4'b0000: haddr_out =haddr_def;
    		4'b0001: haddr_out =haddr_m1;
    		4'b0010: haddr_out =haddr_m2;
    		default: haddr_out =32'bxxxx_xxxx;
    	endcase
    end   
endmodule
