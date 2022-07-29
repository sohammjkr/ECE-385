module Branch_En(input logic [15:0] IR, BUS,
					  input logic LD_BEN, LD_CC, Reset, Clk,
					  output logic BEN_out
					  );
					  
	//BUS --> NZP 
	
	logic N, Z, P, BR_in;
	
	logic [2:0] nzp, DR;
	
	assign DR = IR[11:9];
	
	
	always_ff @ (posedge Clk)
	begin
		if(Reset)
			begin
				BEN_out <= 16'h0000;
			end
			
		else if(LD_BEN)
			begin
				BEN_out <= BR_in;
			end
			
		if(LD_CC)
			begin
				nzp[2] <= N;
				nzp[1] <= Z;
				nzp[0] <= P;
			end
	end
	
	
	always_comb
		begin

			BR_in = ((nzp[2] & DR[2]) | (nzp[1] & DR[1]) | (nzp[0] & DR[0])); 
	
			if (BUS[15] == 1'b0 && BUS != 16'h0000)
				begin
					N = 1'b0;
					Z = 1'b0;
					P = 1'b1;
				end
			else if(BUS == 16'h0000)
				begin 
					N = 1'b0;
					Z = 1'b1;
					P = 1'b0;
				end
			else if(BUS[15] == 1'b1)
				begin
					N = 1'b1;
					Z = 1'b0;
					P = 1'b0;
				end
			else 
				begin
					N = 1'b1;
					Z = 1'b1;
					P = 1'b1;
				end
		end
endmodule 