module CSA(	input x, y, z,
					
				output s, c);

assign s = (x ^ y ^ z);

assign c = (x & y) | (y & z) | (x & z);

endmodule

module MUX( input In0, In1, InC,
				output logic Out);
	
	always_comb
		begin
	
			if(InC == 1'b1) 
				Out = In1;
	
			else
				Out = In0;
	
		end

	endmodule

module firstCSA(input [3:0] inA, inB, 			// Charlie 
				input cin,
				output [3:0] sum,
				output cout);
				
logic [3:0] CSA1;

CSA firstCSA0(.x(inA[0]), .y(inB[0]), .z(1'b0), .s(sum[0]), .c(CSA1[0]));
CSA firstCSA1(.x(inA[1]), .y(inB[1]), .z(CSA1[0]), .s(sum[1]), .c(CSA1[1]));
CSA firstCSA2(.x(inA[2]), .y(inB[2]), .z(CSA1[1]), .s(sum[2]), .c(CSA1[2]));
CSA firstCSA3(.x(inA[3]), .y(inB[3]), .z(CSA1[2]), .s(sum[3]), .c(cout));

endmodule

module CSA4(input [3:0] inA, inB, 			// Greg 
				input cin,
				output [3:0] sum,
				output cout);
				
logic [3:0] s0, s1, carry0, carry1;

CSA CSA00(.x(inA[0]), .y(inB[0]), .z(1'b0), .s(s0[0]), .c(carry0[0]));
CSA CSA01(.x(inA[1]), .y(inB[1]), .z(carry0[0]), .s(s0[1]), .c(carry0[1]));
CSA CSA02(.x(inA[2]), .y(inB[2]), .z(carry0[1]), .s(s0[2]), .c(carry0[2]));
CSA CSA03(.x(inA[3]), .y(inB[3]), .z(carry0[2]), .s(s0[3]), .c(carry0[3]));

CSA CSA10(.x(inA[0]), .y(inB[0]), .z(1'b1), .s(s1[0]), .c(carry1[0]));
CSA CSA11(.x(inA[1]), .y(inB[1]), .z(carry1[0]), .s(s1[1]), .c(carry1[1]));
CSA CSA12(.x(inA[2]), .y(inB[2]), .z(carry1[1]), .s(s1[2]), .c(carry1[2]));
CSA CSA13(.x(inA[3]), .y(inB[3]), .z(carry1[2]), .s(s1[3]), .c(carry1[3]));

MUX carry_select(.In0(carry0[3]), .In1(carry1[3]), .InC(cin), .Out(cout));

MUX sum_select0(.In0(s0[0]), .In1(s1[0]), .InC(cin), .Out(sum[0]));
MUX sum_select1(.In0(s0[1]), .In1(s1[1]), .InC(cin), .Out(sum[1]));
MUX sum_select2(.In0(s0[2]), .In1(s1[2]), .InC(cin), .Out(sum[2]));
MUX sum_select3(.In0(s0[3]), .In1(s1[3]), .InC(cin), .Out(sum[3]));

endmodule
	
	
	
module select_adder (							//Steve
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

logic carry1, carry2, carry3;

firstCSA CSA4_0(.inA(A[3:0]), .inB(B[3:0]), .cin(cin), .sum(S[3:0]), .cout(carry1)); //Calls Charlie

CSA4		CSA4_1(.inA(A[7:4]), .inB(B[7:4]), .cin(carry1), .sum(S[7:4]), .cout(carry2));		//Calls Gregs
CSA4		CSA4_2(.inA(A[11:8]), .inB(B[11:8]), .cin(carry2), .sum(S[11:8]), .cout(carry3));
CSA4		CSA4_3(.inA(A[15:12]), .inB(B[15:12]), .cin(carry3), .sum(S[15:12]), .cout(cout));
	  
endmodule
