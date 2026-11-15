`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.07.2026 23:09:29
// Design Name: 
// Module Name: master_2_top
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


module Master_2_top(
	input logic hclk_m2,
	input logic hreset_m2,
	input logic hgrant_m2,
	input logic hready_m2,
	
	input logic [1:0]hresp_m2,
	input logic [31:0]hrdata_m2,
	
	output logic hbusreq_m2,
	output logic hwrite_m2,
	output logic [1:0]htrans_m2,
	output logic [31:0]haddr_m2,
	
	output logic [2:0]hsize_m2,
	output logic [2:0]hburst_m2,
	output logic [31:0]hwdata_m2  
    );
  
	Second_master_fsm fsm_mast_2(//Inputs
    							 .hclk_m2(),
    							 .hreset_m2(),  
    							 .hready_m2(),
								 .hresp_m2(), 
								 
								 .hgrant_m2(),
								 .hrdata_m2(),  
								 
								 .data_out_m2(), 	//Coming from data generation logic(Size=32bit)
								 .burst_size_m2(),  //Coming from Burst size generation logic (int type)
								 .addr_out_m2(),    //Coming from Address generation logic (Size=32bit)
								
								 //Output
								 .hwdata_m2(),				 
								 .haddr_m2(), 
								 .hburst_m2(),
								 .hsize_m2(),
								 .hwrite_m2(),
								 .htrans_m2(),
								 .hbusreq_m2(),
								 
								 .load_data_m2(),	//Signal going to data generation logic (size=1bit)
								 .load_addr_m2()	//Signal going to Address generation logic (Size=1bit)	 
							);

	burst_size_gen_mast_2 burst_generation_2(
											.hburst_m2(),
											.burst_size_m2()
										  ); 
	
	address_cal_logic_mast_2 addr_calculation_logic_master_2(
															.burst_size_m2(),
															
															//output
															.wrap_byte_variable_m2(),	//[7:0]
															.start_wrap_address_m2(),	//32bit
															.end_wrap_address_m2(),		//32bit
															.remainder_temp_m2()
														);
													
	address_gen_logic_mast_2 addr_gen_logic_mast_2(
													.hclk_m2(),
													.hreset_m2(),
													.hready_m2(),
													
													.hburst_m2(),
													.load_addr_m2(),
													
													.wrap_byte_variable_m2(),
													.start_wrap_address_m2(),
													.end_wrap_address_m2(),
													.remainder_temp_m2(),
													
													.haddr_m2(),		//Signal coming from FSM
													//Output
													.addr_out_m2()		//Signal going to FSM
												);
												
	data_gen_logic_mast_2 data_gen_mast_2(
										   .hclk_m2(),
										   .hreset_m2(),
										   .hready_m2(),
										   
										   .load_out_m2(),
										   //Output
										   .data_out_m2()
										);
	
endmodule

