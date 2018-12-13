module ram_input_unit (
 input data,
 input [9:0] addr,
 input we, clk,
 output q);

 // Declare the RAM variable
 reg ram[2**10 - 1:0];
 // Variable to hold the registered read address
 reg [9:0] addr_reg;

 initial 
 	$readmemh("ram_input_contents_sample_8.txt", ram);

 

 always @ (posedge clk)
 begin
 	if (we) // Write
 		ram[addr] <= data;
 	addr_reg <= addr;
 end

 assign q = ram[addr_reg];

endmodule

/*
module ram_hidden_unit (
 input [7:0] data,
 input [4:0] addr,
 input we, clk,
 output [7:0] q);

 // Declare the RAM variable
 reg [7:0] ram[2**4:0];
 // Variable to hold the registered read address
 reg [4:0] addr_reg;
*/