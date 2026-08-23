`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.07.2026 11:53:05
// Design Name: 
// Module Name: Second_slave_fsm
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


module Second_slave_fsm(
	input logic hreset_s2,
	input logic hclk_s2,
	
	input logic hwrite_s2,
	input logic [3:0]hmaster_s2,
	input logic [1:0]htrans_s2,
	input logic [2:0]hsize_s2,
	
	input logic hsel_s2,
	input logic [2:0]hburst_s2,
	input logic hready_s2,
	
	
	//Signal coming from Response_generator
	input logic [1:0]resp_out_s2,
	
	//Signal coming from Burst_size_gen
	input logic burst_size_s2,
	
	//Signal coming from Data_generation_logic
	input logic [31:0]data_out_s2,
	
	output logic load_resp_s2,//internal signal
	
	output logic hready_out_s2,
	output logic [1:0]hresp_s2,
	output logic [31:0]hrdata_s2,
	
	//Signal going to Response_generator as input
	output logic load_data_s2, //internal signal
	
	//Input Signal for Data_generation_logic
	output logic load_addrs_s2, //internal signal
	output logic store_data_s2 //internal signal
		
    );
   
   reg [3:0]state_s2,next_state_s2;
	
   //reg [7:0]slave_mem_s2[1024:2047];
	
	
	reg stay_s2,stay_wait_s2;
	int count_s2,count_wait_s2;
	
	parameter reg[3:0] IDLE_SLAVE_SECOND=4'b0000, 	ADDRESS_SLAVE_SECOND=4'b0001,
    				   WRITE_WAIT_SLAVE_SECOND =4'b0010, SEQ_WRITE_SLAVE_SECOND=4'b0011,
    				   READ_WAIT_SLAVE_SECOND=4'b0100,SEQ_READ_SLAVE_SECOND=4'b0101, 
    				   WAIT_STATE_SLAVE_SECOND =4'b0110, AFTER_WAIT_STATE_SLAVE_SECOND=4'b0101,
    				   LAST_WAIT_STATE_SLAVE_SECOND =4'b1000;
	
	reg [31:0] address_in_s2,data_mem_s2;
	
	
	parameter reg [31:0]data_memory_s2 =32'h1A5b203b;
	
	always_comb
	begin
		case(state_s2)
			IDLE_SLAVE_SECOND: begin
				if(hready_s2)
				begin
					if(hmaster_s2 ==4'b0000)
					  next_state_s2= IDLE_SLAVE_SECOND;
					else begin
					  if(hsel_s2 && htrans_s2 != 2'b00)
					   next_state_s2 = (hwrite_s2)?((hburst_s2 ==3'b000)?WRITE_WAIT_SLAVE_SECOND:SEQ_WRITE_SLAVE_SECOND)
					   									:((hburst_s2 ==3'b000)?READ_WAIT_SLAVE_SECOND:SEQ_READ_SLAVE_SECOND);
					  else if(htrans_s2 ==2'b00)
					   next_state_s2 =IDLE_SLAVE_SECOND;
					  else
					   next_state_s2 =IDLE_SLAVE_SECOND;
					 end
			 end
		end
		
		WRITE_WAIT_SLAVE_SECOND:
			next_state_s2 =LAST_WAIT_STATE_SLAVE_SECOND;
		SEQ_WRITE_SLAVE_SECOND: begin
			//stay_s2=0;
			stay_s2 = (count_s2 ==burst_size_s2-1)?0:1;
		   next_state_s2=(count_s2 ==burst_size_s2-1)?WRITE_WAIT_SLAVE_SECOND:WAIT_STATE_SLAVE_SECOND;
		end//check above if it is hburst_size or burst size
		READ_WAIT_SLAVE_SECOND:
			next_state_s2 = LAST_WAIT_STATE_SLAVE_SECOND;
		SEQ_READ_SLAVE_SECOND: begin
			stay_s2=(count_s2 == burst_size_s2-1)?0:1;
			next_state_s2 =(count_s2 == burst_size_s2-1)?READ_WAIT_SLAVE_SECOND:WAIT_STATE_SLAVE_SECOND;
		end
		
		WAIT_STATE_SLAVE_SECOND: begin
			//wait for 4 cycles before going to idle
			stay_wait_s2 = (count_wait_s2 == 2)?0:1;
			next_state_s2 = (count_wait_s2 ==2)? AFTER_WAIT_STATE_SLAVE_SECOND: WAIT_STATE_SLAVE_SECOND;
		end
		AFTER_WAIT_STATE_SLAVE_SECOND: begin
			//stay_s2=1;
			if(hwrite_s2)
				next_state_s2 =SEQ_WRITE_SLAVE_SECOND;
			else
				next_state_s2 = SEQ_READ_SLAVE_SECOND;
		end
		LAST_WAIT_STATE_SLAVE_SECOND: begin
			next_state_s2 =IDLE_SLAVE_SECOND;
		end
	endcase
end

always @(posedge hclk_s2,negedge hreset_s2)
begin
if(!hreset_s2)
 state_s2 <= IDLE_SLAVE_SECOND;
 else
 state_s2 <=next_state_s2;
 end
 
 
 always_comb
 begin
 	case(state_s2)
 		IDLE_SLAVE_SECOND: begin
 			hready_out_s2=1;	//0
 			hresp_s2 =resp_out_s2;
 			load_data_s2=(hwrite_s2)?0:1;	//internal signal
 			store_data_s2 =0;	//internal signal
 			load_addrs_s2 =1;	//internal signal
 			load_resp_s2 =0;	//internal signal
 			hrdata_s2 = hrdata_s2;
 		end
 		
 		WRITE_WAIT_SLAVE_SECOND: begin
 			hready_out_s2=1;	
 			hresp_s2 =resp_out_s2;
 			load_data_s2=0;		//internal signal
 			store_data_s2 =1;	//internal signal
 			load_addrs_s2 =0;	//internal signal
 			load_resp_s2 =0;	//internal signal
 		end
 		
 		SEQ_WRITE_SLAVE_SECOND: begin
 			hready_out_s2=0;	
 			hresp_s2 =resp_out_s2;
 			load_data_s2=0;	//internal signal
 			store_data_s2 =1;	//internal signal
 			load_addrs_s2 =0;	//internal signal
 			load_resp_s2 =1;	//internal signal
		end
		
		READ_WAIT_SLAVE_SECOND: begin
			hready_out_s2=1;	
 			hresp_s2 =resp_out_s2;
 			load_data_s2=0;	//internal signal
 			store_data_s2 =0;	//internal signal
 			load_addrs_s2 =0;	//internal signal
 			load_resp_s2 =0;	//internal signal
 			hrdata_s2 = data_out_s2;
 		end
 		
 		SEQ_READ_SLAVE_SECOND: begin
 			hready_out_s2=0;	
 			hresp_s2 =resp_out_s2;
 			load_data_s2=1;	//internal signal
 			store_data_s2 =0;	//internal signal
 			load_addrs_s2 =0;	//internal signal
 			load_resp_s2 =1;	//internal signal
 			hrdata_s2 = data_out_s2;
 		end
 		
 		WAIT_STATE_SLAVE_SECOND: begin
 			hready_out_s2=0;	
 			hresp_s2 =resp_out_s2;
 			load_data_s2=1;	//internal signal
 			store_data_s2 =0;			//internal signal
 			load_addrs_s2 =0;			//internal signal
 			load_resp_s2 =1;			//internal signal
 			hrdata_s2 = data_out_s2;
 		end
 		
 		AFTER_WAIT_STATE_SLAVE_SECOND: begin
 			hready_out_s2=1;	//0
 			hresp_s2 =resp_out_s2;
 			load_data_s2=1;	//internal signal
 			store_data_s2 =0;	//internal signal
 			load_addrs_s2 =1;	//internal signal
 			load_resp_s2 =1;	//internal signal
 			hrdata_s2 = data_out_s2;
 		end
 		
 		LAST_WAIT_STATE_SLAVE_SECOND: begin
 			hready_out_s2=1;	//0
 			hresp_s2 =resp_out_s2;
 			load_data_s2=0;	//internal signal
 			store_data_s2 =0;	//internal signal
 			load_addrs_s2 =0;	//internal signal
 			load_resp_s2 =0;	//internal signal
 			hrdata_s2 =data_out_s2;
 		end
 	endcase
end

always_ff @(posedge hclk_s2) begin
	if(stay_s2 && hready_s2)
	  count_s2 <=count_s2+1;
	else if(!stay_s2)
	  count_s2 <=1;
end

always_ff @(posedge hclk_s2) begin
	if(stay_wait_s2)
	  count_wait_s2 <= count_wait_s2+1;
	else
	  count_wait_s2 <=1;
end

endmodule
