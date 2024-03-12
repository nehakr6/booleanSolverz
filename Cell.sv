module Cell (Clock, Reset, Pause, border, in, out);
	input Clock, Reset, Pause, in;
	input logic [0:7] border;
	output logic out;
	
	enum logic {off = 1'b0, on = 1'b1} curr_state, next_state; //on = cell is alive, off = cell is dead
	logic [0:4] counter;
	
	logic [0:7] slow;
	
	//counts how many surrounding cells are on
	assign counter = border[0] + border[1] + border[2] + border[3] + border[4] + border[5] + border[6] + border[7];
	
	//sets the value of the current cell based on counter
	always_comb begin		
		case (curr_state)
			on:	if (counter == 2 | counter == 3) next_state = on;
					else										next_state = off;
			off:	if (counter == 3)						next_state = on;
					else										next_state = off;
		endcase
	end
	
	//light being on is always equal to the current state
	assign out = curr_state;
	
	//update the state using the clock
	always_ff @(posedge Clock) begin
		if (Reset) begin
			curr_state <= off;
		end else if (Pause) begin
			if (in == 1) curr_state <= on;
			else if (in == 0) curr_state <= off;
		end else begin
			if (slow == 0) curr_state <= next_state;
		end
		slow = slow + 1;
	end
endmodule
