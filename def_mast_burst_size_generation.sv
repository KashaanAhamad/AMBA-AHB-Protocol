`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.08.2026 23:16:31
// Design Name: 
// Module Name: def_burst_size_generation
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
module def_burst_size_generation(
    input wire [2:0]def_hburst,
    output logic [4:0] def_burst_size
    );
    //Burst size generation in terms of beats
    
   always_comb
   begin
     unique case(def_hburst)
     	3'b001: def_burst_size=6;//User Defined beats,here taken as 6
     	3'b010: def_burst_size=4;
     	3'b011: def_burst_size=4;
     	3'b100: def_burst_size=8;
     	3'b101: def_burst_size=8;
     	3'b110: def_burst_size=16;
     	3'b111: def_burst_size=16;
     	default: def_burst_size=1;//Single beats
     endcase
   end
endmodule
