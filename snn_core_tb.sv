module snn_core_tb();

reg [7:0] q_input;
reg done, start,rst_n, clk;
reg[3:0] digit;
reg [7:0] mac_in, mac_weight; //FIXME remove
reg [25:0] mac_result; //FIXME remove

reg [9:0] addr;

// institiate DUTs
ram_input_unit RIU1( .data(1'bx), .addr(addr), .we(1'b0), .clk(clk), .q(q_input));
snn_core snn_core1(.clk(clk), .rst_n(rst_n), .start(start), .q_in(q_input), .addr_in_unit(addr), .digit(digit), .done(done));

always
	#5 clk = ~clk;

initial begin
	$readmemh("rom_act_func_lut_contents.txt", snn_core_tb.snn_core1.RAF1.rom);
	$readmemh("rom_output_weight_contents.txt", snn_core_tb.snn_core1.ROW1.rom);
	$readmemh("rom_hidden_weight_contents.txt", snn_core_tb.snn_core1.RHW1.rom);
	$readmemh("ram_input_contents_sample_5.txt", snn_core_tb.RIU1.ram);
	$readmemh("ram_output_contents.txt", snn_core_tb.snn_core1.ROU1.ram);
	$readmemh("ram_hidden_contents.txt", snn_core_tb.snn_core1.RHU1.ram);

	clk = 0;
	rst_n = 0;
	@(posedge clk)
	rst_n = 1;
	start = 1;
	@(posedge clk)
	start = 0;
	@(posedge done)
	if (digit == 2)
		$display("PASSED: ACTUAL VALUE = %d EXPECTED VALUE = %d", digit, 2);
	else
		$display("FAILED: ACTUAL VALUE = %d EXPECTED VALUE = %d", digit, 2);
		$stop();

	/*
	@(posedge clk)
	start = 1;
	@(posedge clk)
	start = 0;
	@(posedge done)
	if (digit == 2)
		$display("PASSED: ACTUAL VALUE = %d EXPECTED VALUE = %d", digit, 2);
	else
		$display("FAILED: ACTUAL VALUE = %d EXPECTED VALUE = %d", digit, 2);
		$stop();
*/

end


endmodule



