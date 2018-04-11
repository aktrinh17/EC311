`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:11:06 04/07/2016 
// Design Name: 
// Module Name:    seven_segment 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module seven_segment(
    input clk,
	 input [1:0] status,
	 input [3:0] switch_test,
	 output reg [3:0] AN,
	 output [6:0] seven_out
    );

initial AN = 4'b1110;
reg [1:0] count = 0;
reg [3:0] seven_in;

binary_to_segment disp0(seven_in,seven_out);		//tranlate to 7 LED values

always @(posedge clk) begin
	count <= count + 1;
	case (count)
	 0: begin 
		AN <= 4'b1110;
		seven_in <= switch_test;	//dislpay floor number
	 end
	 
	 1: begin 
		AN <= 4'b1101;
		seven_in <= 0;					//coresponds to OFF status
	end
	2: begin 
		AN <= 4'b1011;
		seven_in <= 0;					//OFF
	end
	3: begin 
		AN <= 4'b0111;
		seven_in <= status+10;		//UP, DOWN, or STABLE
	end
	endcase

end

endmodule
