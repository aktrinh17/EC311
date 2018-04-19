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
	 output reg [3:0] AN,
	 output reg [6:0] seven_out
    );
	reg [4:0] seven_in;
	reg [1:0] count;
	wire rst; // this is here temporarily: will find out if it's needed
	initial begin // Initial block , used for correct simulations
		AN = 4'b1110;
		seven_in = 0;
		count = 0;
	end
	
	//translates to 7 LED values
	wire [6:0] seven_out0;
	binary_to_segment disp0(big_bin[4:0],seven_out0);
	wire [6:0] seven_out1;
	binary_to_segment disp1(big_bin[9:5],seven_out1);
	wire [6:0] seven_out2;
	binary_to_segment disp2(big_bin[14:10],seven_out2);
	wire [6:0] seven_out3;
	binary_to_segment disp3(big_bin[19:15],seven_out3);

clk_divider slowerClk(clk, rst, divided_clk); //slows down the clock
//Always block is missing...
// Also count value is operating in very  high frequency? Think about how to fix it!
	always @(posedge divided_clk) begin
	count <= count + 1;
	case (count)
	 0: begin 
		AN <= 4'b1110;
		seven_out <= seven_out0;
	 end
	 
	 1: begin 
		AN <= 4'b1101;
		seven_out <= seven_out1;	
	end
	2: begin 
		AN <= 4'b1011;
		seven_out <= seven_out2;			
	end
	3: begin 
		AN <= 4'b0111;
		seven_out <= seven_out3;
	end
	endcase

end

endmodule
