module sub( input [8:0] D,
				input [8:0] Register,
				output [8:0] D_Sub);
				
	
logic [8:0] temp;

assign temp = ~D;


	
	ripple_adder addition (.A(Register), .B(temp), .cin(1'b1), .S(D_Sub));
	
	
endmodule