`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 02:20:30
// Design Name: 
// Module Name: def_data_gen_logic
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


module def_slv_data_gen_logic (
    input  logic        def_hclk,
    input  logic        def_hreset,
    input  logic        def_hready,

    input  logic [31:0] def_addrs_in,
    input  logic [31:0] def_hwdata,

    input  logic        def_load_data,
    input  logic        def_store_data,

    output logic [31:0] def_data_out
);

    always_ff @(posedge def_hclk) begin
        if (!def_hreset) begin
            def_data_out <= 32'b0;
        end
        else if (def_load_data && def_hready) begin
            // Invalid/unimplemented address.
            // Data is not meaningful for an ERROR response.
            def_data_out <= 32'b0;
        end
    end

endmodule