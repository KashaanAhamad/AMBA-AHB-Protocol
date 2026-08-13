`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 12:11:29
// Design Name: 
// Module Name: data_gen_logic_s2
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


module data_gen_logic_s2(
		input logic hclk_s2,
		input logic hreset_s2,
		input logic hready_s2,
		
		
		input logic [31:0]addrs_in_s2,
		
		input logic [31:0]hwdata_s2, 
		
		
		input logic load_data_s2,
		input logic store_data_s2,
		
		
		output logic [31:0]data_out_s2
    );
    
    parameter logic [31:0] DATA_MEMORY_S2 = 32'h1A5B203B;

    logic [31:0] data_mem_s2;
    logic [7:0]  slave_mem_s2 [0:2047];

    always_ff @(posedge hclk_s2) begin
    if (!hreset_s2) begin
        data_mem_s2 = DATA_MEMORY_S2;
           
        for (int i = 1536; i < 2048; i = i + 4) begin
           slave_mem_s2[i]   <= data_mem_s2[31:24];
           slave_mem_s2[i+1] <= data_mem_s2[23:16];
           slave_mem_s2[i+2] <= data_mem_s2[15:8];
           slave_mem_s2[i+3] <= data_mem_s2[7:0];
			
		   data_mem_s2 = data_mem_s2 + 32'd4;
		end
			data_out_s2 <= 32'b0;

    end	else begin
    	   // AHB write
            if (store_data_s2 && hready_s2) begin

                slave_mem_s2[addrs_in_s2]   <= hwdata_s2[31:24];
                slave_mem_s2[addrs_in_s2+1] <= hwdata_s2[23:16];
                slave_mem_s2[addrs_in_s2+2] <= hwdata_s2[15:8];
                slave_mem_s2[addrs_in_s2+3] <= hwdata_s2[7:0];

            end

            // AHB read
            if (load_data_s2 && hready_s2) begin

                data_out_s2 <= {
                    slave_mem_s2[addrs_in_s2],
                    slave_mem_s2[addrs_in_s2+1],
                    slave_mem_s2[addrs_in_s2+2],
                    slave_mem_s2[addrs_in_s2+3]
                };

            end
        end
    end  
endmodule
