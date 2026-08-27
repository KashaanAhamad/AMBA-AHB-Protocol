`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 23:00:13
// Design Name: 
// Module Name: response_generator_s3
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


module response_generator_s3(
    input logic hclk_s3,
	input logic [31:0]haddr_s3,
	input logic hwrite_s3,
	input logic load_resp_s3,	//this is never used fix it
	
	output logic [1:0]resp_out_s3
    );
    
  always_ff @(posedge hclk_s3)
  begin
    if(load_resp_s3)
    begin
        if(haddr_s3 < 2560) begin
            if(hwrite_s3)
            begin
                resp_out_s3 <= 2'b00;
            end
            else
                resp_out_s3 <= 2'b01;
        end
        else
        begin
            if(!hwrite_s3) begin
                resp_out_s3 <= 2'b00;
            end
            else	
                resp_out_s3 <= 2'b01;
        end
    end
    else
        resp_out_s3 <= 2'b00;
  end
endmodule