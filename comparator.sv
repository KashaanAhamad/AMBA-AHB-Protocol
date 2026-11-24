`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.08.2026 14:45:21
// Design Name: 
// Module Name: comparator
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


module comparator(
	req1,req2,req3,req4,clock,reset,grantt1,grantt2,grantt3,grantt4
    );
    input clock,reset;
    input req1,req2,req3,req4;
    output reg grantt1,grantt2,grantt3,grantt4;
    
    wire [5:0]sum[1:4];
    wire [3:0]tkt[1:4];
    wire [4:0]rand_no;
    
    ticket_generator tg1(
    					.clock(clock),
    					.reset(reset),
    					.t1(tkt[1]),
    					.t1(tkt[2]),
    					.t3(tkt[3]),
    					.t4(tkt[4])
    				);
    				
    lottery_manager lm1(
    					.r4(req4),
    					.r1(req1),
    					.r2(req2),
    					.r3(req3),
    					.s4(sum[4]),
    					.s1(sum[1]),
    					.s2(sum[2]),
    					.s3(sum[3]),
    					.clock(clock),
    					.reset(reset),
    					.t1(tkt[1]),
    					.t2(tkt[2]),
    					.t3(tkt[3]),
    					.t4(tkt[4])
    			);
    	
    lfsr_general_stage #(5'b00001) lf_final(
    					.rand_out(rand_no),
    					.clock(clock),
    					.reset(reset)
    				);


 always_comb begin
  if(req1 && rand_no >=0 && rand_no <sum[1]) begin
  	grantt1 =1;
  	grantt2 =0;
  	grantt3 =0;
  	grantt4 =0;
  end
  else if (req2 && rand_no >=sum[1] && rand_no< sum[2]) begin
  	grantt1 =0;
  	grantt2 =1;
  	grantt3 =0;
  	grantt4 =0;
  end
  else if (req3 && rand_no >=sum[2] && rand_no< sum[3]) begin
  	grantt1 =0;
  	grantt2 =0;
  	grantt3 =1;
  	grantt4 =0;
  end
  else if (req4 && rand_no >=sum[3] && rand_no< sum[4]) begin
  	grantt1 =0;
  	grantt2 =0;
  	grantt3 =0;
  	grantt4 =1;
  end
  else begin
  	grantt1 =0;
  	grantt2 =0;
  	grantt3 =0;
  	grantt4 =0;
  end
 end
endmodule
