module uart_tx (clk, rst_n, tx_start, tx_data, tx, tx_rdy); //FIXME

input clk, rst_n, tx_start;
input reg [7:0] tx_data;
output reg tx, tx_rdy; 

reg clr, bit_full, baud_full, shift, load;

typedef enum reg {IDLE, TX} state_t;
state_t state, nxt_state;

reg [11:0] baud_cnt; //increases at every clock //clear baud counter at every half of max
reg [3:0] index_cnt;
reg [9:0] shift_reg;

// baud counter
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		baud_cnt <= 0;
	end
	else begin
		baud_cnt <= (clr) ? 0 : baud_cnt + 1;
	end 
end
assign baud_full = (baud_cnt == 12'b1010_0010_1100)? 1 : 0;

// index counter
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		index_cnt <= 4'b0000;
	end
	else begin
		if(load) begin
			index_cnt <= 4'b0000;
		end
		else begin
			if(shift) begin
				index_cnt <= index_cnt + 1;
			end
		end
	end
end
assign bit_full = (index_cnt == 4'b1010)? 1 : 0;

//SHIFT REGISTER
//shift right since LSB comes in first
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		shift_reg[0] <= 1'b1;
	end
	else begin
		if (load) begin
			shift_reg <= {1'b1, tx_data, 1'b0};
		end
		else begin
			if (shift) begin
				shift_reg <= {1'b1, shift_reg[9:1]};
			end
			else begin
				shift_reg <= shift_reg;
			end
		end
	end
end
assign tx = shift_reg[0];


//UPDATING OF FLIP FLOP WITH NEXT STATE
always_ff @ (posedge clk, negedge rst_n) begin
	
	if (!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= nxt_state;
	end
end

// 
always_comb begin
	shift = 0;
	load = 0;
	clr = 0;
	tx_rdy = 0;
	nxt_state = IDLE;
	case(state)
		IDLE:
			if(tx_start) begin
				load = 1;
				clr = 1;
				nxt_state = TX;
			end
			else begin
				clr = 1;
				tx_rdy = 1;
				nxt_state = IDLE;
			end

		TX:
			if(bit_full) begin
				nxt_state = IDLE;
			end
			else begin
				if(baud_full) begin
					shift = 1;
					clr = 1;
					nxt_state = TX;
				end
				else begin
					nxt_state = TX;
				end
			end
	endcase
end
		
	
endmodule		

		

