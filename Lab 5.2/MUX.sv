module MUX2
		#(parameter width = 8)
		(input logic [width - 1: 0] d0, d1, 
		 input logic select,
		 output logic [width - 1: 0] y);
		
always_comb 
begin

if(select)
	begin
		y = d0;
	end
else
	begin
		y = d1;
	end
end
endmodule


module PCMUX(input logic [15:0] PC0, PC1, PC2,  //pc0 = pc + 1, pc1 = bus, pc2 = ADDR1 + ADDR2 for week 1. change for week 2
				 input logic [1:0] Select,
				 output logic [15:0] PC
				 );

	logic [15:0] temp;
	assign temp = 16'h0000;
	logic [15:0] PC_next;
	assign PC_next = PC0 + 1;
always_comb
begin
	

	unique case(Select)
		
		2'b00 : PC = PC_next;
		
		2'b01 : PC = PC1;
		
		2'b10 : PC = PC2;
		
		default : PC = PC0;
		
	endcase	
end

endmodule

module BUSMUX(input logic GateALU, GateMARMUX, GateMDR, GatePC, 
				  input logic [15:0] MDR, PC, BUS_in, EVALADDR, ALUOUT,
				  output logic [15:0] BUS);

	logic [3:0] temp;
	
always_comb
	begin
	
	temp = {GateMARMUX, GateMDR, GateALU, GatePC};

		unique case(temp)

		4'b1000 : BUS = EVALADDR; //ADDR1 + ADDR2

		4'b0100 : BUS = MDR;

		4'b0010 : BUS = ALUOUT;

		4'b0001 : BUS = PC;
		
		default : BUS = BUS_in;

		endcase	
	end
endmodule	
	
module SR1MUX_MUX(input logic [15:0] IR, 
						input logic select,
						output logic [2:0] SR1MUXOUT
					  );

always_comb
	begin
		unique case(select)
		
			1'b0 : SR1MUXOUT = IR[11:9];
		
			1'b1 : SR1MUXOUT = IR[8:6];		
		endcase	
	end	
endmodule 

module DRMUX_MUX(input logic [15:0] IR, 
						input logic select,
						output logic [2:0] DRMUXOUT
					  );

always_comb
	begin
		unique case(select)
		
			1'b0 : DRMUXOUT = IR[11:9];
		
			1'b1 : DRMUXOUT = 3'b111;		
		endcase	
	end	
endmodule

module SR2MUX_MUX(input logic [15:0] IR, SR2OUT, 
						input logic select, 
						output logic [15:0] SR2MUXOUT
						); 
	logic [4:0] IR_temp;
	logic [15:0] IR_MUX;

	assign IR_temp = IR[4:0];
	
	SEXT #(5) SEXT5_16 (.in(IR_temp), .out(IR_MUX));
always_comb
	begin
		case(select)
		
			1'b0 : SR2MUXOUT = SR2OUT;
			1'b1 : SR2MUXOUT = IR_MUX; 
			
		endcase
	end
endmodule
		
module ADDR2MUX_MUX(input logic [15:0] IR, 
						  input logic [1:0] select,
						  output logic [15:0] ADDR2MUXOUT
						  );
	logic [15:0] ZERO, SEXT6, SEXT9, SEXT11;
	
	assign ZERO = 16'h0000;
	
	SEXT #(6) SEXT6_16(.in(IR[5:0]), .out(SEXT6));
	SEXT #(9) SEXT9_16(.in(IR[8:0]), .out(SEXT9));
	SEXT #(11) SEXT11_16(.in(IR[10:0]), .out(SEXT11));

	always_comb
		begin
			case (select)
				
					2'b00 : ADDR2MUXOUT = ZERO;
					2'b01 : ADDR2MUXOUT = SEXT6;
					2'b10 : ADDR2MUXOUT = SEXT9;
					2'b11 : ADDR2MUXOUT = SEXT11;
					default: ADDR2MUXOUT = 4'hX;
			endcase
		end
endmodule

module ADDR1MUX_MUX(input logic [15:0] SR1OUT, PC, 
						  input logic select,
						  output logic [15:0] ADDR1MUXOUT
						  );
	always_comb
		begin
			case (select)	
				1'b0: ADDR1MUXOUT = PC;
				1'b1: ADDR1MUXOUT = SR1OUT;
				default: ADDR1MUXOUT = 4'hX;
			endcase
		end
endmodule  

module MARMUX_MUX(input logic [15:0] EVALADDR, IR,
						input logic select,
						output logic [15:0] MARMUXOUT
						);
			
	logic [7:0] IR_temp;
		
		always_comb
			begin
				case (select)	
				1'b0: MARMUXOUT = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, IR [7:0]};
				1'b1: MARMUXOUT = EVALADDR;
				default: MARMUXOUT = 4'hX;
			endcase
			end
endmodule 
