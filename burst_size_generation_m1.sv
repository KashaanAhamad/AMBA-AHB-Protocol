`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 15:52:29
// Design Name: 
// Module Name: burst_size_generation
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
module burst_size_generation(
    input wire [2:0]hburst_m1,
    output logic [4:0] burst_size_m1
    );
    //Burst size generation in terms of beats
    
   always_comb
   begin
     unique case(hburst_m1)
     	3'b001: burst_size_m1=6;//User Defined beats,here taken as 6
     	3'b010: burst_size_m1=4;
     	3'b011: burst_size_m1=4;
     	3'b100: burst_size_m1=8;
     	3'b101: burst_size_m1=8;
     	3'b110: burst_size_m1=16;
     	3'b111: burst_size_m1=16;
     	default: burst_size_m1=1;//Single beats
     endcase
   end
endmodule
