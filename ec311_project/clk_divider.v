`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    clk_divider 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: Generates a clock with period 50 ms, from 25 MHz input clock, T=0.00004 ms
//						A counter counts till 625.000 = 010011000100101101000
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_divider(
	input clk_in,
	input rst,
	output reg divided_clk
    );
	 
	 

parameter toggle_value = 16'b1001110001000000; //40,000 in binary for 1kHz
	 
reg[15:0] cnt;

always@(posedge clk_in or posedge rst)
begin
	if (rst==1) begin
		cnt <= 0;
		divided_clk <= 0;
	end
	else begin
		if (cnt==toggle_value) begin
			cnt <= 0;
			divided_clk <= ~divided_clk;
		end
		else begin
			cnt <= cnt +1;
			divided_clk <= divided_clk;		
		end
	end

end
			  
	


endmodule
