`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.07.2026 11:41:33
// Design Name: 
// Module Name: default_master_fsm
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


module default_master_fsm(
		def_hready, 
		def_hresp, 
		def_hreset, 
		def_hclk, 
		def_hrdata, 
		def_hgrant, 
		def_haddr, 
		def_hwrite, 
		def_hsize,
		def_hburst, 
		def_htrans, 
		def_hwdata, 
		def_hbusreq
	);

input def_hready;
input def_hreset, def_hclk;
input [1:0]def_hresp;
input [31:0]def_hrdata;
input def_hgrant;

output reg [31:0] def_haddr, def_hwdata;
output reg def_hwrite;
output reg [2:0] def_hsize, def_hburst;
output reg [1:0] def_htrans;
output reg def_hbusreq;

parameter IDLE_DEFAULT_MAST = 2'b00, TRANSFER_DEFAULT_MAST = 2'b01;

reg [1:0]def_next_state, def_state;

always_comb
begin
unique case(def_state)

	IDLE_DEFAULT_MAST: begin	
	if(def_hgrant)
		def_next_state = TRANSFER_DEFAULT_MAST;
	else
		def_next_state = IDLE_DEFAULT_MAST;
end
	TRANSFER_DEFAULT_MAST:begin
	if(!def_hgrant)
		def_next_state =IDLE_DEFAULT_MAST;
	else
		def_next_state =TRANSFER_DEFAULT_MAST;
end

	default:def_next_state = IDLE_DEFAULT_MAST;
endcase
end

always_ff @(posedge def_hclk, negedge def_hreset)
begin
	if(!def_hreset)
		def_state <= IDLE_DEFAULT_MAST;
	else
		def_state <= def_next_state;
	end
	
always_comb
begin
	if(def_state == IDLE_DEFAULT_MAST)
	begin
		def_haddr = 32'b0;
		def_htrans = 2'b00;
		def_hwrite = 1'b0;
		def_hsize = 3'b010;
		def_hburst = 3'b000;
		def_hwdata = 32'b0;
		def_hbusreq = 1'b1;
	end
	else if(def_state == TRANSFER_DEFAULT_MAST)
	begin
		def_haddr = 32'b0;
		def_htrans = 2'b00;
		def_hwrite = 1'b0;
		def_hsize = 3'b010;
		def_hburst = 3'b000;
		def_hwdata = 32'b0;
		def_hbusreq = 1'b0;
	end
	else
	begin
		def_haddr = 32'b0;
		def_htrans = 2'b00;
		def_hwrite = 1'b0;
		def_hsize = 3'b010;
		def_hburst = 3'b000;
		def_hwdata = 32'b0;
		def_hbusreq = 1'b1;
	end
   end
endmodule
