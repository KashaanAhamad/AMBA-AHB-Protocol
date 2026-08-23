`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2026 02:02:47
// Design Name: 
// Module Name: slave_2_top
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


module slave_2_top(
	input logic hclk_s2,
	input logic hreset_s2,
	
	input logic hwrite_s2,
	input logic hsel_s2,
	input logic hready_s2,
    
    input logic [31:0]haddr_s2,
    input logic [3:0]hmaster_s2,
    input logic [1:0]htrans_s2,
    input logic [2:0]hsize_s2,
    input logic [2:0]hburst_s2,
    
    input logic [31:0]hwdata_s2,
    
    output logic hready_out_s2,
    output logic [31:0]hrdata_s2,
    output logic [1:0]hresp_s2
    );
    
    //Signal for Response_generator and FSM
    wire load_resp_s2;
    wire [1:0]resp_out_s2;
  
  	//Signal for Address_loader and Data_generation_logic
    wire [31:0]address_in_s2;
    
    //Signal for FSM and Address_loader
    wire load_addrs_s2;
    
    //Signal for FSM and Data_generation_logic
    wire load_data_s2,store_data_s2;
    wire [31:0]data_out_s2;
    
    //Signal for Burst_size_gen and FSM
    wire burst_size_s2;
    
    Second_slave_fsm fsm_s2( 
    					 .hreset_s2(hreset_s2),
						 .hclk_s2(hclk_s2),
						 .hwrite_s2(hwrite_s2),
						 .hmaster_s2(hmaster_s2),
						 .htrans_s2(htrans_s2),
						 .hsize_s2(hsize_s2),
						 .hsel_s2(hsel_s2),
						 .hburst_s2(hburst_s2),
						 .hready_s2(hready_s2),
						 
						 
						 .resp_out_s2(resp_out_s2),
						 .burst_size_s2(burst_size_s2),
						 .data_out_s2(data_out_s2),
						 
						 //output
						 .load_resp_s2(load_resp_s2),
						 .hready_out_s2(hready_out_s2),
						 .hresp_s2(hresp_s2),
						 .hrdata_s2(hrdata_s2),
						 
						 .load_data_s2(load_data_s2),
						 .load_addrs_s2(load_addrs_s2),
						 .store_data_s2(store_data_s2)		 
						 
					);
					
    burst_size_gen_s2 burst_size_gen_slave_2(
    										.hburst_s2(hburst_s2),
											.burst_size_s2(burst_size_s2)
										);
										
    address_loader_s2 address_loader_slave_2(
    										 .hclk_s2(hclk_s2),
											 
											 .load_addrs_s2(load_addrs_s2),
											 .haddr_s2(haddr_s2),
											 .hwrite_s2(hwrite_s2),
											
											 //Output
											 .address_in_s2(address_in_s2)
										);
										
    data_gen_logic_s2 data_gen_logic_slave_2(
    										.hclk_s2(hclk_s2),
											.hreset_s2(hreset_s2),
											.hready_s2(hready_s2),
											
											.addrs_in_s2(address_in_s2),
											.hwdata_s2(hwdata_s2), 
											
											.load_data_s2(load_data_s2),
											.store_data_s2(store_data_s2),
											//output
											.data_out_s2(data_out_s2)
										);
										
    response_generator_s2 response_generator_slave_2(
													.hclk_s2(hclk_s2),
													.haddr_s2(haddr_s2),
													.hwrite_s2(hwrite_s2),
													
													//Signal comming from FSM
													.load_resp_s2(load_resp_s2),
													
													//Output: Signal going to FSM
													.resp_out_s2(resp_out_s2)
												);

endmodule
