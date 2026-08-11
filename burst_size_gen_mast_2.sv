`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 23:08:32
// Design Name: 
// Module Name: burst_size_gen_mast_2
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


module burst_size_gen_mast_2(

   input wire [2:0]hburst_m2,
    output logic [3:0] burst_size_m2
    );
    //Burst size generation in terms of beats
    
   always_comb
   begin
     unique case(hburst_m2)
     	3'b001: burst_size_m2=6;//Custom value given by designer
     	3'b010: burst_size_m2=4;
     	3'b011: burst_size_m2=4;
     	3'b100: burst_size_m2=8;
     	3'b101: burst_size_m2=8;
     	3'b110: burst_size_m2=16;
     	3'b111: burst_size_m2=16;
     	default: burst_size_m2=1;//Single beats
     endcase
   end
endmodule
