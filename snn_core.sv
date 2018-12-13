module snn_core(clk, rst_n, start, q_in, addr_in_unit, digit, done); //FIXME remove mac_in, mac_weight, mac_result

input clk, rst_n, start, q_in;
output reg done;
output reg [3:0] digit;
output reg [9:0] addr_in_unit;

//wire ram_hid_unit, rom_hid_weight, rom_out_weight; 
reg [7:0] q_in_ext, RHW_q, ROW_q, RAF_q, RHU_q, ROU_q, max_val;
reg [7:0] mac_in, mac_weight; //FIXME remove output
reg [25:0] mac_result; //FIXME remove output
reg [25:0] result_hold;

reg [9:0]  in_cnt;  // 784  
reg [5:0] hid_cnt; // 32 
reg [3:0]  out_cnt; // 10
/*reg [14:0] in_hid_addr;
reg [8:0] hid_out_addr;*/
reg [10:0] mac_rect;

reg in_full, hid_full, out_full, hid_out_full, hid_over, out_over, 
    clr_in_cnt, clr_hid_cnt, clr_out_cnt, clr_mac, clr_max_val,
    inc_hid_cnt, inc_out_cnt, 
    we_hid, we_out, select_mac_in, select_mac_weight, update; 

//reg clr_in_hid_addr, clr_hid_out_addr, inc_in_hid_addr, inc_hid_out_addr,


typedef enum reg[3:0] {IDLE, MAC_HIDDEN, MAC_HIDDEN_FP, MAC_HIDDEN_BP, MAC_HIDDEN_WRITE, 
		             MAC_OUTPUT, MAC_OUTPUT_FP, MAC_OUTPUT_BP, MAC_OUTPUT_WRITE,
			     DONE} state_t; 
state_t state, nxt_state;

