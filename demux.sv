//Verilog module for 1:2 DEMUX
module demux(data, sel, q_0, q_1);

input reg [7:0] data;
input sel;
output reg [7:0] q_0, q_1;

    always @(*) begin
        case (sel)
            1'b0 : begin
                        q_0 = data;
                        q_1 = 0;
                      end

            1'b1 : begin
                        q_0 = 0;
                        q_1 = data;
                      end            
        endcase
    end
endmodule
