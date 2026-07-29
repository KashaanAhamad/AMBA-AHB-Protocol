`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 17.07.2026 18:20:41
// Design Name: 
// Module Name: Second_master_fsm
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


module Second_master_fsm(
				 hready_m2,
				 hresp_m2, 
				 hreset_m2, 
				 hclk_m2, 
				 hrdata_m2, 
				 hgrant_m2, 
				 haddr_m2, 
				 hwrite_m2, 
				 hsize_m2,
				 hburst_m2, 
				 htrans_m2, 
				 hwdata_m2, 
				 hbusreq_m2
			);

input hready_m2;
input hreset_m2, hclk_m2;
input [1:0]hresp_m2;
input [31:0]hrdata_m2;
input hgrant_m2;

output reg [31:0]haddr_m2, hwdata_m2;
output reg hwrite_m2;
output reg [2:0] hsize_m2, hburst_m2;
output reg [1:0]htrans_m2; 
output reg hbusreq_m2;

parameter IDLE_MAST_SECOND = 4'b0000, 	BUSREQ_MAST_SECOND = 4'b0001, 
NON_SEQ_WRITE_MAST_SECOND = 4'b0010,	WRITE_WAIT_MAST_SECOND = 4'b0011,
SEQ_WRITE_MAST_SECOND = 4'b0100, 		NON_SEQ_READ_MAST_SECOND = 4'b0101, 
READ_WAIT_MAST_SECOND = 4'b0110, 		SEQ_READ_MAST_SECOND =4'b0111,
LAST_WRITE_MAST_SECOND = 4'b1000, 		LAST_READ_MAST_SECOND = 4'b1001;

parameter reg[2:0] burst_out_m2 = 3'b100;
parameter reg[31:0] start_addrs_m2 = 32'h0000_0210, data_m2=32'h01a7_d24c;
parameter reg req_m2 = 1, 	write_m2=0;
reg transfer_start_request_m2=1; 

int count_m2, burst_size_m2;
bit stay_m2;
reg [3:0]next_state_m2, state_m2;

reg [31:0]data_out_m2, addr_out_m2;
reg load_data_m2;

//address generation variables required 
reg load_addr_m2;
reg [31:0] quotient_temp_m2, remainder_temp_m2;
reg [7:0]wrap_byte_variable_m2;
reg [31:0]start_wrap_address_m2, end_wrap_address_m2;

//fsm part of Second master logic starts here
always_comb
begin
 	case(state_m2)
		IDLE_MAST_SECOND: begin
	   	if(!hgrant_m2)
		 begin
		   if(transfer_start_request_m2)
			next_state_m2 = BUSREQ_MAST_SECOND;
		   else
			next_state_m2 = IDLE_MAST_SECOND;
		end
		else if(hready_m2 && hresp_m2==2'b00 && transfer_start_request_m2) 
			next_state_m2 = (write_m2)?NON_SEQ_WRITE_MAST_SECOND:NON_SEQ_READ_MAST_SECOND;	
		else
		 	next_state_m2 = IDLE_MAST_SECOND;
		end

		BUSREQ_MAST_SECOND: begin
		if(hready_m2 && hresp_m2==2'b00)
		 begin
			if(hgrant_m2)
				next_state_m2 = (write_m2)?NON_SEQ_WRITE_MAST_SECOND:NON_SEQ_READ_MAST_SECOND; 
			else 
				next_state_m2 = BUSREQ_MAST_SECOND;
			end
		end
		NON_SEQ_WRITE_MAST_SECOND : begin
			if(hgrant_m2)
			 begin
				if(burst_size_m2 == 1)
					next_state_m2 = WRITE_WAIT_MAST_SECOND;
			else
				next_state_m2 = SEQ_WRITE_MAST_SECOND;
			end
		else
		  next_state_m2 = LAST_WRITE_MAST_SECOND; 
		end
		
		WRITE_WAIT_MAST_SECOND: begin
		 if(hgrant_m2)
		  begin
		  if((hready_m2 == 1'b1) && (hresp_m2 == 2'b00)) 
		  	next_state_m2 = IDLE_MAST_SECOND;
		end
	  end

	SEQ_WRITE_MAST_SECOND: begin 
		if (hgrant_m2) begin
			next_state_m2 = (count_m2==burst_size_m2)?WRITE_WAIT_MAST_SECOND: SEQ_WRITE_MAST_SECOND;
			stay_m2 = (count_m2==burst_size_m2) ?0:1;
		end 
		else
			next_state_m2 = LAST_WRITE_MAST_SECOND;
		end

	NON_SEQ_READ_MAST_SECOND: begin
	  if (hgrant_m2)
		begin
			if (burst_size_m2== 1)
			next_state_m2 = READ_WAIT_MAST_SECOND;
			else 
			next_state_m2= SEQ_READ_MAST_SECOND; 
		end
	else
		next_state_m2 = LAST_READ_MAST_SECOND;//non block to blocking
end

	READ_WAIT_MAST_SECOND: begin
		if (hgrant_m2)
		begin
			if ((hready_m2 == 1'b1) && (hresp_m2 == 2'b00))
			next_state_m2 = IDLE_MAST_SECOND;
	end
end

	SEQ_READ_MAST_SECOND: begin 
	if (hgrant_m2) begin
		stay_m2 = (count_m2==burst_size_m2-1)?0:1;
		next_state_m2 = (count_m2==burst_size_m2-1)?READ_WAIT_MAST_SECOND:SEQ_READ_MAST_SECOND;
	end 
	else
		next_state_m2 = LAST_READ_MAST_SECOND;
end

	LAST_WRITE_MAST_SECOND: begin
	if (hgrant_m2)
		next_state_m2 = NON_SEQ_WRITE_MAST_SECOND;
	else
		next_state_m2 = LAST_WRITE_MAST_SECOND;
	end

	LAST_READ_MAST_SECOND: begin
	if (hgrant_m2)
		next_state_m2 = NON_SEQ_READ_MAST_SECOND;
	else
		next_state_m2 = LAST_READ_MAST_SECOND;
	end
	endcase
end
	


always_ff @(posedge hclk_m2) begin
	if (stay_m2 && hready_m2) 
		count_m2<=count_m2+1;
	else if(!stay_m2) 
		count_m2<=1;
	end

always_ff @(posedge hclk_m2, negedge hreset_m2)
	if(!hreset_m2)
		state_m2 <= IDLE_MAST_SECOND; 
	else
		state_m2 <= next_state_m2;


always_comb
begin
	if(state_m2 == IDLE_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b00;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hbusreq_m2 = 0;
		load_data_m2 = 0;//interbnal signals
		load_addr_m2 = 0;//internal signals
end
	else if(state_m2== BUSREQ_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b00;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 0; //internal signal
		load_addr_m2 = 0; //internal signal
end

//else if (state_m2== NON_SEQ_WRITE_MAST_SECOND)
//	begin
//		haddr_m2 = addr_out_m2;
//		htrans_m2 = 2'b10;
//		hwrite_m2 = write_m2;
//		hsize_m2 = 3'b010;
//		hburst_m2 = burst_out_m2;
//		hbusreq_m2 = req_m2;
//		load_data_m2 = 0;//internal signal
//		load_addr_m2 = 1;//internal signal 
//	end
//else if(state_m2 == WRITE_WAIT_MAST_SECOND)//Missing
//begin
//haddr_m2 = addr_out_m2;
//htrans_m2 = 2'b10;
//hwrite_m2 = write_m2;
//hsize_m2 = 3'b010:

//.....


else if (state_m2== NON_SEQ_WRITE_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b10;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 0;//internal signal
		load_addr_m2 = 1;//internal signal
	end

else if(state_m2 == WRITE_WAIT_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b10;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		// hwdata_m2 = data_out_m2;
		hwdata_m2 = hwdata_m2;
		
		hbusreq_m2 = req_m2;
		load_data_m2 = 0;//internal signal
		load_addr_m2 = 0; //internal signal
		transfer_start_request_m2 = 0;
	end

else if(state_m2 == SEQ_WRITE_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b11;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hwdata_m2 = data_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 1;//internal signal
		load_addr_m2 = 1; //internal signal
	end

else if(state_m2 == NON_SEQ_READ_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b10;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hwdata_m2 = data_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 0;//internal signal 
		load_addr_m2 = 1;//internal signal
	end

else if(state_m2 == READ_WAIT_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b10;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hwdata_m2 = data_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 0;//internal signal
		load_addr_m2 = 0;//internal signal
		transfer_start_request_m2 = 0;
	end

else if(state_m2 == SEQ_READ_MAST_SECOND)
	begin
		haddr_m2 = addr_out_m2;
		htrans_m2 = 2'b11;
		hwrite_m2 = write_m2;
		hsize_m2 = 3'b010;
		hburst_m2 = burst_out_m2;
		hwdata_m2 = data_out_m2;
		hbusreq_m2 = req_m2;
		load_data_m2 = 0;//internal signal 
		load_addr_m2 = 1;//internal signal
	end
end
endmodule

