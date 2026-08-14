`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:59:33
// Design Name: 
// Module Name: data_gen_logic_s3
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


module data_gen_logic_s3(
    input logic        hclk_s3,
    input logic        hreset_s3,
    input logic        hready_s3,

    input logic [31:0] addrs_in_s3,
    input logic [31:0] hwdata_s3,

    input logic        load_data_s3,
    input logic        store_data_s3,

    output logic [31:0] data_out_s3
);

    parameter logic [31:0] DATA_MEMORY_S3 = 32'h1A5B203B;

    logic [31:0] data_mem_s3;
    logic [7:0]  slave_mem_s3 [2048:3071];

    always_ff @(posedge hclk_s3) begin
        if (!hreset_s3) begin

            data_mem_s3 = DATA_MEMORY_S3;

            for (int i = 2048; i < 3072; i = i + 4) begin
                slave_mem_s3[i]   <= data_mem_s3[31:24];
                slave_mem_s3[i+1] <= data_mem_s3[23:16];
                slave_mem_s3[i+2] <= data_mem_s3[15:8];
                slave_mem_s3[i+3] <= data_mem_s3[7:0];

                data_mem_s3 = data_mem_s3 + 32'd4;
            end

            data_out_s3 <= 32'b0;
        end
        else begin
            // Write
            if (store_data_s3 && hready_s3) begin
                slave_mem_s3[addrs_in_s3]   <= hwdata_s3[31:24];
                slave_mem_s3[addrs_in_s3+1] <= hwdata_s3[23:16];
                slave_mem_s3[addrs_in_s3+2] <= hwdata_s3[15:8];
                slave_mem_s3[addrs_in_s3+3] <= hwdata_s3[7:0];
            end

            // Read
            if (load_data_s3 && hready_s3) begin
            
                data_out_s3 <= {
                    slave_mem_s3[addrs_in_s3],
                    slave_mem_s3[addrs_in_s3+1],
                    slave_mem_s3[addrs_in_s3+2],
                    slave_mem_s3[addrs_in_s3+3]
                };

            end
        end
    end
endmodule

