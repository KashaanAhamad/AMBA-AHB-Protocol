`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 18:09:11
// Design Name: 
// Module Name: master_1_top
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


module Master_1_top(
	input logic hclk_m1,
	input logic hreset_m1,
	input logic hgrant_m1,
	input logic hready_m1,
	
	input logic [1:0]hresp_m1,
	input logic [31:0]hrdata_m1,
	
	output logic hbusreq_m1,
	output logic hwrite_m1,
	output logic [1:0]htrans_m1,
	output logic [31:0]haddr_m1,
	
	output logic [2:0]hsize_m1,
	output logic [2:0]hburst_m1,
	output logic [31:0]hwdata_m1  

    );
    
    First_master_fsm fsm_mast_1( //Inputs
    							 .hclk_m1(),
    							 .hreset_m1(),  
    							 .hready_m1(),
								 .hresp_m1(), 
								 
								 .hgrant_m1(),
								 .hrdata_m1(), 
								  
								 .data_out_m1(), 	//Coming from data generation logic(Size=32bit)
								 .burst_size_m1(),  //Coming from Burst size generation logic (int type)
								 .addr_out_m1(),    //Coming from Address generation logic (Size=32bit)
								
								 //Output
								 .hwdata_m1(),				 
								 .haddr_m1(), 
								 .hburst_m1(),
								 .hsize_m1(),
								 .hwrite_m1(),
								 .htrans_m1(),
								 .hbusreq_m1(),
								 
								 .load_data_m1(),	//Signal going to data generation logic (size=1bit)
								 .load_addr_m1()	//Signal going to Address generation logic (Size=1bit)	 
							);
							
	 burst_size_generation mast_1_gen_logic(
    										.hburst_m1(),
    										.burst_size_m1()
    									 );
    
    address_calc_logic mast_1_addr_calc_logic(
    										.burst_size_m1(),			//Signal coming from burst size generation logic
											
											//output
											.wrap_byte_variable_m1(),	//[7:0]
											.start_wrap_address_m1(),	//32bit
											.end_wrap_address_m1(),		//32bit
											.remainder_temp_m1()		//32bit	
										);
										
    address_generation_logic mast_1_addr_gen_logic(
    												.hclk_m1(),
													.hreset_m1(),
													.hready_m1(),
													
													.hburst_m1(),
													.load_addr_m1(),
													
													.wrap_byte_variable_m1(),
													.start_wrap_address_m1(),
													.end_wrap_address_m1(),
													.remainder_temp_m1(),
													
													.haddr_m1(),		//Signal coming from FSM
													//Output
													.addr_out_m1()		//Signal going to FSM
												);
   
    data_gen_logic mast_1_data_gen_logic(
    									  .hclk_m1(),
										  .hreset_m1(),
										  .hready_m1(),
										  
										  .load_out_m1(),			//Signal coming from FSM
										  //Output
										  .data_out_m1()			//Signal going to FSM
										);
endmodule