rom_hidden_weight RHW1( .addr({ hid_cnt[4:0], in_cnt}), .clk(clk), .q(RHW_q)); 
rom_output_weight ROW1( .addr({out_cnt,  hid_cnt[4:0]}), .clk(clk), .q(ROW_q));
rom_act_func_lut  RAF1( .addr(mac_rect + 11'b100_0000_0000), .clk(clk), .q(RAF_q)); //addr??
ram_hidden_unit   RHU1( .data(RAF_q), .addr(hid_cnt[4:0]), .we(we_hid), .clk(clk), .q(RHU_q)); //addr??
ram_output_unit   ROU1( .data(RAF_q), .addr(out_cnt), .we(we_out), .clk(clk), .q(ROU_q));
mac mac1(.in1(mac_in), .in2(mac_weight), .clr(clr_mac), .rst_n(rst_n), .clk(clk), .acc(mac_result)); 

//UPDATING OF FLIP FLOP WITH NEXT STATE
always_ff @ (posedge clk, negedge rst_n) begin
	
	if (!rst_n) begin
		state <= IDLE;
	end
	else begin
		state <= nxt_state;
	end
end

/*
// MAC result rectification
always_ff @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		mac_rect <= 11'b000_0000_0000;
	end
	else begin
		if((result_hold[25] == 0) && (result_hold[24:17] > 8'b0000_0000)) begin
			mac_rect <= 11'b011_1111_1111;		
		end
		else if((result_hold[25] == 1) && (result_hold[24:17] < 8'b1111_1111)) begin
			mac_rect <= 11'b100_0000_0000;
		end
		else begin
			mac_rect <= result_hold[17:7];
		end
	end
end


//assign result_hold = (update) ? mac_result : result_hold;

//Register to hold the value calculated of mac
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		result_hold <= 26'b0;
	end
	else begin
		if (update) begin
			result_hold <= mac_result;
		end
		else begin
			result_hold <= result_hold;
		end
	end
end
*/

//Register to hold the value calculated of mac and rectify it at the same time
always_ff @ (posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		mac_rect <= 11'b0;
	end
	else begin
		if (update) begin
			if((mac_result[25] == 0) && (mac_result[24:17] > 8'b0000_0000)) begin
				mac_rect <= 11'b011_1111_1111;		
			end
			else if((mac_result[25] == 1) && (mac_result[24:17] < 8'b1111_1111)) begin
				mac_rect <= 11'b100_0000_0000;
			end
			else begin
				mac_rect <= mac_result[17:7];
			end
		end
		else begin
			mac_rect <= mac_rect;
		end
	end
end

// Input counter
always_ff @ (posedge clk, negedge rst_n) begin // Do we need rst_n?
	if(!rst_n) begin
		in_cnt <= 0;
	end
	else begin
		in_cnt <= (clr_in_cnt) ? 0 : in_cnt + 1;
	end 
end
assign in_full = (in_cnt == 10'b11_0001_0001)? 1 : 0; //FIXME count one over 784 
assign addr_in_unit = in_cnt;

/*
// Input-Hidden address
always_ff @ (posedge clk, negedge rst_n) begin // Do we need rst_n?
	if(!rst_n) begin
		in_hid_addr <= 0;
	end
	else begin
		if (inc_in_hid_addr) begin
			in_hid_addr <= in_hid_addr + 1;
		end
		else if (clr_in_hid_addr) begin
			in_hid_addr <= 0;
		end
		else begin
			in_hid_addr <= in_hid_addr;
		end
	end 
end
assign in_hid_full = (in_hid_addr == 15'b110_0010_0000_0000)? 1 : 0;

// Hidden-Output address
always_ff @ (posedge clk, negedge rst_n) begin 
	if(!rst_n) begin
		hid_out_addr <= 0;
	end
	else begin
		if (inc_hid_out_addr) begin
			hid_out_addr <= hid_out_addr + 1;
		end
		else if (clr_hid_out_addr) begin
			hid_out_addr <= 0;
		end
		else begin
			hid_out_addr <= hid_out_addr;
		end
	end 
end
assign hid_out_full = (hid_out_addr == 9'b1_0100_0000)? 1 : 0;
*/

// Hidden counter/address
always @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		hid_cnt <= 6'b00_0000;
	end
	else begin
		if(clr_hid_cnt) begin
			hid_cnt <= 6'b00_0000;
		end
		else if(inc_hid_cnt) begin
			hid_cnt <= hid_cnt + 1;
		end
	end
end
assign hid_full = (hid_cnt == 6'b10_0000)? 1 : 0;
assign hid_over = (hid_cnt == 6'b10_0001)? 1 : 0; //FIXME added to count one over 32

// Output counter/addresss
always @ (posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		out_cnt <= 4'b0000;
	end
	else begin
		if(clr_out_cnt) begin
			out_cnt <= 4'b0000;
		end
		else if(inc_out_cnt) begin
			out_cnt <= out_cnt + 1;
		end
	end
end
assign out_full = (out_cnt == 4'b1010)? 1 : 0;
assign out_over = (out_cnt == 4'b1011)? 1 : 0; //FIXME to count to 11 for comparison of max_val

// FSM
always @(*) begin
	// outputs
	update = 0;
	we_hid = 0;
	we_out = 0;
	clr_in_cnt = 0;
	//clr_in_hid_addr = 0;
	clr_hid_cnt = 0;
	//clr_hid_out_addr = 0;
	clr_out_cnt = 0;
	clr_mac = 0;
	clr_max_val = 0;
	inc_hid_cnt = 0;
	//inc_in_hid_addr = 0;
	inc_out_cnt = 0;
	//inc_hid_out_addr = 0;	
	done = 0;
	select_mac_in = 0;
	select_mac_weight = 0;

	case (state)
		default: begin // IDLE
			if(!start) begin
				nxt_state = IDLE;
			end
			else begin
				clr_hid_cnt = 1;
				//clr_in_hid_addr = 1;
				nxt_state = MAC_HIDDEN_FP;
			end
		end

		MAC_HIDDEN_FP: begin
			clr_in_cnt = 1;
			clr_mac = 1; //FIXME added
			nxt_state = MAC_HIDDEN;
		end

		MAC_HIDDEN: begin
			if(!in_full) begin
				//inc_in_hid_addr = 1;
				nxt_state = MAC_HIDDEN;
			end
			else begin
				clr_in_cnt = 1; //FIXME added
				update = 1;
				nxt_state = MAC_HIDDEN_BP;	
			end
		end

		MAC_HIDDEN_BP: begin
			clr_in_cnt = 1; //FIXME added
			//FIXME original location of write enable
			nxt_state = MAC_HIDDEN_WRITE;
		end

		MAC_HIDDEN_WRITE: begin 
			clr_in_cnt = 1; //FIXME added
			we_hid = 1; //FIXME write enable moved down to here
			if(!hid_full) begin
				//FIXME clr mac originally here
				inc_hid_cnt = 1;
				//inc_in_hid_addr = 1;
				nxt_state = MAC_HIDDEN_FP;
			end
			else begin
				clr_hid_cnt = 1;
				clr_out_cnt = 1;
				//clr_hid_out_addr = 1;
				nxt_state = MAC_OUTPUT_FP;
			end			
		end

		MAC_OUTPUT_FP: begin
			
			select_mac_in = 1; 
			select_mac_weight = 1; 
			inc_hid_cnt = 1; //FIXME added
			clr_mac = 1; 
			nxt_state = MAC_OUTPUT;
		end

		MAC_OUTPUT: begin
			select_mac_in = 1; 
			select_mac_weight = 1; 
			if(!hid_over) begin //FIXME changed from hid_full to hid_over
				inc_hid_cnt = 1;
				nxt_state = MAC_OUTPUT;
			end
			else begin
				update = 1;
				nxt_state = MAC_OUTPUT_BP;
			end	
		end

		MAC_OUTPUT_BP: begin
			select_mac_in = 1; //FIXME
			select_mac_weight = 1; //FIXME
			//FIXME write enable signal was originally here
			nxt_state = MAC_OUTPUT_WRITE;
		end

		MAC_OUTPUT_WRITE: begin 
			we_out = 1;
			select_mac_in = 1; 
			select_mac_weight = 1; 
			if(!out_full) begin
				clr_mac = 1;
				inc_out_cnt = 1;
				clr_hid_cnt = 1; //moved from FP to here
				//inc_hid_out_addr = 1;
				nxt_state = MAC_OUTPUT_FP;
			end
			else begin
				clr_out_cnt = 1;
				clr_max_val = 1;
				nxt_state = DONE;
			end
		end

		DONE: begin
			if(!out_over) begin
				inc_out_cnt = 1;
				nxt_state = DONE;
			end
			else begin
				done = 1;
				nxt_state = IDLE;
			end
		end
	endcase
end

//To check for max value of output units
always_ff @(posedge clk, negedge rst_n) begin
	if (!rst_n) begin
		max_val <= 8'b0;
		digit <= 4'b0;
	end
	else begin
		if (clr_max_val) begin
			max_val <= 8'b0;
			digit <= 4'b0;
		end
		else if (ROU_q > max_val) begin
			max_val <= ROU_q; //update with new max value
			digit <= out_cnt - 1; //FIXME subtracted 1 because obtaining value has one clock delay compared to address
		end
		else begin
			//Hold previous values since new value found was less than current value
			max_val <= max_val;
			digit <= digit;	
		end
	end

end

// Extend 1-bit q_input to 8-bit
assign q_in_ext = (!q_in) ? 8'b0000_0000 : 8'b0111_1111;

// Mux for MAC input
assign mac_in = (select_mac_in) ? RHU_q : q_in_ext;

// Mux for MAC weight 
assign mac_weight = (select_mac_weight) ? ROW_q : RHW_q;


endmodule