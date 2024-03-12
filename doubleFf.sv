//copied from Lab 4, UNCHAGED

module doubleFf (Clock, Reset, key, feedback); 
	input logic Clock, Reset;
	input logic key;
	output logic feedback;
	
	logic Q;
			
			always_ff @(posedge Clock) begin
					Q <= key;
				end
				
			always_ff @(posedge Clock) begin
					feedback <= Q;
				end
endmodule
