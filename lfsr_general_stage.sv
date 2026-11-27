`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 14:27:58
// Design Name: 
// Module Name: lfsr_general_stage
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

module lfsr_general_stage #(parameter [4:0] seed=5'b00101)(rand_out,clock,reset);
 input clock,reset;
 output reg [4:0]rand_out;
 reg [4:0]temp;
 
 always_ff @(posedge clock,negedge reset)
 begin
 	if(!reset)
 	  temp <=seed;
 	else begin
 	  temp <= {temp[3:0],(temp[4]^temp[3])};
 	  rand_out <=temp;
 	end
 end
endmodule