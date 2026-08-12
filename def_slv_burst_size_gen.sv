`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 02:19:15
// Design Name: 
// Module Name: def_burst_size_gen
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


module def_slv_burst_size_gen(
	input logic [2:0] def_hburst,
    
    output logic [3:0] def_burst_size
    );
always_comb
begin
	unique case(def_hburst)
		3'b001: def_burst_size =6;
		3'b010: def_burst_size =4;
		3'b011: def_burst_size =4;
		3'b100: def_burst_size =8;
		3'b101: def_burst_size =8;
		3'b110: def_burst_size =16;
		3'b111: def_burst_size =16;
		default: def_burst_size=1;
	endcase
end
endmodule
