`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 13:02:47
// Design Name: 
// Module Name: data_gen_logic_slave_1
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


module data_gen_logic_slave_1(
	input logic hclk_s1,
	input logic hreset_s1,
	input logic hready_s1,
	
	//Signal comming from Address_loader
	input logic [31:0]addrs_in_s1,
	
	input logic [31:0]hwdata_s1, 
	
	//Signal comming from FSM
	input logic load_data_s1,
	input logic store_data_s1,
	
	//Signal going to FSM
	output logic [31:0]data_out_s1
    );
    
    parameter logic [31:0] DATA_MEMORY_S1 = 32'h1A5B203B;

    logic [31:0] data_mem_s1;
    logic [7:0]  slave_mem_s1 [0:1023];

    always_ff @(posedge hclk_s1) begin

        if (!hreset_s1) begin

            data_mem_s1 = DATA_MEMORY_S1;

            for (int i = 0; i < 1024; i = i + 4) begin
                slave_mem_s1[i]   <= data_mem_s1[31:24];
                slave_mem_s1[i+1] <= data_mem_s1[23:16];
                slave_mem_s1[i+2] <= data_mem_s1[15:8];
                slave_mem_s1[i+3] <= data_mem_s1[7:0];

                data_mem_s1 = data_mem_s1 + 32'd4;
            end

            data_out_s1 <= 32'b0;
        end

        else begin

            // Write
            if (store_data_s1 && hready_s1) begin
                slave_mem_s1[addrs_in_s1]   <= hwdata_s1[31:24];
                slave_mem_s1[addrs_in_s1+1] <= hwdata_s1[23:16];
                slave_mem_s1[addrs_in_s1+2] <= hwdata_s1[15:8];
                slave_mem_s1[addrs_in_s1+3] <= hwdata_s1[7:0];
            end

            // Read
            if (load_data_s1 && hready_s1) begin
                data_out_s1 <= {
                    slave_mem_s1[addrs_in_s1],
                    slave_mem_s1[addrs_in_s1+1],
                    slave_mem_s1[addrs_in_s1+2],
                    slave_mem_s1[addrs_in_s1+3]
                };
            end
        end
    end
endmodule
