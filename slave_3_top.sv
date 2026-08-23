`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 22:37:56
// Design Name: 
// Module Name: slave_3_top
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


module slave_3_top(
	input logic hclk_s3,
	input logic hreset_s3,
	
	input logic hwrite_s3,
	input logic hsel_s3,
	input logic hready_s3,
    
    input logic [31:0]haddr_s3,
    input logic [3:0]hmaster_s3,
    input logic [1:0]htrans_s3,
    input logic [2:0]hsize_s3,
    input logic [2:0]hburst_s3,
    
    input logic [31:0]hwdata_s3,
    
    output logic hready_out_s3,
    output logic [31:0]hrdata_s3,
    output logic [1:0]hresp_s3
    );
    
    //Signal for Response_generator and FSM
    wire load_resp_s3;
    wire [1:0]resp_out_s3;
  
  	//Signal for Address_loader and Data_generation_logic
    wire [31:0]address_in_s3;
    
    //Signal for FSM and Address_loader
    wire load_addrs_s3;
    
    //Signal for FSM and Data_generation_logic
    wire load_data_s3,store_data_s3;
    wire [31:0]data_out_s3;
    
    //Signal for Burst_size_gen and FSM
    wire burst_size_s3;
    
    Third_slave_fsm fsm_s3( 
						 .hclk_s3(hclk_s3),
						 .hreset_s3(hreset_s3),
						 .hwrite_s3(hwrite_s3),
						 .hmaster_s3(hmaster_s3),
						 .htrans_s3(htrans_s3),
						 .hsize_s3(hsize_s3),
						 .hsel_s3(hsel_s3),
						 .hburst_s3(hburst_s3),
						 .hready_s3(hready_s3),
						 .resp_out_s3(resp_out_s3),	
						 .burst_size_s3(burst_size_s3), 
						 .data_out_s3(data_out_s3),
						 
						 //output
						 .load_resp_s3(load_resp_s3),//internal signal
						 .hready_out_s3(hready_out_s3),
						 .hrdata_s3(hrdata_s3),
						 .hresp_s3(hresp_s3),
						 .load_data_s3(load_data_s3), //internal signal
						 .load_addrs_s3(load_addrs_s3),
						 .store_data_s3(store_data_s3)
						);
    
    burst_size_gen_s3 s3_burst_size( .hburst_s3(hburst_s3),
    								 .burst_size_s3(burst_size_s3)
    							 );
    							 
    address_loader_s3 addr_loader_s3(
    								.hclk_s3(hclk_s3),
									.load_addrs_s3(load_addrs_s3),
									.hwrite_s3(hwrite_s3),
									.haddr_s3(haddr_s3),
									//Output
									.address_in_s3(address_in_s3)
								);
								
    data_gen_logic_s3 data_gen_s3( 
    								.hclk_s3(hclk_s3),
									.hreset_s3(hreset_s3),
									.hready_s3(hready_s3),
							
									.addrs_in_s3(address_in_s3),
									.hwdata_s3(hwdata_s3),
								
									.load_data_s3(load_data_s3),
									.store_data_s3(store_data_s3),
							
									.data_out_s3(data_out_s3)
								);
    response_generator_s3 resp_gen_s3(
    								  .hclk_s3(hclk_s3),
									  .haddr_s3(haddr_s3),
									  .hwrite_s3(hwrite_s3),
									  .load_resp_s3(load_resp_s3),
										
									  .resp_out_s3(resp_out_s3)
									);
endmodule
