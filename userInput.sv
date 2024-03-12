module userInput(Clock, Reset, Pause, Set, thisRow, up, down, lights, debug);
	input  Clock, Reset, Pause, Set, up, down;
	input  [7:0] thisRow;
	output [7:0] [7:0] lights;
	output [2:0]		 debug;
	
	enum logic [2:0] {a = 3'b000, b = 3'b001, c = 3'b010, d = 3'b011, e = 3'b100, f = 3'b101, g = 3'b110, h = 3'b111} curr_state, next_state;
	
	always_comb begin
		case(curr_state)
			a:	if (down)		next_state = b;	//1
				else 				next_state = curr_state;
			b:	if (up)			next_state = a;	//2
				else if (down)	next_state = c;
				else 				next_state = curr_state;
			c:	if (up)			next_state = b;	//3
				else if (down)	next_state = d;
				else 				next_state = curr_state;
			d:	if (up)			next_state = c;	//4
				else if (down)	next_state = e;
				else 				next_state = curr_state;
			e:	if (up)			next_state = d;	//5
				else if (down)	next_state = f;
				else 				next_state = curr_state;
			f:	if (up)			next_state = e;	//6
				else if (down)	next_state = g;
				else 				next_state = curr_state;
			g:	if (up)			next_state = f;	//7
				else if (down)	next_state = h;
				else 				next_state = curr_state;
			h:	if (up)			next_state = g;	//8
				else 				next_state = curr_state;
		endcase
		
		if (Reset || !Pause) 					lights = '0;
		else if (Pause && Set)					lights[curr_state] = thisRow;
	end
		
	always_ff @(posedge Clock) begin
		if (!Reset) begin // or pause, if needed
				curr_state <= next_state;
		end
			debug <= curr_state;
	end
	
endmodule

module userInput_testbench(); 
	logic Pause, up, down;
	logic [7:0] thisRow;
	logic Clock, Reset;
	logic [7:0] [7:0] lights;
	logic [2:0] debug;
	
	userInput dut (.Clock, .Reset, .Pause, .thisRow, .up, .down, .lights, .debug);
	
	//set up simulated clock
	parameter CLOCK_PERIOD=100;
	initial begin
		Clock <= 0;
		forever #(CLOCK_PERIOD/2) Clock <= ~Clock; // Forever toggle the clock
	end

	// Set up the inputs to the design. Each line is a clock cycle.
	initial begin
													@(posedge Clock);
		Reset <= 1; 							@(posedge Clock);
													@(posedge Clock);
		Reset <= 0;								@(posedge Clock);
													@(posedge Clock);
		 						@(posedge Clock);
													@(posedge Clock);
													@(posedge Clock);
								@(posedge Clock);
													@(posedge Clock);
													@(posedge Clock);
													@(posedge Clock);
								@(posedge Clock);
													@(posedge Clock);
		$stop;	//end 
		
	end
	
endmodule