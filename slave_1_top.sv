`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 19:08:05
// Design Name: 
// Module Name: slave_1_top
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


module slave_1_top(
	input logic hclk_s1,
	input logic hreset_s1,
	
	input logic hwrite_s1,
	input logic hsel_s1,
	input logic hready_s1,
    
    input logic [31:0]haddr_s1,
    input logic [3:0]hmaster_s1,
    input logic [1:0]htrans_s1,
    input logic [2:0]hsize_s1,
    input logic [2:0]hburst_s1,
    
    input logic [31:0]hwdata_s1,
    
    output logic hready_out_s1,
    output logic [31:0]hrdata_s1,
    output logic [1:0]hresp_s1
    
    );
    
    //Signal for Response_generator and FSM
    wire load_resp_s1;
    wire [1:0]resp_out_s1;
  
  	//Signal for Address_loader and Data_generation_logic
    wire [31:0]address_in_s1;
    
    //Signal for FSM and Address_loader
    wire load_addrs_s1;
    
    //Signal for FSM and Data_generation_logic
    wire load_data_s1,store_data_s1;
    wire [31:0]data_out_s1;
    
    //Signal for Burst_size_gen and FSM
    wire burst_size_s1;
    
    
    
    First_slave_fsm fsm_s1(
				 .hclk_s1(hclk_s1),
				 .hreset_s1(hreset_s1),
				 .hwrite_s1(hwrite_s1),
				 .hmaster_s1(hmaster_s1),
				 .htrans_s1(htrans_s1),
				 .hsize_s1(hsize_s1),
				 .hsel_s1(hsel_s1),
				 .hburst_s1(hburst_s1),
				 .hready_s1(hready_s1),
				 .resp_out_s1(resp_out_s1),	
				 .burst_size_s1(burst_size_s1), 
				 .data_out_s1(data_out_s1),
				 
				 //output
				 .load_resp_s1(load_resp_s1),//internal signal
				 .hready_out_s1(hready_out_s1),
				 .hrdata_s1(hrdata_s1),
				 .hresp_s1(hresp_s1),
				 .load_data_s1(load_data_s1), //internal signal
				 .load_addrs_s1(load_addrs_s1),
				 .store_data_s1(store_data_s1) 
			 );
	
	
    burst_size_gen_slave_1 burst_gen_s1(.hburst_s1(hburst_s1),
    									.burst_size_s1(burst_size_s1)
    								   );
   
   
    address_loader_slave_1 addr_loader_s1(.hclk_s1(hclk_s1),
    									  .load_addrs_s1(load_addrs_s1),
    									  .hwrite_s1(hwrite_s1),
    									  .haddr_s1(haddr_s1),
    									  .address_in_s1(address_in_s1)
    									  );
    
    
    data_gen_logic_slave_1 data_gen_s1( .hclk_s1(hclk_s1),
    									.hreset_s1(hreset_s1),
    									.addrs_in_s1(address_in_s1),
    									.hready_s1(hready_s1),
    									.hwdata_s1(hwdata_s1),
    									.load_data_s1(load_data_s1),
    									.store_data_s1(store_data_s1),
    									.data_out_s1(data_out_s1)
    								 ); 	 
   
   
    response_generator_slave_1 resp_gen_s1( .hclk_s1(hclk_s1),
    										.haddr_s1(haddr_s1),
    										.hwrite_s1(hwrite_s1),
    										.load_resp_s1(load_resp_s1),
    										.resp_out_s1(resp_out_s1)
    									  );
    
	
endmodule
