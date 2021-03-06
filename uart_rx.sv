module uart_rx(clk, rst_n, rx, rx_rdy, rx_data);
input clk, rst_n, rx;
output reg rx_rdy;
output reg [7:0] rx_data;
reg [7:0] rx_shift;//FIXME

reg [11:0] baud_cnt; //increases at every clock //clear baud counter at every half of max
reg [3:0] index_cnt;
reg clr_baud, clr_shift_reg, shift, shift_reg_full, half_baud, full_baud, stop_bit;


typedef enum reg[1:0] {IDLE, FRONT_PORCH, RX, BACK_PORCH} state_t; 
state_t state, nxt_state;

//UPDATING OF FLIP FLOP WITH NEXT STATE
always_ff @ (posedge clk, negedge rst_n) begin
	
	if (!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= nxt_state;
	end
end

//COMINBATIONAL LOGIC FOR NEXT STATE
always @(*) begin
	//outputs
	rx_rdy = 1'b0;
	clr_baud = 1'b0;
	clr_shift_reg = 1'b0;
	shift = 1'b0;
	
	case (state)
		default: begin // IDLE
			if (!rx) begin
				nxt_state = FRONT_PORCH;
			end
			else begin
				clr_baud = 1'b1;
				clr_shift_reg = 1'b1;
				nxt_state = IDLE;
			end
		end
		FRONT_PORCH: begin
			if (half_baud) begin
				clr_baud = 1'b1;
				clr_shift_reg = 1'b1;
				nxt_state = RX;
			end
			else begin
				clr_shift_reg = 1'b1;
				nxt_state = FRONT_PORCH;
			end
		end
		RX: begin
			if (shift_reg_full == 1'b1 && full_baud == 1'b1) begin
				clr_baud = 1'b1;
				stop_bit = rx;
				nxt_state = BACK_PORCH;
			end
			else if (shift_reg_full == 1'b0 && full_baud == 1'b1) begin
				shift = 1'b1;
				clr_baud = 1'b1;
				nxt_state = RX;
			end
			else begin //case of shift_reg_full = 1 or 0 & full_baud = 0 or 0
				nxt_state = RX; 
			end
		end
		BACK_PORCH: begin //BACK_PORCH
			if (half_baud == 1'b1 && stop_bit == 1'b1) begin
				rx_rdy = 1'b1;
				rx_data = rx_shift;
				nxt_state = IDLE;
			end	
			else if (half_baud == 1'b1 && stop_bit == 1'b0) begin
				nxt_state = IDLE;
			end	
			else begin
				nxt_state = BACK_PORCH;
			end
		end
	endcase
end

//BAUD COUNTER
always @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		baud_cnt <= 12'b0000_0000_0000;
	end
	else if (clr_baud) begin
		baud_cnt <= 12'b0000_0000_0000;
	end
	else begin
		baud_cnt <= baud_cnt + 1;

	end
end
assign half_baud = (baud_cnt >= 12'b0101_0001_0110) ? 1'b1 : 1'b0;
assign full_baud = (baud_cnt >= 12'b1010_0010_1100) ? 1'b1 : 1'b0;

//INDEX COUNTER
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		index_cnt <= 4'b0;
	end
	else if (clr_shift_reg) begin
		index_cnt <= 4'b0;
	end
	else begin
		if (shift) begin
			index_cnt <= index_cnt + 1;
		end
	end
end
assign shift_reg_full = (index_cnt == 4'b1000) ? 1 : 0;

//SHIFT REGISTER
//shift right since LSB comes in first
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		 rx_shift <= 8'b0;
	end
	else begin
		//Shift right
		if (shift) begin
			rx_shift <= { rx, rx_shift[7:1]};
		end
		else begin
			rx_shift <= rx_shift;
		end
	end
end


endmodule
