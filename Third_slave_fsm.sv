`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 21:55:27
// Design Name: 
// Module Name: Third_slave_fsm
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


module Third_slave_fsm(
	input logic hclk_s3,
	input logic hreset_s3,
	input logic hwrite_s3,
	
	input logic [3:0]hmaster_s3,
	input logic [1:0]htrans_s3,
	input logic [2:0]hsize_s3,
	
	input logic hsel_s3,
	input logic [2:0]hburst_s3,
	input logic hready_s3,
	
	//Signal coming from Response_generator
	input logic [1:0]resp_out_s3,
	
	//Signal coming from Burst_size_gen
	input logic burst_size_s3,
	
	//Signal coming from Data_generation_logic
	input logic [31:0]data_out_s3,
	
	
	output logic load_resp_s3,//Internal signal	
	output logic hready_out_s3,
	output logic [31:0] hrdata_s3,
	output logic [1:0] hresp_s3,
	
	//Signal going to Response_generator as input
	output logic load_data_s3,//Internal signal
	
	//Input Signal for Data_generation_logic
	output logic load_addrs_s3, //internal signal
	output logic store_data_s3 //internal signal
		
    );
    
    //reg [7:0] slave_mem_s3[2048:3071];
    
    reg[3:0] state_s3,next_state_s3;
    reg stay_s3;
    int count_s3;
    
    parameter reg[3:0] IDLE_SLAVE_THIRD=4'b0000,       WRITE_WAIT_SLAVE_THIRD =4'b0001,
    				   SEQ_WRITE_SLAVE_THIRD =4'b0010, READ_WAIT_SLAVE_THIRD =4'b0011,
    				   SEQ_READ_SLAVE_THIRD =4'b0100,  WAIT_STATE_SLAVE_THIRD =4'b0101;
    
    reg [31:0]data_out_s3, address_in_s3, data_mem_s3,indata_s3;
    //reg [1:0]resp_out_s3;
    
    parameter reg [31:0]data_memory_s3 =32'h1A5b203b;
    always_comb
    begin
    	case(state_s3)
    		IDLE_SLAVE_THIRD:begin
    			if(hready_s3)
    			begin	
    				if(hmaster_s3 == 4'b0000)
    				next_state_s3=IDLE_SLAVE_THIRD;
    				else begin
    				if(hsel_s3 && htrans_s3 != 2'b00)
    					next_state_s3 = (hwrite_s3)?((hburst_s3==3'b000)? WRITE_WAIT_SLAVE_THIRD:SEQ_WRITE_SLAVE_THIRD)
    									:((hburst_s3==3'b000)?READ_WAIT_SLAVE_THIRD:SEQ_READ_SLAVE_THIRD);
    					else if(htrans_s3 == 2'b00)
    					next_state_s3 =IDLE_SLAVE_THIRD;
    					else
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				end
    			end
    			end
    			/*
    			ADDRESS_SLAVE_THIRD:begin
    				if(hburst_s3 ==3'b000)
    					next_state_s3 = WRITE_WAIT_SLAVE_THIRD;
    				else
    					next_state_s3=SEQ_WRITE_SLAVE_THIRD;
    				end
    				*/
    			WRITE_WAIT_SLAVE_THIRD:
    			begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else
    					next_state_s3 =WAIT_STATE_SLAVE_THIRD;
    			end
    			SEQ_WRITE_SLAVE_THIRD: begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else begin
    				stay_s3 =(count_s3 ==burst_size_s3-1)?0:1;
    					next_state_s3 = (count_s3 ==burst_size_s3-1)?WRITE_WAIT_SLAVE_THIRD:SEQ_WRITE_SLAVE_THIRD;
    				end
    			end
    			READ_WAIT_SLAVE_THIRD: begin
    				if(hmaster_s3 == 4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else
    				 	next_state_s3 = WAIT_STATE_SLAVE_THIRD;
    			end
    			SEQ_READ_SLAVE_THIRD: begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else begin
    				stay_s3 =(count_s3 == burst_size_s3)?0:1;
    				next_state_s3= (count_s3 == burst_size_s3)?READ_WAIT_SLAVE_THIRD: SEQ_READ_SLAVE_THIRD;
    				end
    			end
    			WAIT_STATE_SLAVE_THIRD:
    			//wait for two cycles before going to idle
    			next_state_s3 =IDLE_SLAVE_THIRD;
    		endcase
    	end
   
   always @(posedge hclk_s3,negedge hreset_s3)
   begin
   	if(!hreset_s3)
   		state_s3 <= IDLE_SLAVE_THIRD;
   	else
   		state_s3 <= next_state_s3;
   	end
   	
   always_comb
   begin	
   		case(state_s3)
   			IDLE_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =0;	//internal signal
   				load_resp_s3 =0;		//internal signal
   				//hrdata_s3 =data_out_s3;
   			end
 
    			WRITE_WAIT_SLAVE_THIRD:
    			begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else
    					next_state_s3 =WAIT_STATE_SLAVE_THIRD;
    			end
    			SEQ_WRITE_SLAVE_THIRD: begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else begin
    				stay_s3 =(count_s3 ==burst_size_s3-1)?0:1;
    					next_state_s3 = (count_s3 ==burst_size_s3-1)?WRITE_WAIT_SLAVE_THIRD:SEQ_WRITE_SLAVE_THIRD;
    				end
    			end
    			READ_WAIT_SLAVE_THIRD: begin
    				if(hmaster_s3 == 4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else
    				 	next_state_s3 = WAIT_STATE_SLAVE_THIRD;
    			end
    			SEQ_READ_SLAVE_THIRD: begin
    				if(hmaster_s3 ==4'b0000)
    					next_state_s3 = IDLE_SLAVE_THIRD;
    				else begin
    				stay_s3 =(count_s3 == burst_size_s3)?0:1;
    				next_state_s3= (count_s3 == burst_size_s3)?READ_WAIT_SLAVE_THIRD: SEQ_READ_SLAVE_THIRD;
    				end
    			end
    			WAIT_STATE_SLAVE_THIRD:
    			//wait for two cycles before going to idle
    			next_state_s3 =IDLE_SLAVE_THIRD;
    		endcase
    	end
   
   always @(posedge hclk_s3,negedge hreset_s3)
   begin
   	if(!hreset_s3)
   		state_s3 <= IDLE_SLAVE_THIRD;
   	else
   		state_s3 <= next_state_s3;
   	end
   	
   always_comb
   begin	
   		case(state_s3)
   			IDLE_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =0;	//internal signal
   				load_resp_s3 =0;		//internal signal
   				//hrdata_s3 =data_out_s3;
   			end
   			/*ADDRESS_SLAVE_THIRD:begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =hwrite_s3?0:1;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =1;	//internal signal
   				
   				//hrdata_s3 = 'bx;
   			end */
   			WRITE_WAIT_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =1;	//internal signal
   				load_addrs_s3 =0;	//internal signal
   				load_resp_s3 =0;		//internal signal
   			end
   			SEQ_WRITE_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =1;	//internal signal
   				load_addrs_s3 =1;	//internal signal
   				load_resp_s3 =1;		//internal signal
   			end
   			READ_WAIT_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =0;	//internal signal
   				load_resp_s3 =0;	//internal signal
   				hrdata_s3 =data_out_s3;		
   			end
   			SEQ_READ_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =1;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =1;	//internal signal
   				load_resp_s3 =1;		//internal signal
   				hrdata_s3 =data_out_s3;
   			end
   			WAIT_STATE_SLAVE_THIRD: begin
   				hready_out_s3 =1;
   				hresp_s3 =resp_out_s3;
   				load_data_s3 =0;	//internal signal
   				store_data_s3 =0;	//internal signal
   				load_addrs_s3 =0;	//internal signal
   				load_resp_s3 =0;		//internal signal
   				hrdata_s3= data_out_s3;
   			end
   		endcase
   	end
   	
   	always_ff @(posedge hclk_s3)begin
   		if(stay_s3)
   			count_s3 <= count_s3 +1;
   		else
   			count_s3 <= 1;
   		end
endmodule

