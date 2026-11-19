`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 11:35:38
// Design Name: 
// Module Name: master_to_slave_data_mux
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


module master_to_slave_data_mux(
	input logic [3:0]hdata_sel,
	input logic [31:0]hdata_def,hdata_m1,hdata_m2,
	output logic [31:0]hdata_mast
    );
    
    always @(hdata_sel,hdata_def,hdata_m1,hdata_m2)
    begin
    	case(hdata_sel)
    	  4'b0000: hdata_mast = hdata_def;
    	  4'b0001: hdata_mast = hdata_m1;
    	  4'b0010: hdata_mast = hdata_m2;
    	  default: hdata_mast = 32'hxxxx_xxxx;
    	endcase
    end
endmodule
