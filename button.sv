module button(Clock, Reset, key, feedback);
	output logic feedback;
	input logic Clock, Reset, key;
	
	enum {off, on} curr_state, next_state;
	
	//set the next state based off of whether the key is pressed
	always_comb begin
		case(key)
			0:	next_state <= on;
			1: next_state <= off;
		endcase
	end
	
	//set the output to positive edges of button presses
	assign feedback = (curr_state == off & next_state == on);
	
	//set state in sync with the clock
	always_ff @(posedge Clock) begin
		if(Reset) 
			curr_state <= off;
		else
			curr_state <= next_state;
	end
	
endmodule