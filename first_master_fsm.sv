`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.07.2026 16:19:21
// Design Name: 
// Module Name: first_master_fsm
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


module First_master_fsm(hready_m1,
				 hresp_m1, 
				 hreset_m1, 
				 hclk_m1, 
				 hrdata_m1, 
				 hgrant_m1, 
				 haddr_m1, 
				 hwrite_m1, 
				 hsize_m1,
				 hburst_m1, 
				 htrans_m1, 
				 hwdata_m1, 
				 hbusreq_m1
			);

input hready_m1;
input hreset_m1, hclk_m1;
input [1:0]hresp_m1;
input [31:0]hrdata_m1;
input hgrant_m1;

output reg [31:0]haddr_m1, hwdata_m1;
output reg hwrite_m1;
output reg [2:0] hsize_m1, hburst_m1;
output reg [1:0]htrans_m1; output reg hbusreq_m1;

parameter IDLE_MAST_FIRST = 4'b0000, 	BUSREQ_MAST_FIRST = 4'b0001, 
NON_SEQ_WRITE_MAST_FIRST = 4'b0010,		WRITE_WAIT_MAST_FIRST = 4'b0011,
SEQ_WRITE_MAST_FIRST = 4'b0100, 		NON_SEQ_READ_MAST_FIRST = 4'b0101, 
READ_WAIT_MAST_FIRST = 4'b0110, 		SEQ_READ_MAST_FIRST =4'b0111,
LAST_WRITE_MAST_FIRST = 4'b1000, 		LAST_READ_MAST_FIRST = 4'b1001;

parameter reg[2:0] burst_out_m1 = 3'b100;
parameter reg[31:0] start_addrs_m1 = 32'h0000_0600, data_m1=32'h01a7_d24c;
parameter reg req_m1 = 1, 	write_m1=0;
reg transfer_start_request_m1=1; 

int count_m1, burst_size_m1;
bit stay_m1;
reg [3:0]next_state_m1, state_m1;

reg [31:0]data_out_m1, addr_out_m1;
reg load_data_m1;

//address generation variables required 
reg load_addr_m1;
reg [31:0] quotient_temp_m1, remainder_temp_m1;
reg [7:0]wrap_byte_variable_m1;
reg [31:0]start_wrap_address_m1, end_wrap_address_m1;

//fsm part of first master logic starts here
always_comb
begin
 	case(state_m1)
		IDLE_MAST_FIRST: begin
	   	if(!hgrant_m1)
		 begin
		   if(transfer_start_request_m1)
			next_state_m1 = BUSREQ_MAST_FIRST;
		   else
			next_state_m1 = IDLE_MAST_FIRST;
		end
		else if(hready_m1 && hresp_m1==2'b00 && transfer_start_request_m1) 
			next_state_m1 = (write_m1)?NON_SEQ_WRITE_MAST_FIRST:NON_SEQ_READ_MAST_FIRST;	
		else
		 	next_state_m1 = IDLE_MAST_FIRST;
		end

		BUSREQ_MAST_FIRST: begin
		if(hready_m1 && hresp_m1==2'b00)
		 begin
			if(hgrant_m1)
				next_state_m1 = (write_m1)?NON_SEQ_WRITE_MAST_FIRST:NON_SEQ_READ_MAST_FIRST; 
			else 
				next_state_m1 = BUSREQ_MAST_FIRST;
			end
		end
		NON_SEQ_WRITE_MAST_FIRST : begin
			if(hgrant_m1)
			 begin
				if(burst_size_m1 == 1)
					next_state_m1 = WRITE_WAIT_MAST_FIRST;
			else
				next_state_m1 = SEQ_WRITE_MAST_FIRST;
			end
		else
		  next_state_m1 = LAST_WRITE_MAST_FIRST; 
		end
		
		WRITE_WAIT_MAST_FIRST: begin
		 if(hgrant_m1)
		  begin
		  if((hready_m1 == 1'b1) && (hresp_m1 == 2'b00)) 
		  	next_state_m1 = IDLE_MAST_FIRST;
		end
	  end

	SEQ_WRITE_MAST_FIRST: begin 
		if (hgrant_m1) begin
			next_state_m1 = (count_m1==burst_size_m1)?WRITE_WAIT_MAST_FIRST: SEQ_WRITE_MAST_FIRST;
			stay_m1 = (count_m1==burst_size_m1) ?0:1;
		end 
		else
			next_state_m1 = LAST_WRITE_MAST_FIRST;
		end

	NON_SEQ_READ_MAST_FIRST: begin
	  if (hgrant_m1)
		begin
			if (burst_size_m1== 1)
			next_state_m1 = READ_WAIT_MAST_FIRST;
			else 
			next_state_m1= SEQ_READ_MAST_FIRST; 
		end
	else
		next_state_m1 = LAST_READ_MAST_FIRST;//non block to blocking
end

	READ_WAIT_MAST_FIRST: begin
		if (hgrant_m1)
		begin
			if ((hready_m1 == 1'b1) && (hresp_m1 == 2'b00))
			next_state_m1 = IDLE_MAST_FIRST;
	end
end

	SEQ_READ_MAST_FIRST: begin 
	if (hgrant_m1) begin
		stay_m1 = (count_m1==burst_size_m1-1)?0:1;
		next_state_m1 = (count_m1==burst_size_m1-1)?READ_WAIT_MAST_FIRST:SEQ_READ_MAST_FIRST;
	end 
	else
		next_state_m1 = LAST_READ_MAST_FIRST;
end

	LAST_WRITE_MAST_FIRST: begin
	if (hgrant_m1)
		next_state_m1 = NON_SEQ_WRITE_MAST_FIRST;
	else
		next_state_m1 = LAST_WRITE_MAST_FIRST;
	end

	LAST_READ_MAST_FIRST: begin
	if (hgrant_m1)
		next_state_m1 = NON_SEQ_READ_MAST_FIRST;
	else
		next_state_m1 = LAST_READ_MAST_FIRST;
	end
	endcase
end
	


always_ff @(posedge hclk_m1) begin
	if (stay_m1 && hready_m1) 
		count_m1<=count_m1+1;
	else if(!stay_m1) 
		count_m1<=1;
	end

always_ff @(posedge hclk_m1, negedge hreset_m1)
	if(!hreset_m1)
		state_m1 <= IDLE_MAST_FIRST; 
	else
		state_m1 <= next_state_m1;


always_comb
begin
	if(state_m1 == IDLE_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b00;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hbusreq_m1 = 0;
		load_data_m1 = 0;//interbnal signals
		load_addr_m1 = 0;//internal signals
end
	else if(state_m1== BUSREQ_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b00;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 0; //internal signal
		load_addr_m1 = 0; //internal signal
end

//else if (state_m1== NON_SEQ_WRITE_MAST_FIRST)
//	begin
//		haddr_m1 = addr_out_m1;
//		htrans_m1 = 2'b10;
//		hwrite_m1 = write_m1;
//		hsize_m1 = 3'b010;
//		hburst_m1 = burst_out_m1;
//		hbusreq_m1 = req_m1;
//		load_data_m1 = 0;//internal signal
//		load_addr_m1 = 1;//internal signal 
//	end
//else if(state_m1 == WRITE_WAIT_MAST_FIRST)//Missing
//begin
//haddr_m1 = addr_out_m1;
//htrans_m1 = 2'b10;
//hwrite_m1 = write_m1;
//hsize_m1 = 3'b010:

//.....


else if (state_m1== NON_SEQ_WRITE_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b10;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 0;//internal signal
		load_addr_m1 = 1;//internal signal
	end

else if(state_m1 == WRITE_WAIT_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b10;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		// hwdata_m1 = data_out_m1;
		hwdata_m1 = hwdata_m1;
		
		hbusreq_m1 = req_m1;
		load_data_m1 = 0;//internal signal
		load_addr_m1 = 0; //internal signal
		transfer_start_request_m1 = 0;
	end

else if(state_m1 == SEQ_WRITE_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b11;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hwdata_m1 = data_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 1;//internal signal
		load_addr_m1 = 1; //internal signal
	end

else if(state_m1 == NON_SEQ_READ_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b10;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hwdata_m1 = data_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 0;//internal signal 
		load_addr_m1 = 1;//internal signal
	end

else if(state_m1 == READ_WAIT_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b10;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hwdata_m1 = data_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 0;//internal signal
		load_addr_m1 = 0;//internal signal
		transfer_start_request_m1 = 0;
	end

else if(state_m1 == SEQ_READ_MAST_FIRST)
	begin
		haddr_m1 = addr_out_m1;
		htrans_m1 = 2'b11;
		hwrite_m1 = write_m1;
		hsize_m1 = 3'b010;
		hburst_m1 = burst_out_m1;
		hwdata_m1 = data_out_m1;
		hbusreq_m1 = req_m1;
		load_data_m1 = 0;//internal signal 
		load_addr_m1 = 1;//internal signal
	end
end
endmodule
