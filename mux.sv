module mux( select, d1, d0, q );

input select;
input d1, d0;
output q;

assign q = (select) ? d1 : d0;

endmodule
