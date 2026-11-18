`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 18:15:07
// Design Name: 
// Module Name: default_master_top
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


module default_master_top(
		input logic hclk_def,
		input logic hreset_def,
		input logic hgrant_def,
		input logic hready_def,
		
		input logic [1:0]hresp_def,
		input logic [31:0]hrdata_def,
		
		output logic hbusreq_def,
		output logic hwrite_def,
		output logic [1:0]htrans_def,
		output logic [31:0]haddr_def,
		
		output logic [2:0]hsize_def,
		output logic [2:0]hburst_def,
		output logic [31:0]hwdata_def  
    );
    
	//Signal for Burst_size_gen and FSM
    int def_burst_size;

	//Signal for Address_calculation_logic and Address_generation_logic
    wire [7:0] def_wrap_byte_variable;
    wire [31:0] def_start_wrap_address;
    wire [31:0] def_end_wrap_address;
    wire [31:0] def_remainder_temp;  

	//Signal for Address_generation_logic and FSM
	wire [31:0] def_addr_out; 
	logic def_load_addr;  

	//Signal for Data_generation_logic and FSM
	wire [31:0] def_data_out;
	logic def_load_data; 
    
    default_master_fsm def_mast_fsm(
    							//Inputs
								.def_hclk(hclk_def),
								.def_hreset(hreset_def),
								.def_hready(hready_def), 
								.def_hresp(hresp_def),
								 
								.def_hgrant(hgrant_def),
								.def_hrdata(hrdata_def),
								
								.def_data_out(def_data_out),	//Coming from data generation logic(Size=32bit)
								.def_burst_size(def_burst_size),	//Coming from Burst size generation logic (int type)
								.def_addr_out(def_addr_out),	//Coming from Address generation logic (Size=32bit)	
								
								//Output
								.def_hwdata(hwdata_def),
								.def_haddr(haddr_def), 
								.def_hburst(hburst_def),
								.def_hsize(hsize_def),
								.def_hwrite(hwrite_def), 
								.def_htrans(htrans_def), 
								.def_hbusreq(hbusreq_def),
								
								.def_load_data(),	//Signal going to data generation logic (size=1bit)
								.def_load_addr()	//Signal going to Address generation logic (Size=1bit)	 
							);
							
							
    def_burst_size_generation default_burst_size_generation(
    														.def_hburst(hburst_def),
    														.def_burst_size(def_burst_size)
    													  );
    													
    def_address_calc_logic default_address_calculation(
														.def_burst_size(def_burst_size),		//Signal coming from burst size generation logic
														
														//Output
														.def_wrap_byte_variable(def_wrap_byte_variable),	
														.def_start_wrap_address(def_start_wrap_address),	//32bit
														.def_end_wrap_address(def_end_wrap_address),	//32bit
														.def_remainder_temp(def_remainder_temp)	//32bit
													  );
													  
    def_address_generation_logic default_address_generation_logic(
    															 .def_hclk(hclk_def),
																 .def_hreset(hreset_def),
																 .def_hready(hready_def),
																 
																 .def_hburst(hburst_def),
																 .def_load_addr(def_load_addr),
																 
																 .def_wrap_byte_variable(def_wrap_byte_variable),
																 .def_start_wrap_address(def_start_wrap_address),
																 .def_end_wrap_address(def_end_wrap_address),
																 .def_remainder_temp(def_remainder_temp),
														
																 .def_haddr(haddr_def),				//Signal coming from FSM
																 //Output
																 .def_addr_out(def_addr_out)			//Signal going to FSM
															);
      
    data_gen_logic_mast_def default_mast_data_gen_logic(
    													.def_hclk(hclk_def),
														.def_hreset(hreset_def),
														.def_hready(hready_def),
														
														.def_load_out(def_load_data),				//Signal coming from FSM
														
														.def_data_out(def_data_out)					//Signal going to FSM
													  );
  	  
endmodule
