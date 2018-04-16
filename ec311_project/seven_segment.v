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
	 input [19:0] big_bin,
	 reg [4:0] seven_in,
	 output reg [3:0] AN,
	 output [6:0] seven_out
    );
	wire rst; // this is here temporarily: will find out if it's needed
	initial begin // Initial block , used for correct simulations
		AN = 4'b1110;
		seven_in = 0;
		count = 0;
	end
	

binary_to_segment disp0(seven_in,seven_out);		//tranlate to 7 LED values
clk_divider slowerClk(clk, rst, divided_clk); //slows down the clock
//Always block is missing...
// Also count value is operating in very  high frequency? Think about how to fix it!
	always @(posedge divided_clk) begin
	count <= count + 1;
	case (count)
	 0: begin 
		AN <= 4'b1110;
		
	 end
	 
	 1: begin 
		AN <= 4'b1101;
			
	end
	2: begin 
		AN <= 4'b1011;
					
	end
	3: begin 
		AN <= 4'b0111;
		
	end
	endcase

end

endmodule
