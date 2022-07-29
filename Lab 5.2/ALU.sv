module ALU(input logic [15:0] SR2MUXOUT, SR1OUT,
			  input logic [1:0] select,
			  output logic [15:0] ALUOUT
			  );
			  
		always_comb
			begin
				case (select)
				
					2'b00 : ALUOUT = SR2MUXOUT + SR1OUT;
					2'b01 : ALUOUT = SR2MUXOUT & SR1OUT;
					2'b10 : ALUOUT = ~SR1OUT;
					2'b11 : ALUOUT = SR1OUT;
					default: ALUOUT = 4'hx;
				endcase
			end
endmodule 
					