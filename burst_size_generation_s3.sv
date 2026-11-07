`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:57:28
// Design Name: 
// Module Name: burst_size_generation_s3
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Burst size generator for Slave 3. Converts hburst encoding
//              to the number of beats in the burst transfer.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - Module implemented (was empty shell)
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module burst_size_generation_s3(
	input  logic [2:0] hburst_s3,
	
	//Signal going to FSM
	output logic [3:0] burst_size_s3
);

always_comb begin
	unique case(hburst_s3)
		3'b001: burst_size_s3 = 6;   // INCR (user-defined length)
		3'b010: burst_size_s3 = 4;   // WRAP4
		3'b011: burst_size_s3 = 4;   // INCR4
		3'b100: burst_size_s3 = 8;   // WRAP8
		3'b101: burst_size_s3 = 8;   // INCR8
		3'b110: burst_size_s3 = 16;  // WRAP16
		3'b111: burst_size_s3 = 16;  // INCR16
		default: burst_size_s3 = 1;  // SINGLE
	endcase
end

endmodule
