
// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
    output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	 output logic [9:0]  LEDR;
    input  logic [3:0]  KEY;
    input  logic [9:0]  SW;
    output logic [35:0] GPIO_1;
    input logic CLOCK_50;

	 // Turn off HEX displays
    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
	 
	 
	 /* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	    ===========================================================*/
	 logic [31:0] clk;
	 logic SYSTEM_CLOCK;
	 
	 clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));
	 
	 assign SYSTEM_CLOCK = clk[14];
	 
	 /* If you notice flickering, set SYSTEM_CLOCK faster.
	    However, this may reduce the brightness of the LED board. */
	
	 
	 /* Set up LED board driver
	    ================================================================== */
	 logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
    logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	 
	 logic Reset, Pause, Set;          // reset - toggle this on startup
	
	 assign Reset	= SW[9];
	 assign Pause 	= SW[8];
	 assign Set 	= !KEY[0];
	 assign LEDR[9] = Reset;
	 assign LEDR[8] = Pause; 
	 
	 /* Standard LED Driver instantiation - set once and 'forget it'. 
	    See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	 LEDDriver Driver (.GPIO_1, .RedPixels, .GrnPixels, .EnableCount(1) , .CLK(SYSTEM_CLOCK), .RST(Reset));
	 
	 
	 /* LED board test submodule - paints the board with a static pattern.
	    Replace with your own code driving RedPixels and GrnPixels.
		 
	 	 SW[9]      : Reset
		 SW[8]		: Pause
		 LEDR[0]		: down
		 LEDR[1]		: up
		 =================================================================== */
		logic uTemp, dTemp, up, down;
		logic [2:0] debug;
		
		always_ff @(posedge SYSTEM_CLOCK) begin
			LEDR[7:0] <= (1 << debug);
		end
		
		button x 		(.Clock(SYSTEM_CLOCK), .Reset, .key(KEY[2]), .feedback(uTemp));
		button y 		(.Clock(SYSTEM_CLOCK), .Reset, .key(KEY[3]), .feedback(dTemp));
		doubleFf a		(.Clock(SYSTEM_CLOCK), .Reset, .key(uTemp), 	.feedback(up));
		doubleFf b		(.Clock(SYSTEM_CLOCK), .Reset, .key(dTemp), 	.feedback(down));
		
		userInput user	(.Clock(SYSTEM_CLOCK), .Reset, .Pause, .Set, .thisRow(SW[7:0]), .up, .down, .lights({GrnPixels[0][7:0], GrnPixels[1][7:0], GrnPixels[2][7:0], GrnPixels[3][7:0], GrnPixels[4][7:0], GrnPixels[5][7:0], GrnPixels[6][7:0], GrnPixels[7][7:0]}), .debug);
		
		//corners
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][1], RedPixels[1][0], RedPixels[1][1]}), .in(GrnPixels[0][0]), .out(RedPixels[0][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][6], RedPixels[1][6], RedPixels[1][7]}), .in(GrnPixels[0][7]), .out(RedPixels[0][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][0], RedPixels[6][1], RedPixels[7][1]}), .in(GrnPixels[7][0]), .out(RedPixels[7][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][7], RedPixels[7][6], RedPixels[6][6]}), .in(GrnPixels[7][7]), .out(RedPixels[7][7]));
				
		//row 0
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][1], RedPixels[1][1], RedPixels[0][0], RedPixels[2][1], RedPixels[1][0]}), .in(GrnPixels[1][0]), .out(RedPixels[1][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][0], RedPixels[1][1], RedPixels[3][1], RedPixels[2][1], RedPixels[2][0]}), .in(GrnPixels[2][0]), .out(RedPixels[2][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][1], RedPixels[4][1], RedPixels[2][0], RedPixels[3][1], RedPixels[3][0]}), .in(GrnPixels[3][0]), .out(RedPixels[3][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][1], RedPixels[4][1], RedPixels[3][0], RedPixels[5][1], RedPixels[4][0]}), .in(GrnPixels[4][0]), .out(RedPixels[4][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][1], RedPixels[4][1], RedPixels[4][0], RedPixels[6][1], RedPixels[6][0]}), .in(GrnPixels[5][0]), .out(RedPixels[5][0]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[7][1], RedPixels[5][1], RedPixels[7][0], RedPixels[6][1], RedPixels[5][0]}), .in(GrnPixels[6][0]), .out(RedPixels[6][0]));
				
		//row 1
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][0], RedPixels[1][1], RedPixels[0][0], RedPixels[0][1], RedPixels[1][2]}), .in(GrnPixels[0][1]), 																	.out(RedPixels[0][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][2], RedPixels[2][1], RedPixels[0][0], RedPixels[2][0], RedPixels[1][0], RedPixels[1][2], RedPixels[0][2], RedPixels[0][1]}), .in(GrnPixels[1][1]), .out(RedPixels[1][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][0], RedPixels[2][0],	RedPixels[3][0], RedPixels[3][2], RedPixels[3][1], RedPixels[2][2], RedPixels[1][2], RedPixels[1][1]}), .in(GrnPixels[2][1]),.out(RedPixels[2][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][2], RedPixels[3][2],	RedPixels[4][2], RedPixels[4][1], RedPixels[4][0], RedPixels[3][0], RedPixels[1][1], RedPixels[2][1]}), .in(GrnPixels[3][1]),.out(RedPixels[3][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][1], RedPixels[3][2],	RedPixels[4][2], RedPixels[5][2], RedPixels[3][0], RedPixels[5][1], RedPixels[4][0], RedPixels[5][0]}), .in(GrnPixels[4][1]),.out(RedPixels[4][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][1], RedPixels[4][2],	RedPixels[5][2], RedPixels[6][2], RedPixels[6][1], RedPixels[4][0], RedPixels[5][0], RedPixels[6][0]}), .in(GrnPixels[5][1]),.out(RedPixels[5][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][2], RedPixels[5][1],	RedPixels[7][2], RedPixels[6][2], RedPixels[7][1], RedPixels[5][0], RedPixels[6][0], RedPixels[7][0]}), .in(GrnPixels[6][1]),.out(RedPixels[6][1]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[7][2], RedPixels[6][2], RedPixels[7][0], RedPixels[6][1], RedPixels[6][0]}), .in(GrnPixels[7][1]), 									  							  .out(RedPixels[7][1]));
				
		//row 2
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][1], RedPixels[1][1], RedPixels[1][2], RedPixels[1][3], RedPixels[0][3]}), .in(GrnPixels[0][2]), 																	.out(RedPixels[0][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][1], RedPixels[1][1], RedPixels[2][1], RedPixels[2][2], RedPixels[2][3], RedPixels[1][3], RedPixels[0][3], RedPixels[0][2]}), .in(GrnPixels[1][2]), .out(RedPixels[1][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][1], RedPixels[2][1],	RedPixels[3][1], RedPixels[3][2], RedPixels[3][3], RedPixels[2][3], RedPixels[1][3], RedPixels[1][2]}), .in(GrnPixels[2][2]), .out(RedPixels[2][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][1], RedPixels[3][1],	RedPixels[4][1], RedPixels[4][2], RedPixels[4][3], RedPixels[3][3], RedPixels[2][3], RedPixels[2][2]}), .in(GrnPixels[3][2]), .out(RedPixels[3][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][1], RedPixels[4][1],	RedPixels[5][1], RedPixels[5][2], RedPixels[5][3], RedPixels[4][3], RedPixels[3][3], RedPixels[3][2]}), .in(GrnPixels[4][2]), .out(RedPixels[4][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][1], RedPixels[5][1],	RedPixels[6][1], RedPixels[6][2], RedPixels[6][3], RedPixels[5][3], RedPixels[4][3], RedPixels[4][2]}), .in(GrnPixels[5][2]), .out(RedPixels[5][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][1], RedPixels[6][1],	RedPixels[7][1], RedPixels[7][2], RedPixels[7][3], RedPixels[6][3], RedPixels[5][3], RedPixels[5][2]}), .in(GrnPixels[6][2]), .out(RedPixels[6][2]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][1], RedPixels[7][1], RedPixels[7][3], RedPixels[6][3], RedPixels[6][2]}), .in(GrnPixels[7][2]), 																	.out(RedPixels[7][2]));
			
		//row 3
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][2], RedPixels[1][2], RedPixels[1][3], RedPixels[1][4], RedPixels[0][4]}), .in(GrnPixels[0][3]), 																	.out(RedPixels[0][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][2], RedPixels[1][2], RedPixels[2][2], RedPixels[2][3], RedPixels[2][4], RedPixels[1][4], RedPixels[0][4], RedPixels[0][3]}), .in(GrnPixels[1][3]), .out(RedPixels[1][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][2], RedPixels[2][2],	RedPixels[3][2], RedPixels[3][3], RedPixels[3][4], RedPixels[2][4], RedPixels[1][4], RedPixels[1][3]}), .in(GrnPixels[2][3]), .out(RedPixels[2][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][2], RedPixels[3][2],	RedPixels[4][2], RedPixels[4][3], RedPixels[4][4], RedPixels[3][4], RedPixels[2][4], RedPixels[2][3]}), .in(GrnPixels[3][3]), .out(RedPixels[3][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][2], RedPixels[4][2],	RedPixels[5][2], RedPixels[5][3], RedPixels[5][4], RedPixels[4][4], RedPixels[3][4], RedPixels[3][3]}), .in(GrnPixels[4][3]), .out(RedPixels[4][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][2], RedPixels[5][2],	RedPixels[6][2], RedPixels[6][3], RedPixels[6][4], RedPixels[5][4], RedPixels[4][4], RedPixels[4][3]}), .in(GrnPixels[5][3]), .out(RedPixels[5][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][2], RedPixels[6][2],	RedPixels[7][2], RedPixels[7][3], RedPixels[7][4], RedPixels[6][4], RedPixels[5][4], RedPixels[5][3]}), .in(GrnPixels[6][3]), .out(RedPixels[6][3]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][2], RedPixels[7][2], RedPixels[7][4], RedPixels[6][4], RedPixels[6][3]}), .in(GrnPixels[7][3]), 																	.out(RedPixels[7][3]));	

		//row 4
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][3], RedPixels[1][3], RedPixels[1][4], RedPixels[1][5], RedPixels[0][5]}), .in(GrnPixels[0][4]), 																	.out(RedPixels[0][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][3], RedPixels[1][3], RedPixels[2][3], RedPixels[2][4], RedPixels[2][5], RedPixels[1][5], RedPixels[0][5], RedPixels[0][4]}), .in(GrnPixels[1][4]), .out(RedPixels[1][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][3], RedPixels[2][3],	RedPixels[3][3], RedPixels[3][4], RedPixels[3][5], RedPixels[2][5], RedPixels[1][5], RedPixels[1][4]}), .in(GrnPixels[2][4]), .out(RedPixels[2][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][3], RedPixels[3][3],	RedPixels[4][3], RedPixels[4][4], RedPixels[4][5], RedPixels[3][5], RedPixels[2][5], RedPixels[2][4]}), .in(GrnPixels[3][4]), .out(RedPixels[3][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][3], RedPixels[4][3],	RedPixels[5][3], RedPixels[5][4], RedPixels[5][5], RedPixels[4][5], RedPixels[3][5], RedPixels[3][4]}), .in(GrnPixels[4][4]), .out(RedPixels[4][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][3], RedPixels[5][3],	RedPixels[6][3], RedPixels[6][4], RedPixels[6][5], RedPixels[5][5], RedPixels[4][5], RedPixels[4][4]}), .in(GrnPixels[5][4]), .out(RedPixels[5][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][3], RedPixels[6][3],	RedPixels[7][3], RedPixels[7][4], RedPixels[7][5], RedPixels[6][5], RedPixels[5][5], RedPixels[5][4]}), .in(GrnPixels[6][4]), .out(RedPixels[6][4]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][3], RedPixels[7][3], RedPixels[7][4], RedPixels[6][5], RedPixels[6][4]}), .in(GrnPixels[7][4]), 																	.out(RedPixels[7][4]));
			
		//row 5
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][4], RedPixels[1][4], RedPixels[1][5], RedPixels[1][6], RedPixels[0][6]}), .in(GrnPixels[0][5]),																		.out(RedPixels[0][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][4], RedPixels[1][4], RedPixels[2][4], RedPixels[2][5], RedPixels[2][6], RedPixels[1][6], RedPixels[0][6], RedPixels[0][5]}), .in(GrnPixels[1][5]), .out(RedPixels[1][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][4], RedPixels[2][4],	RedPixels[3][4], RedPixels[3][5], RedPixels[3][6], RedPixels[2][6], RedPixels[1][6], RedPixels[1][5]}), .in(GrnPixels[2][5]), .out(RedPixels[2][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][4], RedPixels[3][4],	RedPixels[4][4], RedPixels[4][5], RedPixels[4][6], RedPixels[3][6], RedPixels[2][6], RedPixels[2][5]}), .in(GrnPixels[3][5]), .out(RedPixels[3][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][4], RedPixels[4][4],	RedPixels[5][4], RedPixels[5][5], RedPixels[5][6], RedPixels[4][6], RedPixels[3][6], RedPixels[3][5]}), .in(GrnPixels[4][5]), .out(RedPixels[4][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][4], RedPixels[5][4],	RedPixels[6][4], RedPixels[6][5], RedPixels[6][6], RedPixels[5][6], RedPixels[4][6], RedPixels[4][5]}), .in(GrnPixels[5][5]), .out(RedPixels[5][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][4], RedPixels[6][4],	RedPixels[7][4], RedPixels[7][5], RedPixels[7][6], RedPixels[6][6], RedPixels[5][6], RedPixels[5][5]}), .in(GrnPixels[6][5]), .out(RedPixels[6][5]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][4], RedPixels[7][4], RedPixels[7][5], RedPixels[6][6], RedPixels[6][5]}), .in(GrnPixels[7][5]), 																	.out(RedPixels[7][5]));	

		//row 6
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][5], RedPixels[1][5], RedPixels[1][6], RedPixels[1][7], RedPixels[0][7]}), .in(GrnPixels[0][6]), 																	.out(RedPixels[0][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][5], RedPixels[1][5], RedPixels[2][5], RedPixels[2][6], RedPixels[2][7], RedPixels[1][7], RedPixels[0][7], RedPixels[0][6]}), .in(GrnPixels[1][6]), .out(RedPixels[1][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][5], RedPixels[2][5],	RedPixels[3][5], RedPixels[3][6], RedPixels[3][7], RedPixels[2][7], RedPixels[1][7], RedPixels[1][6]}), .in(GrnPixels[2][6]), .out(RedPixels[2][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][5], RedPixels[3][5],	RedPixels[4][5], RedPixels[4][6], RedPixels[4][7], RedPixels[3][7], RedPixels[2][7], RedPixels[2][6]}), .in(GrnPixels[3][6]), .out(RedPixels[3][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][5], RedPixels[4][5],	RedPixels[5][5], RedPixels[5][6], RedPixels[5][7], RedPixels[4][7], RedPixels[3][7], RedPixels[3][6]}), .in(GrnPixels[4][6]), .out(RedPixels[4][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][5], RedPixels[5][5],	RedPixels[6][5], RedPixels[6][6], RedPixels[6][7], RedPixels[5][7], RedPixels[4][7], RedPixels[4][6]}), .in(GrnPixels[5][6]), .out(RedPixels[5][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][5], RedPixels[6][5],	RedPixels[7][5], RedPixels[7][6], RedPixels[7][7], RedPixels[6][7], RedPixels[5][7], RedPixels[5][6]}), .in(GrnPixels[6][6]), .out(RedPixels[6][6]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[6][5], RedPixels[7][5], RedPixels[7][6], RedPixels[6][7], RedPixels[6][6]}), .in(GrnPixels[7][6]), 																	.out(RedPixels[7][6]));	

		//row 7
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[0][6], RedPixels[1][6], RedPixels[2][6], RedPixels[2][7], RedPixels[0][7]}), .in(GrnPixels[1][7]), .out(RedPixels[1][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[1][6], RedPixels[2][6], RedPixels[3][6], RedPixels[3][7], RedPixels[1][7]}), .in(GrnPixels[2][7]), .out(RedPixels[2][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[2][6], RedPixels[3][6], RedPixels[4][6], RedPixels[4][7], RedPixels[2][7]}), .in(GrnPixels[3][7]), .out(RedPixels[3][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[3][6], RedPixels[4][6], RedPixels[5][6], RedPixels[5][7], RedPixels[3][7]}), .in(GrnPixels[4][7]), .out(RedPixels[4][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[4][6], RedPixels[5][6], RedPixels[6][6], RedPixels[6][7], RedPixels[4][7]}), .in(GrnPixels[5][7]), .out(RedPixels[5][7]));
		Cell (.Clock(SYSTEM_CLOCK), .Reset, .Pause, .border({RedPixels[5][6], RedPixels[6][6], RedPixels[7][6], RedPixels[7][7], RedPixels[5][7]}), .in(GrnPixels[6][7]), .out(RedPixels[6][7]));		
endmodule