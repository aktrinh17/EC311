`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    binary_to_segment 
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
module binary_to_segment(
    input [3:0] binary_in,
    output reg [6:0] seven_out
    );

always @(binary_in)
begin
	case(binary_in)								//1 means off and 0 means on
		4'd0: seven_out =7'b1111111;			// OFF status, for 2 middle 7-segments
		4'd1: seven_out =7'b1001111;			//display 1
		4'd2: seven_out =7'b0010010;			//2
		4'd3: seven_out =7'b0000110;			//3
		4'd4: seven_out =7'b1001100;
		4'd5: seven_out =7'b0100100;
    	4'd6: seven_out =7'b0100000;
		4'd7: seven_out =7'b0001111;
		4'd8: seven_out =7'b0000000;
		4'd9: seven_out =7'b0000100;
		4'd10: seven_out= 7'b1111110;			//stable
		4'd11: seven_out= 7'b1000001;			//up
		4'd12: seven_out= 7'b0001001;			//down
		
		default: seven_out = 7'h1;
	endcase
end


endmodule
