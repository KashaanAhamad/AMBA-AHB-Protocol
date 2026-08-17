`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 14:48:40
// Design Name: 
// Module Name: burst_size_gen_slave_1
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


module burst_size_gen_slave_1(
	input logic [2:0]hburst_s1,
	
	//Signal going to FSM
    output logic [3:0] burst_size_s1
    );
always_comb
begin
	unique case(hburst_s1)
		3'b001: burst_size_s1 =6;
		3'b010: burst_size_s1 =4;
		3'b011: burst_size_s1 =4;
		3'b100: burst_size_s1 =8;
		3'b101: burst_size_s1 =8;
		3'b110: burst_size_s1 =16;
		3'b111: burst_size_s1 =16;
		default: burst_size_s1=1;
	endcase
end
endmodule
