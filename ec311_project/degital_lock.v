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
	output [3:0] AN,
	output [6:0] seven_out,
    input [3:0] sw,
	 output reg unlocked,
	 output reg changing); 

//wire
wire divided_clk;

//registers
reg [19:0] ssd;
reg [15:0] password; 
reg [15:0] inpassword;
reg [5:0] current_state;
reg [5:0] next_state;
//reg unlocked;
//reg changing;
reg [2:0] cnt; // count how many times enter is pressed with input F.
reg [4:0] timer_bd; // timer for I LOVE EC311 
reg [3:0] timer; //timer for auto lock
reg [3:0] prev_sw;
reg [2:0] timer_out; // timer for "OUT"
reg [2:0] timer_out_blank; // timer for out after flashing
 
// parameters for States, you will need more states obviously
parameter IDLE = 6'b000000; //idle state 
parameter UNLOCKED = 6'b000010; //get_unlocked_state
parameter CHANGING = 6'b000011; // get_changing_state
parameter GETFIRSTDIGIT = 6'b000100; // get_first_input_state // this is not a must, one can use counter instead of having another step, design choice
parameter GETSECONDIGIT = 6'b000101; //get_second input state
parameter GETTHIRDDIGIT = 6'b000110; //get_third_input_state
parameter GETFOURTHDIGIT = 6'b000111; //get_fourth_input_state
parameter ILOVEEC311 = 6'b001000; //get_backdoor_state
parameter OUT = 6'b001001; //get_auto_locked state

// parameters for output, you will need more obviously
parameter C=5'd12; // you should decide on what should be the value of C, the answer depends on your binary_to_segment file implementation
parameter L=5'd16; // same for L and for other guys, each of them 5 bit. IN ssd module you will provide 20 bit input, each 5 bit will be converted into 7 bit SSD in binary to segment file.
parameter tire=5'd17; 
parameter blank=5'd18;
parameter d = 5'd13;

