module CLA( input x, y, z,
				output P, G, S	);

always_comb 

begin
 S = (x ^ y ^ z);

 P = x ^ y;

 G = x & y;
end
endmodule


module pg_gg(input [3:0] Pcla, Gcla,		// IN both greg and steve, per 4 bit adder there is one pg and gg
				output PG, GG
				);
assign PG = Pcla[3] & Pcla[2] & Pcla[1] & Pcla[0];
assign GG = Gcla[3] | (Gcla[2] & Pcla[3]) | (Gcla[1] & Pcla[2] & Pcla[3]) | (Gcla[0] & Pcla[1] & Pcla[2] & Pcla[3]);

endmodule
				

module CLA4(input [3:0] inA, inB, 			// Greg 
				input inC,
				output [3:0] s,
				output pg, gg);
				
logic [3:0] p, g;

logic carry1, carry2, carry3;
	
CLA CLA0(.x(inA[0]), .y(inB[0]), .z(inC), .P(p[0]), .G(g[0]), .S(s[0]));			// Potential Error, outputs reused as inputs
	
assign carry1 = (inC & p[0]) | g[0];

CLA CLA1(.x(inA[1]), .y(inB[1]), .z(carry1), .P(p[1]), .G(g[1]), .S(s[1]));
	
assign carry2 = (inC & p[0] & (p[1])) | (g[0] & p[1]) | g[1];


CLA CLA2(.x(inA[2]), .y(inB[2]), .z(carry2), .P(p[2]), .G(g[2]), .S(s[2]));
	
assign carry3 = (inC & p[0] & p[1] & p[2]) | (g[0] & p[1] & p[2]) | (g[1] & p[2]) | g[2];


CLA CLA3(.x(inA[3]), .y(inB[3]), .z(carry3), .P(p[3]), .G(g[3]), .S(s[3]));


pg_gg group(.Pcla(p[3:0]), .Gcla(g[3:0]), .PG(pg), .GG(gg));


endmodule
				


module lookahead_adder (
	input  [15:0] A, B,
	input         cin,
	output [15:0] S,
	output        cout
);

logic pg0, pg4, pg8, pg12, gg0, gg4, gg8, gg12, pg, gg, c4, c8, c12;
logic [3:0] Ptotal;
logic [3:0] Gtotal;

	CLA4 cla4_0(.inA(A[3:0]), .inB(B[3:0]), .inC(cin), .s(S[3:0]), .pg(pg0), .gg(gg0));
	
	assign c4 = gg0 | (cin & pg0);
	
	CLA4 cla4_1(.inA(A[7:4]), .inB(B[7:4]), .inC(c4), .s(S[7:4]), .pg(pg4), .gg(gg4));
	
	assign c8 = gg4 | (gg0 & pg4) | (cin & pg0 & pg4);
	
	CLA4 cla4_2(.inA(A[11:8]), .inB(B[11:8]), .inC(c8), .s(S[11:8]), .pg(pg8), .gg(gg8));
	
	assign c12 = gg8 | (gg4 & pg8) | (gg0 & pg8 & pg4) | (cin & pg8 & pg4 & pg0);
	
	CLA4 cla4_3(.inA(A[15:12]), .inB(B[15:12]), .inC(c12), .s(S[15:12]), .pg(pg12), .gg(gg12));
	
	
	
	assign cout = gg12 | (gg8 & pg12) | (gg4 & pg12 & pg8) |(gg0 & pg12 & pg8 & pg4 ) | (cin & pg12 & pg8 & pg4 & pg0);
	
	assign Ptotal = {pg12, pg8, pg4, pg0};
	assign Gtotal = {gg12, gg8, gg4, gg0};
	
	pg_gg group(.Pcla(Ptotal[3:0]), .Gcla(Gtotal[3:0]), .PG(pg), .GG(gg));
	
endmodule
	