module rom_hidden_weight_tb();

reg [14:0] addr;
reg clk;
reg [7:0] q;

rom_hidden_weight RHW(.clk(clk), .addr(addr), .q(q));

/*module rom_hidden_weight (
 input [14:0] addr,
 input clk,
 output reg [7:0] q);*/
always 
	#5 clk = ~clk;

initial begin
	clk = 0;
	$readmemh("rom_hidden_weight_contents.txt", rom_hidden_weight_tb.RHW.rom);

	@ (negedge clk)
	addr = 36;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 37;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 38;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 39;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 40;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 41;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 42;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 783;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 784;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 785;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);
	


	@ (negedge clk)
	addr = 885;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 886;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	@ (negedge clk)
	addr = 887;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);
	@ (negedge clk)
	addr = 888;
	@ (posedge clk) #1
	$display("Value @ %d = %d", addr, q);

	
end



endmodule