`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:53:27 04/09/2018 
// Design Name: 
// Module Name:    degital_lock 
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


module ASM (input clk,
    input rst,
    input clr,
    input ent,
    input change,
	output reg [5:0] led,
	output reg [27:0] ssd,
    input [3:0] sw); 


//registers

 reg [15:0] password; 
 reg [15:0] inpassword;
 reg [5:0] current_state;
 reg [5:0] next_state;	

// parameters for States, you will need more states obviously
parameter IDLE = 6'b000000; //idle state 
parameter GETFIRSTDIGIT = 6'b000001; // get_first_input_state // this is not a must, one can use counter instead of having another step, design choice
parameter GETSECONDIGIT = 6'b000010; //get_second input state
parameter GETTHIRDDIGIT = 6'b000011;
parameter GETFOURTHDIGIT = 6'b000100;
// parameters for output, you will need more obviously
parameter C=5'b?????; // you should decide on what should be the value of C, the answer depends on your binary_to_segment file implementation
parameter L=5'b?????; // same for L and for other guys, each of them 5 bit. IN ssd module you will provide 20 bit input, each 5 bit will be converted into 7 bit SSD in binary to segment file.
parameter tire=5'b?????; 
parameter blank=5'b?????;


//Sequential part for state transitions
	always @ (posedge clk or posedge rst)
	begin
		// your code goes here
		if(rst==1)
		current_state<= IDLE;
		else
		current_state<= next_state;
		
	end



	// combinational part - next state definitions
	always @ (*)
	begin
	//DO NOT ASSIGN VALUES TO OUTPUTS DO NOT ASSIGN VALUES TO REGISTERS
	//just determine the next_state, that is all. 
	//password = 0000 -> this should not be there for instance or LED = 1010 this should not be there as well
		
		if(current_state == IDLE)
		begin
			password[15:0] <= 16'b0000000000000000;
			if(ent == 1)
				next_state <= GETFIRSTDIGIT;
			else 
				next_state <= current_state;
		end

		else if ( current_state == GETFIRSTDIGIT )
			 if (ent == 1)
			 	next_state <= GETSECONDIGIT;
			 else
			 	next_state <= current_state;
				
		else if ( current_state == GETSECONDIGIT )
			 if (ent == 1)
			 	next_state <= GETTHIRDDIGIT;
			 else
			 	next_state <= current_state;

		else if ( current_state == GETTHIRDDIGIT )
			 if (ent == 1)
			 	next_state <= GETFOURTHDIGIT;
			 else
			 	next_state <= current_state;

		else
			next_state <= current_state;

	end

	 //Sequential part for control registers, this part is responsible from assigning control registers or stored values
	always @ (posedge clk or posedge rst)
	begin
		if(rst)
		begin
			inpassword[15:0]<=0; // password which is taken coming from user, 
			password[15:0]<=0;
		end

		else
		//in this section, you are supposed to set the values for control registers, stored registers(password for instance)
		//number of trials, counter values etc... 
			if(current_state == IDLE)
			begin
			 	password[15:0] <= 16'b0000000000000000; // Built in reset is 0, when user in IDLE state.
				 // you may need to add extra things here.
			end
		
			else if(current_state == GETFIRSTDIGIT)
			begin
				if(ent==1)
					inpassword[15:12]<=sw[3:0]; // inpassword is the password entered by user, first 4 digin will be equal to current switch values
			end

			else if (current_state == GETSECONDIGIT)
			begin

				if(ent==1)
					inpassword[11:8]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
				
			end
			else if (current_state == GETTHIRDDIGIT)
			begin

				if(ent==1)
					inpassword[7:4]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
				
			end
			else if (current_state == GETFOURTHDIGIT)
			begin

				if(ent==1)
					inpassword[3:0]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
				
			end
	end


	// Sequential part for outputs; this part is responsible from outputs; i.e. SSD and LEDS


	always @(posedge clk)
	begin

		if(current_state == IDLE)
		begin
		ssd <= {C, L, five, d};	//CLSD
		end

		else if(current_state == GETFIRSTDIGIT)
		begin
		ssd <= { 0,sw[3:0], blank, blank, blank};	// you should modify this part slightly to blink it with 1Hz. The 0 is at the beginning is to complete 4bit SW values to 5 bit.
		end

		else if(current_state == GETSECONDIGIT)
		begin
		ssd <= { tire , 0,sw[3:0], blank, blank};	// you should modify this part slightly to blink it with 1Hz. 0 after tire is to complete 4 bit sw to 5 bit. Padding 4 bit sw with 0 in other words.	
		end
		/*
		 You need more else if obviously

		*/
	end


endmodule
