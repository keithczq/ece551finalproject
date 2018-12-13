module mac(in1, in2, clr, rst_n, clk, acc); 

//Inputs & Outputs
input clk, clr, rst_n;
input signed [7:0]in1, in2;
output reg signed [25:0]acc;

//Registers to hold values
reg signed [15:0]mult;
reg signed [25:0]mult_ext, acc_nxt, add;

//Multiplier
assign mult = in1 * in2;

//Sign-extension
assign mult_ext = { {10{mult[15]}}, mult[15:0] };
 
//Adder
assign add = mult_ext + acc;

//Mux
assign acc_nxt = (clr) ? 26'sb0 : add;

//Output
always_ff @ (posedge clk, negedge rst_n ) begin
	if (!rst_n) begin
		acc <= 26'sb0;
	end
	else begin
		acc <= acc_nxt;
	end
end

endmodule