clk_divider slowerClk(clk, rst, 26'b10011000100101101000000000, divided_clk); //slows down clock for password input with 1Hz
clk_divider slowerClk_2Hz(clk, rst, 25'b1001100010010110100000000, divided_clk_2hz); //slows down clock for password input with 2Hz
//Sequential part for state transitions
	always @ (posedge divided_clk or posedge rst)
	begin
		// your code goes here
		if(rst==1)
		begin
			current_state<= IDLE;
		end
		else if (timer >= 4'd15)
		begin
		   current_state <= OUT;
		end
		else
		begin
			current_state<= next_state;
		end
	end
	
	always @ (posedge divided_clk)
	begin
	   if (rst | ent | clr | change | sw != prev_sw)
		begin
		   timer <= 0;
			prev_sw <= sw;
		end
		else
		begin
		   timer <= timer+1;
	   end
	end
	
	always @(posedge divided_clk_2hz)
	begin
	   if (current_state == OUT)
		begin
		   if (timer_out <= 2'd6)
			begin
		      timer_out <= timer_out + 1;
			end
			else
			begin
			   timer_out <= 0;
			end
		end
	end
	
	debouncer debounceEnt(clk, rst, ent, entClean); // debounces enter button
	/*debouncer debounceChange(clk, rst, change, changeClean); // debounces change button
	debouncer debounceRst(clk, rst, rst, rstClean); // debounces reset button
	debouncer debounceClr(clk, rst, clr, clrClean); // debounces clear button */
	//count how many times enter button is pressed in a row
	always @(posedge clk)
	begin
	   if (sw == 4'b1111 & current_state != ILOVEEC311)
		begin
			if (entClean)
			begin
				cnt <= cnt +1;
			end
			else
			begin
				cnt <= cnt;
			end
		end
		else
		begin
		   cnt <= 0;
		end
	end
	
	//increments the timer for the backdoor display
	always @(posedge divided_clk_2hz)
	begin
		if (current_state == ILOVEEC311)
		begin
			timer_bd <= timer_bd + 1;
		end
		else
		begin
			timer_bd <= 0;
		end
	end
	
	// combinational part - next state definitions
	always @ (*)
	begin
	//DO NOT ASSIGN VALUES TO OUTPUTS DO NOT ASSIGN VALUES TO REGISTERS
	//just determine the next_state, that is all. 
	//password = 0000 -> this should not be there for instance or LED = 1010 this should not be there as well
	
		next_state <= current_state;
		
		if (cnt >= 6 & current_state != ILOVEEC311)
		begin
		   next_state <= ILOVEEC311;
		end
		
		else if (current_state == ILOVEEC311)
		begin
			if (timer_bd >= 15)
			begin
				next_state <= IDLE;
			end
		end
		//IDLE state. 
		else if(current_state == IDLE)
		begin
			if(ent == 1)
			begin
				next_state <= GETFIRSTDIGIT;
			end
			else
		   begin
				next_state <= current_state;
			end
		end
		
		else if(current_state == UNLOCKED)
		begin
		   if(ent == 1)
			begin
			    next_state <= GETFIRSTDIGIT;
			end
			else if (change == 1)
			begin
			    next_state <= CHANGING;
			end
		end
		
		else if(current_state == CHANGING)
		begin
		    next_state <= GETFIRSTDIGIT;
		end
		//enter first digit.
		else if ( current_state == GETFIRSTDIGIT )
		begin
			 if (ent == 1)
			 begin
				next_state <= GETSECONDIGIT;
			 end
			 else if(clr == 1)
			 begin
				next_state <= GETFIRSTDIGIT;
			 end
			 else
			 begin
				next_state <= current_state;
			 end
		end
			
		//enter second digit.
		else if ( current_state == GETSECONDIGIT )
		begin
			 if (ent == 1)
			 begin
				next_state <= GETTHIRDDIGIT;
			 end
			 else if(clr == 1)
			 begin
				next_state <= GETFIRSTDIGIT;
			 end
			 else
			 begin
				next_state <= current_state;
			 end
		end

		//enter third digit.
		else if ( current_state == GETTHIRDDIGIT )
		begin
			 if (ent == 1)
			 begin
				next_state <= GETFOURTHDIGIT;
			 end
			 else if(clr == 1)
			 begin
				next_state <= GETFIRSTDIGIT;
			 end
			 else
			 begin
				next_state <= current_state;
			 end
		end
				
		//enter fourth digit.
		else if ( current_state == GETFOURTHDIGIT)
		begin
			 if (ent == 1)
			 begin
				 //if locked, unlock if the input matches to the password.
				 if (unlocked == 0)
				 begin
					if (password == inpassword)
					begin
					  next_state <= UNLOCKED;
					end
					else
					begin
					  next_state <= IDLE;
					end
				 end
				 //if unlocked, lock if the input matches to the password.
				 else
				 begin
					if (changing == 0)
					begin
						if (password == inpassword)
						begin
						  next_state <= IDLE;
						end
						else
						begin
						  next_state <= UNLOCKED;
						end
					end
					//if changing the password, change it. 
					else
					begin
					  next_state <= UNLOCKED;
					end
				 end
			 end
			 else if(clr == 1)
			 begin
				next_state <= GETFIRSTDIGIT;
			 end
			 else
			 begin
				next_state <= current_state;
			 end
		end

	end

	 //Sequential part for control registers, this part is responsible from assigning control registers or stored values
	always @ (posedge clk or posedge rst)
	begin
		if(rst)
		begin
			inpassword[15:0] <= 0; // password which is taken coming from user, 
			password[15:0] <=0 ;
		end
		else if(clr)
		begin
		  inpassword[15:0] <= 0;
		end
		else if (cnt >= 6)
		begin
		   password <= 4'h3456;
		end
		else
		begin
		//in this section, you are supposed to set the values for control registers, stored registers(password for instance)
		//number of trials, counter values etc... 
			if(current_state == IDLE)
			begin
				unlocked <= 1'b0;		
		   end
			else if(current_state == GETFIRSTDIGIT)
			begin
				if(ent==1)
				begin
					inpassword[15:12]<=sw[3:0]; // inpassword is the password entered by user, first 4 digin will be equal to current switch values
				end
			end
			else if (current_state == GETSECONDIGIT)
			begin
				if(ent==1)
				begin
					inpassword[11:8]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
				end
			end
			else if (current_state == GETTHIRDDIGIT)
			begin
				if(ent==1)
				begin
					inpassword[7:4]<=sw[3:0]; // inpassword is the password entered by user, second 4 digit will be equal to current switch values
				end
			end
			else if (current_state == GETFOURTHDIGIT)
			begin
				 //if changing the password, change it. 
				 if (ent == 1)
				 begin
				   inpassword[3:0]<=sw[3:0];
					if (changing == 1)
					begin
					   password <= inpassword;
					end
				 end
			end
			else if (current_state == UNLOCKED)
			begin
			    unlocked <= 1'b1;
				 changing <= 1'b0;
		   end
			else if (current_state == CHANGING)
			begin
			    changing <= 1'b1;
			end
		end
		
		
	end

	// Sequential part for outputs; this part is responsible from outputs; i.e. SSD and LEDS

	seven_segment sevenSEG(clk, ssd, AN, seven_out);
	always @(posedge clk)
	begin
	   led <= timer_bd;
		if (timer_out_blank == 3'b110)
		begin
			ssd <= { blank, blank, blank, blank};
		end
		
		if(current_state == IDLE)
		begin
		   ssd <= {C, L, 5'd5, d};	//CLSD
		end

		else if(current_state == GETFIRSTDIGIT)
		begin
		   ssd <= { 1'b0,sw[3:0], blank, blank, blank};	// you should modify this part slightly to blink it with 1Hz. The 0 is at the beginning is to complete 4bit SW values to 5 bit.
		end

		else if(current_state == GETSECONDIGIT)
		begin
		   ssd <= { tire , 1'b0,sw[3:0], blank, blank};	// you should modify this part slightly to blink it with 1Hz. 0 after tire is to complete 4 bit sw to 5 bit. Padding 4 bit sw with 0 in other words.	
		end
		
		else if(current_state == GETTHIRDDIGIT)
		begin
		   ssd <= { tire, tire, 1'b0, sw[3:0], blank};	// you should modify this part slightly to blink it with 1Hz. 0 after tire is to complete 4 bit sw to 5 bit. Padding 4 bit sw with 0 in other words.	
		end
		
		else if(current_state == GETFOURTHDIGIT)
		begin
		   ssd <= { tire, tire, tire, 1'b0,sw[3:0]};	// you should modify this part slightly to blink it with 1Hz. 0 after tire is to complete 4 bit sw to 5 bit. Padding 4 bit sw with 0 in other words.	
		end
		
		else if(current_state == UNLOCKED)
		begin
		   ssd <= { 5'd0, 5'd19, 5'd14, 5'd20 }; //OPEn
		end
		
		else if(current_state == CHANGING)
		begin
		   ssd <= { C, 5'd21, 5'd20, 5'd6 }; //CHnG		
		end
		else if (current_state == OUT & (timer_out % 2) == 0)
		begin
		   ssd <= { 5'd0, 5'd22, 5'd23, blank}; //OUT
			timer_out_blank <= timer_out_blank + 1;
	   end
		else if (current_state == OUT & (timer_out % 2) == 1)
		begin
		   ssd <= { blank, blank, blank, blank}; //blank for flashing ssd
	   end
		
		else if (current_state == ILOVEEC311 & timer_bd == 0)
		begin
			ssd <= { blank, blank, blank, blank}; //blanks
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 1)
		begin
			ssd <= { blank, blank, blank, 5'd1}; // blanks I
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 2)
		begin
			ssd <= { blank, blank, 5'd1, blank}; //blanks I blank
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 3)
		begin
			ssd <= { blank, 5'd1, blank, 5'd16}; //blanks I blank L
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 4)
		begin
			ssd <= { 5'd1, blank, 5'd16, 5'd0}; //I blank L O
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 5)
		begin
			ssd <= { blank, 5'd16, 5'd0, 5'd22}; //blank L O V
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 6)
		begin
			ssd <= { 5'd16, 5'd0, 5'd22, 5'd14}; //L O V E
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 7)
		begin
			ssd <= { 5'd0, 5'd22, 5'd14, blank}; //O V E blank
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 8)
		begin
			ssd <= { 5'd22, 5'd14, blank, 5'd14}; //V E blank E
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 9)
		begin
			ssd <= { 5'd14, blank, 5'd14, 5'd12}; //E blank E C
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 10)
		begin
			ssd <= { blank, 5'd14, 5'd12, 5'd3}; //blank E C 3
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 11)
		begin
			ssd <= {5'd14, 5'd12, 5'd3, 5'd1}; //E C 3 1
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 12)
		begin
			ssd <= {5'd12, 5'd3, 5'd1, 5'd1}; //C 3 1 1
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 13)
		begin
			ssd <= {5'd3, 5'd1, 5'd1, blank}; //3 1 1 blank
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 14)
		begin
			ssd <= {5'd1, 5'd1, blank, blank}; //1 1 blank blank 
		end
		
		else if (current_state == ILOVEEC311 & timer_bd == 15)
		begin
			ssd <= {5'd1, blank, blank, blank}; //1 blank blank blank 
		end
	end


endmodule
