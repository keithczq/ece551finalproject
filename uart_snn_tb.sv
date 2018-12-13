module uart_snn_tb();

reg clk, rst_n;
wire [7:0] led;
reg rx;
wire uart_tx;
integer x;
reg [9:0] frame;

snn iDUT (.clk(clk), .sys_rst_n(rst_n), .led(led), .uart_rx(rx), .uart_tx(uart_tx));

initial begin
	rx = 1;
	clk = 0; 
	rst_n = 0; //assert reset
	repeat(1302) @(posedge clk);
	#1
	rst_n = 1; //deassert reset
	//Test for A5 
	frame = {1'b1, 8'b1010_0101, 1'b0}; //1 at the MSB for stop bit, followed by hex A5, followed by 0 for start bit
	for (x = 0; x < 10; x = x + 1) begin	
		rx = frame[x];
		repeat(2604) @(posedge clk);
	end

	//Test for E7 
	repeat(1302) @(posedge clk);
	frame = {1'b1, 8'b1110_0111, 1'b0}; //1 at the MSB for stop bit, followed by hex A5, followed by 0 for start bit
	for (x = 0; x < 10; x = x + 1) begin	
		rx = frame[x];
		repeat(2604) @(posedge clk);
	end
	repeat(1302) @(posedge clk);
	//Test for 24
	frame = {1'b1, 8'b0010_0100, 1'b0}; //1 at the MSB for stop bit, followed by hex A5, followed by 0 for start bit
	for (x = 0; x < 10; x = x + 1) begin	
		rx = frame[x];
		repeat(2604) @(posedge clk);
	end

end

always 
	#5 clk = ~clk;

endmodule
