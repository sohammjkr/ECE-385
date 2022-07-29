module SEXT 
		#(parameter size = 2)
		(input signed [size - 1:0] in, 
		 output signed [15:0] out );

			assign out = in;
		
endmodule 