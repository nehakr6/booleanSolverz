module button(Clock, Reset, key, feedback);
	output logic feedback;
	input logic Clock, Reset, key;
	
	enum {on, off} curr_state, next_state;
	
	always_comb begin
		case(curr_state)
			on: 	if(key) next_state = on;
	
					else next_state = off;
				
			off: 	if(key) next_state = on;
						
					else next_state = off;
			
		endcase
		
	end
	
	assign feedback = (curr_state == on & next_state == off);
	
	always_ff @(posedge Clock) begin
		if(Reset) 
			curr_state <= off;
		else
			curr_state <= next_state;
	end
	
endmodule

module button_testbench();
	logic Clock,Reset;
	logic key;
	logic feedback;
	
	userInput dut (.Clock, .Reset, .feedback, .key);
	
	parameter CLOCK_PERIOD = 100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD / 2) 
		Clock <= ~Clock;
	end
	
	initial begin
		Reset <= 1;						@(posedge Clock);
											@(posedge Clock);
		Reset <= 0;						@(posedge Clock);
											@(posedge Clock);
		key <= 1;						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 0;						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 1;						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 0; 						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 1;						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 0; 						@(posedge Clock);
											@(posedge Clock);
											@(posedge Clock);
		key <= 1;						@(posedge Clock);
											@(posedge Clock);
		$stop;
		
	end
	
endmodule 