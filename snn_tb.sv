module snn_tb();

reg [7:0] led;
reg rst_n, clk, uart_rx, uart_tx;
reg[3:0] digit;

snn snn1(.clk(clk), .sys_rst_n(rst_n), .led(led), .uart_rx(uart_rx), .uart_tx(uart_tx));
always
	#5 clk = ~clk;

initial begin
	$readmemh("rom_act_func_lut_contents.txt", snn_tb.snn1.snn_core1.RAF1.rom);
	$readmemh("rom_output_weight_contents.txt", snn_tb.snn1.snn_core1.ROW1.rom);
	$readmemh("rom_hidden_weight_contents.txt", snn_tb.snn1.snn_core1.RHW1.rom);
	$readmemh("ram_input_contents_sample_8.txt", snn_tb.snn1.RIU1.ram);
	$readmemh("ram_output_contents.txt", snn_tb.snn1.snn_core1.ROU1.ram);
	$readmemh("ram_hidden_contents.txt", snn_tb.snn1.snn_core1.RHU1.ram);
	clk = 0;
	rst_n = 0;
	#5
	rst_n = 1;
	
	

end


endmodule



