`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 13:17:35
// Design Name: 
// Module Name: burst_size_gen_s2
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


module burst_size_gen_s2(
	input logic [2:0]hburst_s2,
	
	output logic [3:0] burst_size_s2
    );
    
always_comb
begin
	unique case(hburst_s2)
		3'b001: burst_size_s2 =6;
		3'b010: burst_size_s2 =4;
		3'b011: burst_size_s2 =4;
		3'b100: burst_size_s2 =8;
		3'b101: burst_size_s2 =8;
		3'b110: burst_size_s2 =16;
		3'b111: burst_size_s2 =16;
		default: burst_size_s2=1;
	endcase
end
endmodule
