module uart_tx_tb();

reg clk;
reg rst_n;
reg tx_start;
reg [7:0] tx_data;

wire tx;
wire tx_rdy;

uart_tx iDUT(.clk(clk), .rst_n(rst_n), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .tx_rdy(tx_rdy)); //FIXME

always
    #5 clk = ~clk;

initial begin

rst_n = 0;
clk = 0;
tx_start = 0;tx_data = 0;

#1000 rst_n = 1;

// Test 1: Drive tx_data with hex A5
#1000 tx_start = 1;
tx_data = 8'hA5;

#10 tx_start = 0;
tx_data = 0;

// Test 2: Drive tx_data with hex E7
@ (posedge tx_rdy)
#1005;
tx_start = 1;
tx_data = 8'hE7;

#10 tx_start = 0;
tx_data = 0;

// Test 3: Drive tx_data with hex 24
@ (posedge tx_rdy)
#1005;
tx_start = 1;
tx_data = 8'h24;

#10 tx_start = 0;
tx_data = 0;

@ (posedge tx_rdy)
#1000 $stop;
end
endmodule

