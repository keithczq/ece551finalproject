module mac_tb();

reg [7:0] a, b;
reg clr, rst_n;
reg [25:0]acc;
reg clk;
mac mac1(.in1(a), .in2(b),.clr(clr), .clk(clk), .acc(acc), .rst_n(rst_n)); 

//Initialization of values
initial begin
	clk = 0;
	//Assert clear and reset
	rst_n = 0;
	clr = 1;
	#8
	//Deassert clear and reset
	rst_n = 1;
	clr = 0;
//Check for normal operation
	//Calculate 2*5 + (-2)*5 + (-3)*8
	//2*5
	a = 8'sb00000010;
	b = 8'sb00000101;
	//(-2)*5
	#10
	a = 8'sb11111110;
	b = 8'sb00000101;
	//(-3)*8
	#10
	a = 8'sb11111101;
	b = 8'sb00001000;

//Check for overflow
	//Calculate 30*2 + -8*5 + 4*1 
	#10
	a = 8'sb0001_1110;
	b = 8'sb0000_0010;
	#10
	a = 8'sb1111_1000;
	b = 8'sb0000_0101;
	#10
	a = 8'sb0000_0100;
	b = 8'sb0000_0001;

/*Check for underflow
	//Reset counts
	#20
	a = 0;
	b = 0;
	clr = 1;
	#20
	clr = 0;
	//Calculate -126*126 + -126*126 + -126*126
	#10
	a = 8'sb1000_0010;
	b = 8'sb0111_1110;
	#10
	a = 8'sb1000_0010;
	b = 8'sb0111_1110;
	#10
	a = 8'sb1000_0010;
	b = 8'sb0111_1110; */
	$stop();
end


//Clock oscillator
always 
	#5 clk = ~clk;


endmodule
