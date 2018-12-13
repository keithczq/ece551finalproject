module snn(clk, sys_rst_n, led, uart_rx, uart_tx);
		
	input clk;			      	// 50MHz clock
	input sys_rst_n;			// Unsynched reset from push button. Needs to be synchronized.
	output logic [7:0] led;			// Drives LEDs of DE0 nano board
	
	input uart_rx;
	output uart_tx;

	logic rst_n;				// Synchronized active low reset
	
	logic uart_rx_ff, uart_rx_synch;

	reg [7:0] uart_data;   //modified 
	
	reg [3:0] byte_cnt;
	reg [6:0] NE_cnt;
	reg byte_full, NE_cnt_full, inc_NE_cnt, clr_byte_cnt, clr_NE_cnt, we,
		tx_start, rx_rdy, done, tx_rdy, rst_in_cnt, start;
	wire [9:0] addr_in_unit;
	reg [3:0] digit;
	reg [9:0] addr;
	reg [7:0] digit_ext;
	

	typedef enum reg[2:0] {IDLE, RX_WAIT, RAM_WRITE, SNN_CORE, TX_WAIT} state_t; 
	state_t state, nxt_state;

	/******************************************************
	Reset synchronizer
	******************************************************/
	rst_synch i_rst_synch(.clk(clk), .sys_rst_n(sys_rst_n), .rst_n(rst_n));
	
	/******************************************************
	UART
	******************************************************/
	
	// Declare wires below
	
	// Double flop RX for meta-stability reasons
	always_ff @(posedge clk, negedge rst_n)
		if (!rst_n) begin
		uart_rx_ff <= 1'b1;
		uart_rx_synch <= 1'b1;
	end else begin
	  uart_rx_ff <= uart_rx;
	  uart_rx_synch <= uart_rx_ff;
	end
	
	
	// Instantiate DUTs
	// For UART_RX, use "uart_rx_synch", which is synchronized, not "uart_rx".
	uart_rx uart_rx1(.clk(clk), .rst_n(rst_n), .rx(uart_rx_synch), .rx_rdy(rx_rdy), .rx_data(uart_data));
	ram_input_unit RIU1( .data(uart_data[byte_cnt]), .addr(addr), .we(we), .clk(clk), .q(RIU_q));
	snn_core snn_core1(.clk(clk), .rst_n(rst_n), .start(start), .q_in(RIU_q), .addr_in_unit(addr_in_unit), .digit(digit), .done(done));
	uart_tx uart_tx1(.clk(clk), .rst_n(rst_n), .tx_start(tx_start), .tx_data(digit_ext), .tx(uart_tx), .tx_rdy(tx_rdy));

	assign addr = (we) ? ({NE_cnt, byte_cnt[2:0]}) : addr_in_unit;
	assign digit_ext = {4'b0000, digit}; // Extend 4-bit digit to 8-bit
			
	/******************************************************
	LED
	******************************************************/
	
	//UPDATING OF FLIP FLOP WITH NEXT STATE
	always_ff @ (posedge clk, negedge rst_n) begin
	
		if (!rst_n) begin
			state <= IDLE;
		end
		else begin
			state <= nxt_state;
		end
	end

	always @ (posedge clk, negedge rst_n) begin
		if (!rst_n) begin
			led <= 8'b0;
		end
		
		else begin
			led <= digit_ext;
		end
		
	end

	// Byte Counter (free-running)
	always @ (posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			byte_cnt <= 4'b0;
		end
		else begin
			byte_cnt <= (clr_byte_cnt) ? 0 : byte_cnt + 1;
		end
	end
	assign byte_full = (byte_cnt == 4'b1000)? 1 : 0;

	// Ninety-eight Counter
	always @ (posedge clk, negedge rst_n) begin
		if(!rst_n) begin
			NE_cnt <= 7'b0;
		end
		else begin
			if(clr_NE_cnt) begin
				NE_cnt <= 7'b0;
			end
			else if(inc_NE_cnt) begin
				NE_cnt <= NE_cnt + 1;
			end
			else begin
				NE_cnt <= NE_cnt;
			end
		end
	end
	assign NE_full = (NE_cnt == 7'b110_0001)? 1 : 0; //counts to index 97

	/******************************************************
	CONTROL FSM
	******************************************************/
	always @ (*) begin
		clr_NE_cnt = 0;
		clr_byte_cnt = 0;
		we = 0;
		inc_NE_cnt = 0;
		tx_start = 0;
		start = 0;

		case (state)
		default: begin // IDLE
			if (!uart_rx_synch) begin	
				clr_NE_cnt = 1;
				nxt_state = RX_WAIT;
			end
			else begin
				nxt_state = IDLE;
			end
		end
		RX_WAIT: begin
			if (!rx_rdy) begin
				nxt_state = RX_WAIT;
			end
			else begin
				clr_byte_cnt = 1;
				nxt_state = RAM_WRITE;
			end
		end
		RAM_WRITE: begin
			if (!byte_full) begin
				we = 1;
				nxt_state = RAM_WRITE;
			end
			else if (byte_full && NE_full) begin
				start = 1;
				nxt_state = SNN_CORE;
			end
			else begin
				inc_NE_cnt = 1;
				nxt_state = RX_WAIT;
			end
		end
		SNN_CORE: begin
			if (!done) begin
				nxt_state = SNN_CORE;
			end
			else begin
				tx_start = 1;
				nxt_state = TX_WAIT;
			end
		end
		TX_WAIT: begin
			if (!tx_rdy) begin
				nxt_state = TX_WAIT;
			end
			else begin
				nxt_state = IDLE;
			end
		end
		endcase
	end

endmodule
