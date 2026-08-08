`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 14:54:01
// Design Name: 
// Module Name: First_slave_fsm
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


module First_slave_fsm(
	input logic hclk_s1,
	input logic hreset_s1,
	input logic hwrite_s1,
	input logic [3:0]hmaster_s1,
	input logic [1:0]htrans_s1,
	input logic [2:0]hsize_s1,
	input logic hsel_s1,
	input logic [2:0]hburst_s1,
	input logic hready_s1,
	
	//Signal comming from Response_generator
	input logic [1:0]resp_out_s1,
	
	//Signal comming from Burst_size_gen
	input logic burst_size_s1, 
	
	//Signal comming from Data_generation_logic
	input logic [31:0]data_out_s1,
	
	output logic load_resp_s1,//internal signal
	
	output logic hready_out_s1,
	output logic [31:0] hrdata_s1,
	output logic [1:0] hresp_s1,
	
	//Signal going to Response_generator as input
	output logic load_data_s1, //internal signal
	
	//Input Signal for Data_generation_logic
	output logic load_addrs_s1, //internal signal
	output logic store_data_s1 //internal signal
		
    );
    
    reg[3:0] state_s1,next_state_s1;
    reg stay_s1;
    //reg store_data_s1;
    //reg load_addrs_s1,load_resp_s1,load_data_s1;
    //int count_s1,burst_size_s1;
    int count_s1;
    
    parameter reg[3:0] IDLE_SLAVE_FIRST=4'b0000, WRITE_WAIT_SLAVE_FIRST =4'b0001,
    SEQ_WRITE_SLAVE_FIRST =4'b0010, READ_WAIT_SLAVE_FIRST =4'b0011,SEQ_READ_SLAVE_FIRST =4'b0100,
    WAIT_STATE_SLAVE_FIRST =4'b0101;
    
    reg [31:0]data_out_s1, address_in_s1, data_mem_s1;
    reg [1:0]resp_out_s1;
    
   // parameter reg [31:0]data_memory_s1 =32'h1A5b203b;
    always_comb
    begin
    	case(state_s1)
    		IDLE_SLAVE_FIRST:begin
    			if(hready_s1)
    			begin	
    				if(hmaster_s1 == 4'b0000)
    				next_state_s1=IDLE_SLAVE_FIRST;
    				else begin
    				if(hsel_s1 && htrans_s1 != 2'b00)
    					next_state_s1 = (hwrite_s1)?((hburst_s1==3'b000)? WRITE_WAIT_SLAVE_FIRST:SEQ_WRITE_SLAVE_FIRST)
    									:((hburst_s1==3'b000)?READ_WAIT_SLAVE_FIRST:SEQ_READ_SLAVE_FIRST);
    					else if(htrans_s1 == 2'b00)
    					next_state_s1 =IDLE_SLAVE_FIRST;
    					else
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				end
    			end
    			end
    			/*
    			ADDRESS_SLAVE_FIRST:begin
    				if(hburst_s1 ==3'b000)
    					next_state_s1 = WRITE_WAIT_SLAVE_FIRST;
    				else
    					next_state_s1=SEQ_WRITE_SLAVE_FIRST;
    				end
    				*/
    			WRITE_WAIT_SLAVE_FIRST:
    			begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else
    					next_state_s1 =WAIT_STATE_SLAVE_FIRST;
    			end
    			SEQ_WRITE_SLAVE_FIRST: begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else begin
    				stay_s1 =(count_s1 ==burst_size_s1-1)?0:1;
    					next_state_s1 = (count_s1 ==burst_size_s1-1)?WRITE_WAIT_SLAVE_FIRST:SEQ_WRITE_SLAVE_FIRST;
    				end
    			end
    			READ_WAIT_SLAVE_FIRST: begin
    				if(hmaster_s1 == 4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else
    				 	next_state_s1 = WAIT_STATE_SLAVE_FIRST;
    			end
    			SEQ_READ_SLAVE_FIRST: begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else begin
    				stay_s1 =(count_s1 == burst_size_s1)?0:1;
    				next_state_s1= (count_s1 == burst_size_s1)?READ_WAIT_SLAVE_FIRST: SEQ_READ_SLAVE_FIRST;
    				end
    			end
    			WAIT_STATE_SLAVE_FIRST:
    			//wait for two cycles before going to idle
    			next_state_s1 =IDLE_SLAVE_FIRST;
    		endcase
    	end
   
   always @(posedge hclk_s1,negedge hreset_s1)
   begin
   	if(!hreset_s1)
   		state_s1 <= IDLE_SLAVE_FIRST;
   	else
   		state_s1 <= next_state_s1;
   	end
   	
   always_comb
   begin	
   		case(state_s1)
   			IDLE_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =0;	//internal signal
   				load_resp_s1 =0;		//internal signal
   				//hrdata_s1 =data_out_s1;
   			end
 
    			WRITE_WAIT_SLAVE_FIRST:
    			begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else
    					next_state_s1 =WAIT_STATE_SLAVE_FIRST;
    			end
    			SEQ_WRITE_SLAVE_FIRST: begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else begin
    				stay_s1 =(count_s1 ==burst_size_s1-1)?0:1;
    					next_state_s1 = (count_s1 ==burst_size_s1-1)?WRITE_WAIT_SLAVE_FIRST:SEQ_WRITE_SLAVE_FIRST;
    				end
    			end
    			READ_WAIT_SLAVE_FIRST: begin
    				if(hmaster_s1 == 4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else
    				 	next_state_s1 = WAIT_STATE_SLAVE_FIRST;
    			end
    			SEQ_READ_SLAVE_FIRST: begin
    				if(hmaster_s1 ==4'b0000)
    					next_state_s1 = IDLE_SLAVE_FIRST;
    				else begin
    				stay_s1 =(count_s1 == burst_size_s1)?0:1;
    				next_state_s1= (count_s1 == burst_size_s1)?READ_WAIT_SLAVE_FIRST: SEQ_READ_SLAVE_FIRST;
    				end
    			end
    			WAIT_STATE_SLAVE_FIRST:
    			//wait for two cycles before going to idle
    			next_state_s1 =IDLE_SLAVE_FIRST;
    		endcase
    	end
   
   always @(posedge hclk_s1,negedge hreset_s1)
   begin
   	if(!hreset_s1)
   		state_s1 <= IDLE_SLAVE_FIRST;
   	else
   		state_s1 <= next_state_s1;
   	end
   	
   always_comb
   begin	
   		case(state_s1)
   			IDLE_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =0;	//internal signal
   				load_resp_s1 =0;		//internal signal
   				//hrdata_s1 =data_out_s1;
   			end
   			/*ADDRESS_SLAVE_FIRST:begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =hwrite_s1?0:1;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =1;	//internal signal
   				
   				//hrdata_s1 = 'bx;
   			end */
   			WRITE_WAIT_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =1;	//internal signal
   				load_addrs_s1 =0;	//internal signal
   				load_resp_s1 =0;		//internal signal
   			end
   			SEQ_WRITE_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =1;	//internal signal
   				load_addrs_s1 =1;	//internal signal
   				load_resp_s1 =1;		//internal signal
   			end
   			READ_WAIT_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =0;	//internal signal
   				load_resp_s1 =0;	//internal signal
   				hrdata_s1 =data_out_s1;		
   			end
   			SEQ_READ_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =1;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =1;	//internal signal
   				load_resp_s1 =1;		//internal signal
   				hrdata_s1 =data_out_s1;
   			end
   			WAIT_STATE_SLAVE_FIRST: begin
   				hready_out_s1 =1;
   				hresp_s1 =resp_out_s1;
   				load_data_s1 =0;	//internal signal
   				store_data_s1 =0;	//internal signal
   				load_addrs_s1 =0;	//internal signal
   				load_resp_s1 =0;		//internal signal
   				hrdata_s1= data_out_s1;
   			end
   		endcase
   	end
   	
   	always_ff @(posedge hclk_s1)begin
   		if(stay_s1)
   			count_s1 <= count_s1 +1;
   		else
   			count_s1 <= 1;
   		end
endmodule
