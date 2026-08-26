`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 02:13:07
// Design Name: 
// Module Name: default_slave_top
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


module default_slave_top(
	input logic hclk_def,
	input logic hreset_def,
	
	input logic hwrite_def,
	input logic hsel_def,
	input logic hready_def,
    
    input logic [31:0]haddr_def,
    input logic [3:0]hmaster_def,
    input logic [1:0]htrans_def,
    input logic [2:0]hsize_def,
    input logic [2:0]hburst_def,
    
    input logic [31:0]hwdata_def,
    
    output logic hready_out_def,
    output logic [31:0]hrdata_def,
    output logic [1:0]hresp_def
    );
    
    
    // Instantiation of the compliant FSM
    default_slave_fsm def_slv_fsm (
        .hclk_def       (hclk_def),
        .hreset_def     (hreset_def),
        .hsel_def       (hsel_def),
        .hready_def     (hready_def),
        .htrans_def     (htrans_def),
        .hready_out_def (hready_out_def),
        .hresp_def      (hresp_def)
    );

    // Default slave does not drive data phase transfers
    assign hrdata_def = 32'b0;

    /* Unused submodules kept for reference but deactivated as per Default Slave protocol:
    def_slv_burst_size_gen 	default_slv_burst_size_gen( .def_hburst(),
    													.def_burst_size()
    												);
    													
    def_slv_address_loader 	default_slv_addr_loader(
    												 .def_hclk(),
													 .def_load_addrs(),
													 .def_hwrite(),
												     .def_haddr(),
												     .def_address_in()
												);
    													
    def_slv_data_gen_logic 	default_slv_data_gen_logic( .def_hclk(),
														.def_hreset(),
														.def_addrs_in(),
														.def_hready(),
														.def_hwdata(),
														.def_load_data(),
														.def_store_data(),
														.def_data_out()
													);
    													
    def_slv_response_generator 	default_slv_resp_gen(.def_hclk(),
    												 .def_haddr(),
    												 .def_hwrite(),
    											 	 .def_load_resp(),
    												 .def_resp_out()
    											);
    */
    
endmodule
