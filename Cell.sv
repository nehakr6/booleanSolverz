
module Cell (Clock, Reset, Pause, border, out)
	input Clock, Reset, Pause;
	input logic [0:7] border;
	output logic out;
	
	enum {on, off} curr_state, next_state; //on = cell is alive, off = cell is dead
	logic [0:4] counter;
	
	//counts how many surrounding cells are on
	assign counter = border[0] + border[1] + border[2] + border[3] + border[4] + border[5] + border[6] + border[7];
	
	
	always_comb begin		
		case (curr_state)
			on:	if (counter == 2 | counter == 3) next_state = on;
					else										next_state = off;
			off:	if (counter == 3)						next_state = on;
					else										next_state = off;
		endcase
		
	end
		
	assign out = next_state;
	
	always_ff @(posedge Clock) begin
		if (Reset)
			curr_state <= off;
		else if (!Pause)
			curr_state <= next_state;
		