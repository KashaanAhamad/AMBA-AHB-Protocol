`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:56:48
// Design Name: 
// Module Name: slave_select_decoder
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


module slave_select_decoder(
	input logic [31:0]haddr,//coming from addrs_control_mux
	//Output going to their respective slave
	output logic hsel_s1,
	output logic hsel_s2,
	output logic hsel_s3,
	output logic hsel_def,
	
	output logic [1:0]mux_select//This o/p signal goes to slave_to_master_mux
    );
    
    always_comb begin
    	if(haddr >=0 && haddr <1024)
    	 begin
    	 	hsel_s1=1;
    	 	hsel_s2=0;
    	 	hsel_s3=0;
    	 	hsel_def=0;
    	 	mux_select=2'b01;
    	 end
    	else if(haddr>=1024 && haddr <2048)
    	 begin
    	 	hsel_s1=0;
    	 	hsel_s2=1;
    	 	hsel_s3=0;
    	 	hsel_def=0;
    	 	mux_select=2'b10;
    	 end
    	else if(haddr >=2048 && haddr <3072)
    	 begin
    	 	hsel_s1=0;
    	 	hsel_s2=0;
    	 	hsel_s3=1;
    	 	hsel_def=0;
    	 	mux_select=2'b11;
    	 end
    	else
    	 begin
    	 	hsel_s1=0;
    	 	hsel_s2=0;
    	 	hsel_s3=0;
    	 	hsel_def=1;
    	 	mux_select=2'b00;
    	 end
    end
endmodule
